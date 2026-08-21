import { Injectable } from '@nestjs/common';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import { ChangeLogService, type TransactionClient } from '../change-log.service';
import type { EntitySnapshot } from '../sync.types';

interface CustomerPayload {
  name?: unknown;
  phone?: unknown;
  notes?: unknown;
  reason?: unknown;
}

/**
 * Applies customer operations.
 *
 * Every lookup is scoped by `userId`. Not "looked up then checked" — scoped in
 * the query itself, as one statement, because an ownership check written
 * separately is one that can be forgotten in the next method.
 */
@Injectable()
export class CustomerHandler {
  constructor(private readonly changeLog: ChangeLogService) {}

  static readonly maxNameLength = 120;

  async create(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: CustomerPayload,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const name = this.requireName(payload.name);
    const phone = this.optionalString(payload.phone, 'phone');
    const notes = this.optionalString(payload.notes, 'notes') ?? '';

    const existing = await tx.customer.findUnique({
      where: { id: entityId },
      select: { id: true, userId: true },
    });

    if (existing) {
      // A create for an id that already exists. Under this user it is a
      // duplicate; under another it is someone probing whether an id is taken.
      // Both answer the same way — a different response for the cross-tenant
      // case would confirm the id belongs to a real account.
      if (existing.userId !== userId) throw this.notFound();

      throw new AppException(
        409,
        ErrorCode.ID_EXISTS,
        'This customer already exists.',
        true,
        { entityId },
      );
    }

    const row = await tx.customer.create({
      data: { id: entityId, userId, name, phoneE164: phone, notes },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'customer',
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
    payload: CustomerPayload,
    expectedVersion: number,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const current = await this.load(tx, userId, entityId);

    if (current.deletedAt) {
      // Delete wins over a concurrent update. Letting an update resurrect a
      // deleted row means a device that was offline can undo a deletion the
      // user made deliberately.
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        'This customer has been deleted.',
        true,
      );
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    const row = await tx.customer.update({
      where: { id: entityId },
      data: {
        name: payload.name === undefined ? undefined : this.requireName(payload.name),
        phoneE164:
          payload.phone === undefined
            ? undefined
            : this.optionalString(payload.phone, 'phone'),
        notes:
          payload.notes === undefined
            ? undefined
            : (this.optionalString(payload.notes, 'notes') ?? ''),
        version: { increment: 1 },
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'customer',
      entityId,
      opType: 'update',
      snapshot: this.snapshot(row),
      previous,
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq };
  }

  async void(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: CustomerPayload,
    expectedVersion: number,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const current = await this.load(tx, userId, entityId);

    // Deleting an already-deleted row is a success, not an error. A client
    // retrying a delete it never got a response for must not be told its data
    // is broken.
    if (current.deletedAt) {
      return { snapshot: this.snapshot(current), seq: 0n };
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    const row = await tx.customer.update({
      where: { id: entityId },
      data: { deletedAt: new Date(), version: { increment: 1 } },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'customer',
      entityId,
      opType: 'void',
      snapshot: this.snapshot(row),
      previous,
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq };
  }

  // ------------------------------------------------------------------ internals

  private async load(tx: TransactionClient, userId: string, entityId: string) {
    const row = await tx.customer.findFirst({ where: { id: entityId, userId } });
    if (!row) throw this.notFound();
    return row;
  }

  /**
   * A row belonging to another tenant is reported exactly as a row that does
   * not exist: same code, same message. Anything else turns this endpoint into
   * an oracle confirming that a given id belongs to a real account.
   */
  private notFound(): AppException {
    return new AppException(
      404,
      ErrorCode.NOT_FOUND,
      'That customer could not be found.',
      true,
    );
  }

  private assertVersion(current: { version: number }, expected: number): void {
    if (current.version !== expected) {
      throw new AppException(
        409,
        ErrorCode.STALE_VERSION,
        'This customer was changed on another device.',
        false,
        { expectedVersion: expected, actualVersion: current.version },
      );
    }
  }

  private requireName(value: unknown): string {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        'Customer name is required.',
        true,
        { field: 'name' },
      );
    }

    const trimmed = value.trim();

    if (trimmed.length > CustomerHandler.maxNameLength) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        'Customer name is too long.',
        true,
        { field: 'name' },
      );
    }

    return trimmed;
  }

  private optionalString(value: unknown, field: string): string | null {
    if (value === null || value === undefined) return null;

    if (typeof value !== 'string') {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        `${field} must be text.`,
        true,
        { field },
      );
    }

    const trimmed = value.trim();
    return trimmed.length === 0 ? null : trimmed;
  }

  private snapshot(row: {
    id: string;
    name: string;
    phoneE164: string | null;
    notes: string;
    version: number;
    createdAt: Date;
    updatedAt: Date;
    deletedAt: Date | null;
  }): EntitySnapshot {
    return {
      id: row.id,
      name: row.name,
      phone: row.phoneE164,
      notes: row.notes,
      version: row.version,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      deletedAt: row.deletedAt?.toISOString() ?? null,
    };
  }
}
