import { Injectable } from '@nestjs/common';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import {
  ChangeLogService,
  type TransactionClient,
} from '../change-log.service';
import type { EntitySnapshot } from '../sync.types';
import type { Applied, Meta } from './party.handler';

const MAX_NAME = 120;
const MAX_DESCRIPTION = 500;

interface ChopdiPayload {
  name?: unknown;
  description?: unknown;
  reason?: unknown;
}

interface ChopdiRow {
  id: string;
  name: string;
  description: string;
  version: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * Applies operations for a ledger book.
 *
 * Which book is *active* is deliberately not synced: it is a per-device view
 * choice, and syncing it would make switching books on one phone switch them
 * on every other.
 */
@Injectable()
export class ChopdiHandler {
  constructor(private readonly changeLog: ChangeLogService) {}

  async create(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: ChopdiPayload,
    meta: Meta,
  ): Promise<Applied> {
    const name = this.requireName(payload.name);
    const description = this.optionalDescription(payload.description);

    const existing = await tx.chopdi.findUnique({
      where: { id: entityId },
      select: { userId: true },
    });

    if (existing) {
      if (existing.userId !== userId) throw this.notFound();

      throw new AppException(
        409,
        ErrorCode.ID_EXISTS,
        'This chopdi already exists.',
        true,
        {
          entityId,
        },
      );
    }

    const row = await tx.chopdi.create({
      data: { id: entityId, userId, name, description },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'chopdi',
      entityId,
      opType: 'create',
      snapshot: this.snapshot(row),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq };
  }

  async update(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: ChopdiPayload,
    expectedVersion: number,
    meta: Meta,
  ): Promise<Applied> {
    const current = await this.load(tx, userId, entityId);

    if (current.deletedAt) {
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        'This chopdi has been deleted.',
        true,
      );
    }

    this.assertVersion(current, expectedVersion);

    const row = await tx.chopdi.update({
      where: { id: entityId },
      data: {
        name:
          payload.name === undefined
            ? undefined
            : this.requireName(payload.name),
        description:
          payload.description === undefined
            ? undefined
            : this.optionalDescription(payload.description),
        version: { increment: 1 },
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'chopdi',
      entityId,
      opType: 'update',
      snapshot: this.snapshot(row),
      previous: this.snapshot(current),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq };
  }

  async void(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    _payload: ChopdiPayload,
    expectedVersion: number,
    meta: Meta,
  ): Promise<Applied> {
    const current = await this.load(tx, userId, entityId);

    if (current.deletedAt) {
      return { snapshot: this.snapshot(current), seq: 0n };
    }

    this.assertVersion(current, expectedVersion);

    const row = await tx.chopdi.update({
      where: { id: entityId },
      data: { deletedAt: new Date(), version: { increment: 1 } },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'chopdi',
      entityId,
      opType: 'void',
      snapshot: this.snapshot(row),
      previous: this.snapshot(current),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq };
  }

  // ------------------------------------------------------------------ internals

  private async load(tx: TransactionClient, userId: string, entityId: string) {
    const row = await tx.chopdi.findFirst({ where: { id: entityId, userId } });
    if (!row) throw this.notFound();
    return row;
  }

  private notFound(): AppException {
    return new AppException(
      404,
      ErrorCode.NOT_FOUND,
      'That chopdi could not be found.',
      true,
    );
  }

  private assertVersion(current: { version: number }, expected: number): void {
    if (current.version !== expected) {
      throw new AppException(
        409,
        ErrorCode.STALE_VERSION,
        'This chopdi was changed on another device.',
        false,
        { expectedVersion: expected, actualVersion: current.version },
      );
    }
  }

  private requireName(value: unknown): string {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw this.invalid('Chopdi name is required.', 'name');
    }
    const trimmed = value.trim();
    if (trimmed.length > MAX_NAME)
      throw this.invalid('Chopdi name is too long.', 'name');
    return trimmed;
  }

  private optionalDescription(value: unknown): string {
    if (value === undefined || value === null) return '';
    if (typeof value !== 'string')
      throw this.invalid('description must be text.', 'description');
    const trimmed = value.trim();
    if (trimmed.length > MAX_DESCRIPTION) {
      throw this.invalid('description is too long.', 'description');
    }
    return trimmed;
  }

  private invalid(message: string, field: string): AppException {
    return new AppException(400, ErrorCode.VALIDATION_FAILED, message, true, {
      field,
    });
  }

  private snapshot(row: ChopdiRow): EntitySnapshot {
    return {
      id: row.id,
      name: row.name,
      description: row.description,
      version: row.version,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      deletedAt: row.deletedAt?.toISOString() ?? null,
    };
  }
}
