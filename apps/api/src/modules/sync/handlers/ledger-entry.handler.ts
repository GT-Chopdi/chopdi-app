import { Injectable } from '@nestjs/common';

import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import { ChangeLogService, type TransactionClient } from '../change-log.service';
import type { EntitySnapshot } from '../sync.types';

/** ₹100 crore, matching `ledger_entry_amount_sane`. */
const MAX_AMOUNT_PAISE = 10_000_000_000_000n;
const MAX_RATE_BP = 1_000_000;
const MAX_DESCRIPTION = 500;

const DIRECTIONS = ['gave', 'received'] as const;
const LEDGER_SIDES = ['lent', 'borrowed'] as const;
const INTEREST_TYPES = ['none', 'simple', 'compound'] as const;
const FREQUENCIES = ['daily', 'weekly', 'monthly', 'yearly'] as const;

/**
 * Applies ledger-entry operations.
 *
 * Entries are facts rather than state: two devices creating entries offline
 * produce a union, not a conflict, and balances are derived by folding them.
 * That is why nothing here stores a balance — there is no shared number for two
 * devices to disagree about.
 *
 * Validation duplicates the database's CHECK constraints on purpose. The
 * constraints are the backstop that no code path can bypass; these produce a
 * message naming the field, so a rejected entry tells the user what to fix
 * instead of surfacing as an opaque constraint violation.
 */
@Injectable()
export class LedgerEntryHandler {
  constructor(private readonly changeLog: ChangeLogService) {}

  async create(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: Record<string, unknown>,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const customerId = this.requireUuid(payload.customerId, 'customerId');

    // The parent must exist and belong to this user. Scoped in the query, so a
    // cross-tenant customer id is indistinguishable from one that never
    // existed.
    const customer = await tx.customer.findFirst({
      where: { id: customerId, userId },
      select: { id: true, deletedAt: true },
    });

    if (!customer) {
      // Not permanent: entries and their customer are usually created in the
      // same batch, and a customer whose own operation failed may succeed on
      // the next attempt. The client retries a bounded number of times before
      // giving up, rather than dead-lettering a valid entry immediately.
      throw new AppException(
        409,
        ErrorCode.PARENT_NOT_FOUND,
        'That customer has not been synced yet.',
        false,
        { customerId },
      );
    }

    if (customer.deletedAt) {
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        'That customer has been deleted.',
        true,
        { customerId },
      );
    }

    const existing = await tx.ledgerEntry.findUnique({
      where: { id: entityId },
      select: { id: true, userId: true },
    });

    if (existing) {
      if (existing.userId !== userId) throw this.notFound();

      throw new AppException(
        409,
        ErrorCode.ID_EXISTS,
        'This entry already exists.',
        true,
        { entityId },
      );
    }

    const row = await tx.ledgerEntry.create({
      data: {
        id: entityId,
        userId,
        customerId,
        amountPaise: this.requireAmount(payload.amountPaise),
        direction: this.requireEnum(payload.direction, DIRECTIONS, 'direction'),
        ledgerSide: this.optionalEnum(payload.ledgerSide, LEDGER_SIDES, 'ledgerSide') ?? 'lent',
        interestRateBp: this.optionalRate(payload.interestRateBp),
        interestType:
          this.optionalEnum(payload.interestType, INTEREST_TYPES, 'interestType') ?? 'none',
        interestFrequency:
          this.optionalEnum(payload.interestFrequency, FREQUENCIES, 'interestFrequency') ??
          'monthly',
        entryDate: this.requireDate(payload.entryDate),
        description: this.optionalText(payload.description, 'description'),
        paymentMode: this.optionalText(payload.paymentMode, 'paymentMode'),
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'ledger_entry',
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
    payload: Record<string, unknown>,
    expectedVersion: number,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const current = await this.load(tx, userId, entityId);

    if (current.voidedAt) {
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        'This entry has been deleted.',
        true,
      );
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    const row = await tx.ledgerEntry.update({
      where: { id: entityId },
      data: {
        amountPaise:
          payload.amountPaise === undefined
            ? undefined
            : this.requireAmount(payload.amountPaise),
        interestRateBp:
          payload.interestRateBp === undefined
            ? undefined
            : this.optionalRate(payload.interestRateBp),
        entryDate:
          payload.entryDate === undefined ? undefined : this.requireDate(payload.entryDate),
        description:
          payload.description === undefined
            ? undefined
            : this.optionalText(payload.description, 'description'),
        paymentMode:
          payload.paymentMode === undefined
            ? undefined
            : this.optionalText(payload.paymentMode, 'paymentMode'),
        version: { increment: 1 },
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'ledger_entry',
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
    payload: Record<string, unknown>,
    expectedVersion: number,
    meta: { deviceId: string; opId: string },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint }> {
    const current = await this.load(tx, userId, entityId);

    if (current.voidedAt) {
      return { snapshot: this.snapshot(current), seq: 0n };
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    const row = await tx.ledgerEntry.update({
      where: { id: entityId },
      data: {
        voidedAt: new Date(),
        // The database requires a reason on a voided row: an audit trail that
        // records a deletion without saying why explains nothing.
        voidedReason: this.optionalText(payload.reason, 'reason') || 'Deleted by user',
        version: { increment: 1 },
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'ledger_entry',
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
    const row = await tx.ledgerEntry.findFirst({ where: { id: entityId, userId } });
    if (!row) throw this.notFound();
    return row;
  }

  private notFound(): AppException {
    return new AppException(404, ErrorCode.NOT_FOUND, 'That entry could not be found.', true);
  }

  private assertVersion(current: { version: number }, expected: number): void {
    if (current.version !== expected) {
      throw new AppException(
        409,
        ErrorCode.STALE_VERSION,
        'This entry was changed on another device.',
        false,
        { expectedVersion: expected, actualVersion: current.version },
      );
    }
  }

  private invalid(message: string, field: string): AppException {
    return new AppException(400, ErrorCode.VALIDATION_FAILED, message, true, { field });
  }

  /**
   * Amounts are strictly positive; `direction` carries the sign. A negative
   * amount is therefore not a rejected value but an unrepresentable one.
   */
  private requireAmount(value: unknown): bigint {
    if (typeof value !== 'number' || !Number.isInteger(value)) {
      throw this.invalid('Amount must be a whole number of paise.', 'amountPaise');
    }
    if (value <= 0) {
      throw this.invalid('Amount must be greater than zero.', 'amountPaise');
    }
    if (BigInt(value) > MAX_AMOUNT_PAISE) {
      throw this.invalid('That amount is too large.', 'amountPaise');
    }
    return BigInt(value);
  }

  private optionalRate(value: unknown): number {
    if (value === undefined || value === null) return 0;
    if (typeof value !== 'number' || !Number.isInteger(value)) {
      throw this.invalid('Interest rate must be whole basis points.', 'interestRateBp');
    }
    if (value < 0 || value > MAX_RATE_BP) {
      throw this.invalid('Interest rate is out of range.', 'interestRateBp');
    }
    return value;
  }

  /**
   * `entryDate` is a business date, not an instant: "3 March" is the same day
   * whatever the clock said, and interest day-counts run on calendar days.
   */
  private requireDate(value: unknown): Date {
    if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      throw this.invalid('Entry date must look like 2026-03-03.', 'entryDate');
    }

    const parsed = new Date(`${value}T00:00:00.000Z`);
    if (Number.isNaN(parsed.getTime())) {
      throw this.invalid('Entry date is not a real date.', 'entryDate');
    }

    // A day of slack absorbs timezone skew; beyond that a future date is a
    // typo, and back-dating decades would fabricate years of accrued interest.
    const tomorrow = new Date(Date.now() + 86_400_000);
    if (parsed > tomorrow) {
      throw this.invalid('Entry date cannot be in the future.', 'entryDate');
    }
    if (parsed.getUTCFullYear() < new Date().getUTCFullYear() - 50) {
      throw this.invalid('Entry date is too far in the past.', 'entryDate');
    }

    return parsed;
  }

  private requireUuid(value: unknown, field: string): string {
    if (
      typeof value !== 'string' ||
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
    ) {
      throw this.invalid(`${field} must be a UUID.`, field);
    }
    return value;
  }

  private requireEnum<T extends readonly string[]>(
    value: unknown,
    allowed: T,
    field: string,
  ): T[number] {
    if (typeof value !== 'string' || !allowed.includes(value)) {
      throw this.invalid(`${field} must be one of: ${allowed.join(', ')}.`, field);
    }
    return value;
  }

  private optionalEnum<T extends readonly string[]>(
    value: unknown,
    allowed: T,
    field: string,
  ): T[number] | undefined {
    if (value === undefined || value === null || value === '') return undefined;
    return this.requireEnum(value, allowed, field);
  }

  private optionalText(value: unknown, field: string): string {
    if (value === undefined || value === null) return '';
    if (typeof value !== 'string') throw this.invalid(`${field} must be text.`, field);

    const trimmed = value.trim();
    if (trimmed.length > MAX_DESCRIPTION) {
      throw this.invalid(`${field} is too long.`, field);
    }
    return trimmed;
  }

  private snapshot(row: {
    id: string;
    customerId: string;
    amountPaise: bigint;
    direction: string;
    ledgerSide: string;
    interestRateBp: number;
    interestType: string;
    interestFrequency: string;
    entryDate: Date;
    description: string;
    paymentMode: string;
    version: number;
    createdAt: Date;
    updatedAt: Date;
    voidedAt: Date | null;
    voidedReason: string | null;
  }): EntitySnapshot {
    return {
      id: row.id,
      customerId: row.customerId,
      // A string on the wire: JSON numbers are IEEE-754, and a ledger should
      // not depend on staying under 2^53 to stay exact.
      amountPaise: row.amountPaise.toString(),
      direction: row.direction,
      ledgerSide: row.ledgerSide,
      interestRateBp: row.interestRateBp,
      interestType: row.interestType,
      interestFrequency: row.interestFrequency,
      entryDate: row.entryDate.toISOString().slice(0, 10),
      description: row.description,
      paymentMode: row.paymentMode,
      version: row.version,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      voidedAt: row.voidedAt?.toISOString() ?? null,
      voidedReason: row.voidedReason,
    };
  }
}
