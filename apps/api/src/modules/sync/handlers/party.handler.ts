import { AppException, ErrorCode } from '../../../common/errors/app.exception';
import {
  ChangeLogService,
  type TransactionClient,
} from '../change-log.service';
import type { MergeService } from '../merge.service';
import { partyKeys } from '../party-keys';
import type { EntitySnapshot } from '../sync.types';
import { ledgerEntrySnapshot } from './ledger-entry.snapshot';

/** `voided_reason` on entries voided because their customer or lender was deleted. */
export const PARTY_DELETED = 'Party deleted';

export type PartyEntity = 'customer' | 'lender';

export interface PartyRow {
  id: string;
  userId: string;
  chopdiId: string | null;
  name: string;
  phoneE164: string | null;
  notes: string;
  version: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * The slice of a Prisma delegate the party handlers use. `customer` and
 * `lender` have identical columns, so one handler body serves both; the cast
 * to this interface happens once, in each subclass's `table()`.
 */
export interface PartyDelegate {
  findUnique(args: {
    where: { id: string };
    select: { id: true; userId: true };
  }): Promise<{ id: string; userId: string } | null>;
  findFirst(args: {
    where: { id: string; userId: string };
  }): Promise<PartyRow | null>;
  create(args: {
    data: {
      id: string;
      userId: string;
      chopdiId: string | null;
      name: string;
      phoneE164: string | null;
      notes: string;
      nameKey: string;
      phoneKey: string;
    };
  }): Promise<PartyRow>;
  update(args: {
    where: { id: string };
    data: Record<string, unknown>;
  }): Promise<PartyRow>;
}

export interface PartyPayload {
  name?: unknown;
  phone?: unknown;
  notes?: unknown;
  chopdiId?: unknown;
  reason?: unknown;
}

export type Meta = { deviceId: string; opId: string };
export type Applied = { snapshot: EntitySnapshot; seq: bigint; mergedInto?: string };

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Applies operations for a party in someone's ledger: a customer (I gave) or a
 * lender (I took).
 *
 * Every lookup is scoped by `userId`. Not "looked up then checked" — scoped in
 * the query itself, as one statement, because an ownership check written
 * separately is one that can be forgotten in the next method.
 */
export abstract class PartyHandler {
  constructor(
    protected readonly changeLog: ChangeLogService,
    protected readonly merges: MergeService,
  ) {}

  static readonly maxNameLength = 120;

  protected abstract readonly entity: PartyEntity;

  /** Human noun for messages: "customer" or "lender". */
  protected abstract readonly label: string;

  protected abstract table(tx: TransactionClient): PartyDelegate;

  /**
   * A chance to satisfy a create from existing data before inserting.
   * Returns null to fall through to a normal insert.
   */
  protected adopt?(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    fields: {
      chopdiId: string | null;
      name: string;
      phone: string | null;
      notes: string;
    },
    meta: Meta,
  ): Promise<Applied | null>;

  async create(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    payload: PartyPayload,
    meta: Meta,
  ): Promise<Applied> {
    const name = this.requireName(payload.name);
    const phone = this.optionalString(payload.phone, 'phone');
    const notes = this.optionalString(payload.notes, 'notes') ?? '';
    const chopdiId = await this.resolveChopdi(tx, userId, payload.chopdiId);

    // Before the duplicate check, not after: see MergeService.lockUser.
    await this.merges.lockUser(tx, userId);

    const existing = await this.table(tx).findUnique({
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
        `This ${this.label} already exists.`,
        true,
        { entityId },
      );
    }

    // Already folded into another row — the same create sent again under a
    // new opId, e.g. after a reinstall. Answer as the merge did.
    const merged = await this.merges.findByAlias(tx, userId, entityId);
    if (merged) {
      if (merged.entity !== this.entity) throw this.notFound();
      const main = await this.load(tx, userId, merged.mainId);
      return { snapshot: this.snapshot(main), seq: 0n, mergedInto: main.id };
    }

    const adopted = await this.adopt?.(
      tx,
      userId,
      entityId,
      { chopdiId, name, phone, notes },
      meta,
    );
    if (adopted) return adopted;

    // The same person created on another device while this one was offline.
    const keys = partyKeys(name, phone);
    const match = await this.merges.findMatch(tx, this.entity, userId, chopdiId, keys);
    if (match) {
      return this.merges.merge(tx, {
        entity: this.entity,
        userId,
        main: match,
        aliasId: entityId,
        alias: { chopdiId, name, phone, notes },
        meta,
      });
    }

    const row = await this.table(tx).create({
      data: { id: entityId, userId, chopdiId, name, phoneE164: phone, notes, ...keys },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: this.entity,
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
    payload: PartyPayload,
    expectedVersion: number,
    meta: Meta,
  ): Promise<Applied> {
    const current = await this.load(tx, userId, entityId);

    if (current.deletedAt) {
      // Delete wins over a concurrent update. Letting an update resurrect a
      // deleted row means a device that was offline can undo a deletion the
      // user made deliberately.
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        `This ${this.label} has been deleted.`,
        true,
      );
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    const name =
      payload.name === undefined ? current.name : this.requireName(payload.name);
    const phone =
      payload.phone === undefined
        ? current.phoneE164
        : this.optionalString(payload.phone, 'phone');
    const chopdiId =
      payload.chopdiId === undefined
        ? current.chopdiId
        : await this.resolveChopdi(tx, userId, payload.chopdiId);
    const keys = partyKeys(name, phone);
    const before = partyKeys(current.name, current.phoneE164);

    // Only an edit that changes who this is can collide. Checking every edit
    // would also refuse a notes change on a row that is already one of a
    // duplicate pair from before merging existed.
    if (
      keys.nameKey !== before.nameKey ||
      keys.phoneKey !== before.phoneKey ||
      chopdiId !== current.chopdiId
    ) {
      await this.assertNoOtherMatch(tx, userId, current.id, chopdiId, keys);
    }

    const row = await this.table(tx).update({
      where: { id: current.id },
      data: {
        name,
        phoneE164: phone,
        ...keys,
        notes:
          payload.notes === undefined
            ? undefined
            : (this.optionalString(payload.notes, 'notes') ?? ''),
        // Sent by a client backfilling the book on rows synced before books
        // were, and when a party moves between books.
        chopdiId,
        version: { increment: 1 },
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: this.entity,
      entityId: current.id,
      opType: 'update',
      snapshot: this.snapshot(row),
      previous,
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq, ...this.redirected(entityId, current.id) };
  }

  async void(
    tx: TransactionClient,
    userId: string,
    entityId: string,
    _payload: PartyPayload,
    expectedVersion: number,
    meta: Meta,
  ): Promise<Applied> {
    const current = await this.load(tx, userId, entityId);

    // Deleting an already-deleted row is a success, not an error. A client
    // retrying a delete it never got a response for must not be told its data
    // is broken.
    if (current.deletedAt) {
      return { snapshot: this.snapshot(current), seq: 0n, ...this.redirected(entityId, current.id) };
    }

    this.assertVersion(current, expectedVersion);

    const previous = this.snapshot(current);

    await this.voidLiveEntries(tx, userId, current.id, meta);

    const row = await this.table(tx).update({
      where: { id: current.id },
      data: { deletedAt: new Date(), version: { increment: 1 } },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity: this.entity,
      entityId: current.id,
      opType: 'void',
      snapshot: this.snapshot(row),
      previous,
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: this.snapshot(row), seq, ...this.redirected(entityId, current.id) };
  }

  // ------------------------------------------------------------------ internals

  /**
   * Voids the entries still live under a party being deleted.
   *
   * The app is meant to send a void for each entry alongside the party's, but
   * the server must not depend on it: a deleted customer with live entries
   * still counts in balances and comes back on every restore. Entries the app
   * does void arrive after this (parties sort before entries in a batch), find
   * themselves already voided, and succeed without writing — see
   * LedgerEntryHandler.void.
   */
  private async voidLiveEntries(
    tx: TransactionClient,
    userId: string,
    partyId: string,
    meta: Meta,
  ): Promise<void> {
    const parent =
      this.entity === 'customer'
        ? { customerId: partyId }
        : { lenderId: partyId };

    const live = await tx.ledgerEntry.findMany({
      where: { userId, ...parent, voidedAt: null },
      orderBy: { createdAt: 'asc' },
    });

    for (const entry of live) {
      const row = await tx.ledgerEntry.update({
        where: { id: entry.id },
        data: {
          voidedAt: new Date(),
          voidedReason: PARTY_DELETED,
          version: { increment: 1 },
        },
      });

      await this.changeLog.append(tx, {
        userId,
        entity: 'ledger_entry',
        entityId: entry.id,
        opType: 'void',
        snapshot: ledgerEntrySnapshot(row),
        previous: ledgerEntrySnapshot(entry),
        deviceId: meta.deviceId,
        opId: meta.opId,
      });
    }
  }

  /**
   * The row an id refers to — following a merge, so an edit or delete a device
   * queued against its own copy of a merged party lands on the survivor.
   */
  protected async load(
    tx: TransactionClient,
    userId: string,
    entityId: string,
  ) {
    const { id } = await this.merges.resolve(tx, userId, entityId);
    const row = await this.table(tx).findFirst({
      where: { id, userId },
    });
    if (!row) throw this.notFound();
    return row;
  }

  /** Tells the client which id an operation sent under a merged alias landed on. */
  private redirected(sentId: string, actualId: string): { mergedInto?: string } {
    return sentId === actualId ? {} : { mergedInto: actualId };
  }

  /**
   * An edit that would make this party a duplicate of another live one.
   *
   * Refused rather than merged: unlike a create, both rows already have their
   * own entries and history, and silently voiding one side's entries because
   * of a rename is not something the user asked for.
   */
  private async assertNoOtherMatch(
    tx: TransactionClient,
    userId: string,
    selfId: string,
    chopdiId: string | null,
    keys: { nameKey: string; phoneKey: string },
  ): Promise<void> {
    const other = await this.merges.findMatch(tx, this.entity, userId, chopdiId, keys);
    if (!other || other.id === selfId) return;

    throw new AppException(
      409,
      ErrorCode.PARTY_EXISTS,
      `Another ${this.label} already has this name and phone number.`,
      true,
      { otherId: other.id },
    );
  }

  /**
   * The book a party belongs to. Optional — rows from builds that did not sync
   * books carry none — but when given it must be one of this user's live books.
   */
  protected async resolveChopdi(
    tx: TransactionClient,
    userId: string,
    value: unknown,
  ): Promise<string | null> {
    if (value === undefined || value === null) return null;

    if (typeof value !== 'string' || !UUID.test(value)) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        'chopdiId must be a UUID.',
        true,
        {
          field: 'chopdiId',
        },
      );
    }

    const chopdi = await tx.chopdi.findFirst({
      where: { id: value, userId },
      select: { id: true, deletedAt: true },
    });

    if (!chopdi) {
      // Not permanent, for the same reason as an entry whose customer is
      // missing: the book's own create is usually in the same batch.
      throw new AppException(
        409,
        ErrorCode.PARENT_NOT_FOUND,
        'That chopdi has not been synced yet.',
        false,
        { chopdiId: value },
      );
    }

    if (chopdi.deletedAt) {
      throw new AppException(
        409,
        ErrorCode.ENTITY_VOIDED,
        'That chopdi has been deleted.',
        true,
        {
          chopdiId: value,
        },
      );
    }

    return chopdi.id;
  }

  /**
   * A row belonging to another tenant is reported exactly as a row that does
   * not exist: same code, same message. Anything else turns this endpoint into
   * an oracle confirming that a given id belongs to a real account.
   */
  protected notFound(): AppException {
    return new AppException(
      404,
      ErrorCode.NOT_FOUND,
      `That ${this.label} could not be found.`,
      true,
    );
  }

  protected assertVersion(
    current: { version: number },
    expected: number,
  ): void {
    if (current.version !== expected) {
      throw new AppException(
        409,
        ErrorCode.STALE_VERSION,
        `This ${this.label} was changed on another device.`,
        false,
        { expectedVersion: expected, actualVersion: current.version },
      );
    }
  }

  protected requireName(value: unknown): string {
    const noun = this.label.charAt(0).toUpperCase() + this.label.slice(1);

    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        `${noun} name is required.`,
        true,
        {
          field: 'name',
        },
      );
    }

    const trimmed = value.trim();

    if (trimmed.length > PartyHandler.maxNameLength) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        `${noun} name is too long.`,
        true,
        {
          field: 'name',
        },
      );
    }

    return trimmed;
  }

  protected optionalString(value: unknown, field: string): string | null {
    if (value === null || value === undefined) return null;

    if (typeof value !== 'string') {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        `${field} must be text.`,
        true,
        {
          field,
        },
      );
    }

    const trimmed = value.trim();
    return trimmed.length === 0 ? null : trimmed;
  }

  protected snapshot(row: PartyRow): EntitySnapshot {
    return partySnapshot(row);
  }
}

export function partySnapshot(row: PartyRow): EntitySnapshot {
  return {
    id: row.id,
    chopdiId: row.chopdiId,
    name: row.name,
    phone: row.phoneE164,
    notes: row.notes,
    version: row.version,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    deletedAt: row.deletedAt?.toISOString() ?? null,
  };
}
