import { Injectable } from '@nestjs/common';

import { ChangeLogService, type TransactionClient } from './change-log.service';
import { ledgerEntrySnapshot } from './handlers/ledger-entry.snapshot';
import {
  partySnapshot,
  type PartyEntity,
  type PartyRow,
} from './handlers/party.handler';
import type { PartyKeys } from './party-keys';
import type { EntitySnapshot } from './sync.types';

/** `voided_reason` on entries a merge switched off. Also how they are found again. */
export const MERGED_DUPLICATE = 'merged_duplicate';

type Meta = { deviceId: string; opId: string };

/** Fields of the duplicate as its device sent them. */
export interface AliasFields {
  chopdiId: string | null;
  name: string;
  phone: string | null;
  notes: string;
}

/**
 * Folds duplicate customers and lenders created on two offline devices.
 *
 * ## The case
 *
 * Device 1 adds Ravi offline and never syncs. The user signs in on Device 2,
 * which cannot see that Ravi, and adds him again. Each device minted its own
 * id, so the id check in `PartyHandler.create` lets both through.
 *
 * ## What happens instead
 *
 * The first Ravi to reach the server is inserted as usual. The second matches
 * it on name and phone (`partyKeys`) and is *not* inserted: its id is recorded
 * in `party_merge` as an alias of the first. Every later operation naming the
 * alias — the entries still queued on Device 2, an edit, a delete — resolves
 * to the surviving row, so nothing queued on either device is rejected.
 *
 * ## Whose entries stay live
 *
 * The product rule: the copy with **more entries** wins, and the other copy's
 * entries are voided with reason `merged_duplicate` (voided, not deleted — they
 * stay in the history and can be restored). A tie keeps the copy that arrived
 * first.
 *
 * Entries arrive one operation at a time, so the winner cannot be fixed at
 * merge time: Device 2's Ravi lands with no entries, then its entries follow.
 * `settle` therefore re-counts after every entry and flips the outcome when the
 * other side pulls ahead, reinstating what it voided before. The surviving id
 * never changes, so a flip moves no rows and re-keys nothing on any device.
 */
@Injectable()
export class MergeService {
  constructor(private readonly changeLog: ChangeLogService) {}

  /**
   * Serialises every write for one user from this point to commit.
   *
   * The duplicate check is a read followed by an insert. Without the lock, two
   * devices pushing Ravi at the same moment both read "no Ravi" and both
   * insert. This takes the same row lock `ChangeLogService.nextSequence` takes
   * later in the transaction, only earlier — so it adds no new lock ordering,
   * and therefore no new deadlock.
   */
  async lockUser(tx: TransactionClient, userId: string): Promise<void> {
    await tx.$queryRaw`SELECT 1 FROM app_user WHERE id = ${userId}::uuid FOR UPDATE`;
  }

  /**
   * The id a party lives under now. Follows a chain, because the cleanup
   * script can merge a surviving row into an older duplicate later on.
   */
  async resolve(
    tx: TransactionClient,
    userId: string,
    id: string,
  ): Promise<{ id: string; aliasId: string | null }> {
    let current = id;
    let aliasId: string | null = null;

    for (let hop = 0; hop < 8; hop++) {
      const merge = await tx.partyMerge.findFirst({
        where: { aliasId: current, userId },
        select: { mainId: true },
      });
      if (!merge) break;

      // The first hop is the id the client actually used, which is what
      // settle needs to tell the two devices' entries apart.
      aliasId ??= current;
      current = merge.mainId;
    }

    return { id: current, aliasId };
  }

  /** A live party with the same name and phone in the same book, oldest first. */
  findMatch(
    tx: TransactionClient,
    entity: PartyEntity,
    userId: string,
    chopdiId: string | null,
    keys: PartyKeys,
  ): Promise<PartyRow | null> {
    const where = {
      userId,
      chopdiId,
      nameKey: keys.nameKey,
      phoneKey: keys.phoneKey,
      deletedAt: null,
    };
    const orderBy = { createdAt: 'asc' as const };

    return entity === 'customer'
      ? tx.customer.findFirst({ where, orderBy })
      : tx.lender.findFirst({ where, orderBy });
  }

  /** The merge an id was already folded by, if any. */
  findByAlias(tx: TransactionClient, userId: string, aliasId: string) {
    return tx.partyMerge.findFirst({ where: { aliasId, userId } });
  }

  /**
   * Records `aliasId` as a duplicate of `main` instead of inserting it.
   *
   * Written to the change log as a `merge`, so a device that holds the alias —
   * Device 2 itself, after a reinstall, or a third device — learns where its
   * rows went on its next pull.
   */
  async merge(
    tx: TransactionClient,
    args: {
      entity: PartyEntity;
      userId: string;
      main: PartyRow;
      aliasId: string;
      alias: AliasFields;
      meta: Meta;
    },
  ): Promise<{ snapshot: EntitySnapshot; seq: bigint; mergedInto: string }> {
    const { entity, userId, main, aliasId, alias, meta } = args;

    const mainCreate = await tx.syncChangeLog.findFirst({
      where: { userId, entity, entityId: main.id, opType: 'create' },
      select: { deviceId: true },
    });

    await tx.partyMerge.create({
      data: {
        aliasId,
        userId,
        entity,
        mainId: main.id,
        mainDeviceId: mainCreate?.deviceId ?? null,
        aliasDeviceId: meta.deviceId,
        aliasSnapshot: alias as never,
        source: 'sync',
        winner: 'main',
      },
    });

    const seq = await this.changeLog.append(tx, {
      userId,
      entity,
      entityId: aliasId,
      opType: 'merge',
      snapshot: { id: aliasId, version: main.version, mergedInto: main.id },
      previous: { id: aliasId, ...alias },
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: partySnapshot(main), seq, mergedInto: main.id };
  }

  /**
   * Re-applies "more entries wins" to every live merge of `partyId`.
   *
   * Called after each entry lands on a party that has merges. Cheap when
   * nothing changes: two indexed reads per merge, no writes.
   */
  async settleParty(
    tx: TransactionClient,
    userId: string,
    partyId: string,
    meta: Meta,
  ): Promise<void> {
    const merges = await tx.partyMerge.findMany({
      where: { userId, mainId: partyId, source: 'sync' },
      orderBy: { mergedAt: 'asc' },
    });

    for (const merge of merges) {
      await this.settle(tx, merge, meta);
    }
  }

  private async settle(
    tx: TransactionClient,
    merge: {
      aliasId: string;
      userId: string;
      entity: string;
      mainId: string;
      mainDeviceId: string | null;
      aliasSnapshot: unknown;
      winner: string;
      mergedAt: Date;
    },
    meta: Meta,
  ): Promise<void> {
    const parent =
      merge.entity === 'customer'
        ? { customerId: merge.mainId }
        : { lenderId: merge.mainId };

    // Entries a user deleted themselves are out of it entirely — neither
    // counted nor touched. Ones a previous settle voided still count, so the
    // tally doesn't change just because one side is currently switched off.
    const inPlay = {
      OR: [{ voidedAt: null }, { voidedReason: MERGED_DUPLICATE }],
    };

    const aliasSide = await tx.ledgerEntry.findMany({
      where: {
        userId: merge.userId,
        ...parent,
        viaAliasId: merge.aliasId,
        AND: [inPlay],
      },
    });

    // The main copy's side: entries its own device made before it could have
    // known about the merge. The date clause catches entries made offline the
    // same day that only reach the server afterwards. Entries any *other*
    // device adds to the merged party are new business and never compete.
    const mergedDay = new Date(
      `${merge.mergedAt.toISOString().slice(0, 10)}T00:00:00.000Z`,
    );
    const mainSide = merge.mainDeviceId
      ? await tx.ledgerEntry.findMany({
          where: {
            userId: merge.userId,
            ...parent,
            viaAliasId: null,
            originDeviceId: merge.mainDeviceId,
            AND: [
              inPlay,
              {
                OR: [
                  { createdAt: { lte: merge.mergedAt } },
                  { entryDate: { lte: mergedDay } },
                ],
              },
            ],
          },
        })
      : [];

    const winner = aliasSide.length > mainSide.length ? 'alias' : 'main';
    const [keep, drop] =
      winner === 'alias' ? [aliasSide, mainSide] : [mainSide, aliasSide];

    for (const entry of drop) {
      if (entry.voidedAt) continue;

      const row = await tx.ledgerEntry.update({
        where: { id: entry.id },
        data: {
          voidedAt: new Date(),
          voidedReason: MERGED_DUPLICATE,
          version: { increment: 1 },
        },
      });

      await this.changeLog.append(tx, {
        userId: merge.userId,
        entity: 'ledger_entry',
        entityId: entry.id,
        opType: 'void',
        snapshot: ledgerEntrySnapshot(row),
        previous: ledgerEntrySnapshot(entry),
        deviceId: meta.deviceId,
        opId: meta.opId,
      });
    }

    // A flip: what an earlier settle switched off comes back.
    for (const entry of keep) {
      if (!entry.voidedAt) continue;

      const row = await tx.ledgerEntry.update({
        where: { id: entry.id },
        data: { voidedAt: null, voidedReason: null, version: { increment: 1 } },
      });

      await this.changeLog.append(tx, {
        userId: merge.userId,
        entity: 'ledger_entry',
        entityId: entry.id,
        opType: 'update',
        snapshot: ledgerEntrySnapshot(row),
        previous: ledgerEntrySnapshot(entry),
        deviceId: meta.deviceId,
        opId: meta.opId,
      });
    }

    if (winner === merge.winner) return;

    await tx.partyMerge.update({
      where: { aliasId: merge.aliasId },
      data: { winner },
    });

    if (winner === 'alias') await this.adoptAliasNotes(tx, merge, meta);
  }

  /**
   * When the duplicate wins, its notes are the ones the user was keeping — the
   * name and phone already match by definition.
   */
  private async adoptAliasNotes(
    tx: TransactionClient,
    merge: {
      userId: string;
      entity: string;
      mainId: string;
      aliasSnapshot: unknown;
    },
    meta: Meta,
  ): Promise<void> {
    const notes = (merge.aliasSnapshot as Partial<AliasFields>).notes ?? '';
    if (!notes) return;

    const where = { id: merge.mainId };
    const current =
      merge.entity === 'customer'
        ? await tx.customer.findUnique({ where })
        : await tx.lender.findUnique({ where });

    if (!current || current.deletedAt || current.notes === notes) return;

    const data = { notes, version: { increment: 1 } };
    const row =
      merge.entity === 'customer'
        ? await tx.customer.update({ where, data })
        : await tx.lender.update({ where, data });

    await this.changeLog.append(tx, {
      userId: merge.userId,
      entity: merge.entity as PartyEntity,
      entityId: merge.mainId,
      opType: 'update',
      snapshot: partySnapshot(row),
      previous: partySnapshot(current),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });
  }
}
