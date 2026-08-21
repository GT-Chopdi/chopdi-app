import { Injectable, Logger } from '@nestjs/common';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PushBatchDto, SyncOperationDto } from './dto/push.dto';
import { CustomerHandler } from './handlers/customer.handler';
import { LedgerEntryHandler } from './handlers/ledger-entry.handler';
import { IdempotencyService } from './idempotency.service';
import type { SyncOperationResult, SyncPushResponse } from './sync.types';

/** Customers must be applied before the entries that reference them. */
const ENTITY_ORDER: Record<string, number> = { customer: 1, ledger_entry: 2 };

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly idempotency: IdempotencyService,
    private readonly customers: CustomerHandler,
    private readonly entries: LedgerEntryHandler,
  ) {}

  /**
   * Applies a batch and reports on each operation individually.
   *
   * ## Per item, not all-or-nothing
   *
   * One malformed operation must not block the 199 behind it. All-or-nothing
   * gives head-of-line blocking: a single permanently-invalid entry would stall
   * a user's entire ledger forever, and they would have no way to find or fix
   * it. Each operation therefore succeeds or fails on its own, and the client
   * advances past the ones that landed.
   *
   * ## One transaction per operation
   *
   * Not one for the batch. Neon is serverless: a long transaction holds a
   * pooled connection for its whole duration, and a compute restart or scale
   * event kills whatever is in flight. Short transactions lose one operation,
   * which a retry recovers; a long one loses the lot. It is also what makes
   * partial success expressible at all.
   */
  async push(user: AuthenticatedUser, batch: PushBatchDto): Promise<SyncPushResponse> {
    const ordered = this.sortByDependency(batch.operations);
    const results: SyncOperationResult[] = [];

    for (const operation of ordered) {
      results.push(await this.applyOne(user, operation));
    }

    const cursor = await this.prisma.appUser.findUnique({
      where: { id: user.userId },
      select: { changeSeq: true },
    });

    // Results are returned in the client's original order. The server reorders
    // for correctness, but a client matching results to its outbox by position
    // would silently mis-attribute them.
    const byOpId = new Map(results.map((r) => [r.opId, r]));

    return {
      results: batch.operations.map(
        (op) => byOpId.get(op.opId) ?? this.rejected(op.opId, this.internal()),
      ),
      serverCursor: (cursor?.changeSeq ?? 0n).toString(),
    };
  }

  /**
   * Sorts customers ahead of entries, preserving client order within a kind.
   *
   * The client already orders its outbox correctly; this exists because a
   * client bug shipped months ago should not become server-side data loss. The
   * ranking assumes an FK graph exactly one level deep — true for
   * customer → ledger_entry and nothing more. A deeper hierarchy would need a
   * real topological sort.
   */
  private sortByDependency(operations: SyncOperationDto[]): SyncOperationDto[] {
    return operations
      .map((op, index) => ({ op, index }))
      .sort((a, b) => {
        const rank = (ENTITY_ORDER[a.op.entity] ?? 99) - (ENTITY_ORDER[b.op.entity] ?? 99);
        return rank !== 0 ? rank : a.index - b.index;
      })
      .map(({ op }) => op);
  }

  private async applyOne(
    user: AuthenticatedUser,
    operation: SyncOperationDto,
  ): Promise<SyncOperationResult> {
    const payloadHash = this.idempotency.fingerprint(operation.payload);

    try {
      return await this.prisma.$transaction(async (tx) => {
        // Claimed inside the same transaction as the write, so the record and
        // the row commit together or not at all.
        const recorded = await this.idempotency.findRecorded(
          tx,
          user.userId,
          operation.opId,
          payloadHash,
        );

        if (recorded) {
          return { ...recorded.result, status: 'duplicate' as const };
        }

        const { snapshot, seq } = await this.dispatch(tx, user, operation);

        const result: SyncOperationResult = {
          opId: operation.opId,
          status: 'applied',
          entityId: operation.entityId,
          version: snapshot.version,
          seq: seq.toString(),
        };

        await this.idempotency.record(tx, {
          userId: user.userId,
          opId: operation.opId,
          deviceId: user.deviceId,
          entity: operation.entity,
          entityId: operation.entityId,
          opType: operation.opType,
          payloadHash,
          result,
        });

        return result;
      });
    } catch (error) {
      return this.toResult(operation, error);
    }
  }

  private dispatch(
    tx: Parameters<Parameters<PrismaService['$transaction']>[0]>[0],
    user: AuthenticatedUser,
    operation: SyncOperationDto,
  ) {
    const meta = { deviceId: user.deviceId, opId: operation.opId };
    const handler = operation.entity === 'customer' ? this.customers : this.entries;

    switch (operation.opType) {
      case 'create':
        return handler.create(tx, user.userId, operation.entityId, operation.payload, meta);

      case 'update':
        return handler.update(
          tx,
          user.userId,
          operation.entityId,
          operation.payload,
          this.requireExpectedVersion(operation),
          meta,
        );

      case 'void':
        return handler.void(
          tx,
          user.userId,
          operation.entityId,
          operation.payload,
          this.requireExpectedVersion(operation),
          meta,
        );
    }
  }

  /**
   * An update without a version cannot be conflict-checked, so it is refused
   * rather than applied blindly — accepting it would silently overwrite a
   * change made on another device.
   */
  private requireExpectedVersion(operation: SyncOperationDto): number {
    if (operation.expectedVersion === undefined) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        `A ${operation.opType} operation must carry expectedVersion.`,
        true,
        { field: 'expectedVersion' },
      );
    }
    return operation.expectedVersion;
  }

  /**
   * Turns a thrown error into a per-item result.
   *
   * A conflict is reported separately from a rejection because the client acts
   * on them differently: a conflict is resolved by the user, a rejection is
   * retried or dead-lettered.
   */
  private toResult(operation: SyncOperationDto, error: unknown): SyncOperationResult {
    if (error instanceof AppException) {
      const details = (error.details ?? {}) as Record<string, unknown>;

      return {
        opId: operation.opId,
        status: error.code === ErrorCode.STALE_VERSION ? 'conflict' : 'rejected',
        entityId: operation.entityId,
        error: {
          code: error.code,
          message: error.message,
          permanent: error.permanent,
          details,
        },
      };
    }

    // Anything unrecognised is logged in full and reported opaquely. The client
    // must retry rather than discard: an unknown failure is not evidence the
    // data is bad.
    this.logger.error(
      `Unhandled error applying ${operation.entity}/${operation.opType} ` +
        `(op=${operation.opId}): ${String(error)}`,
    );

    return this.rejected(operation.opId, this.internal(), operation.entityId);
  }

  private internal() {
    return {
      code: ErrorCode.INTERNAL,
      message: 'This change could not be applied. It will be retried.',
      permanent: false,
    };
  }

  private rejected(
    opId: string,
    error: { code: string; message: string; permanent: boolean },
    entityId?: string,
  ): SyncOperationResult {
    return { opId, status: 'rejected', entityId, error };
  }
}
