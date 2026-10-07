import { Injectable } from '@nestjs/common';

import {
  ChangeLogService,
  type TransactionClient,
} from '../change-log.service';
import { MergeService } from '../merge.service';
import { partyKeys } from '../party-keys';
import { ledgerEntrySnapshot } from './ledger-entry.handler';
import {
  PartyHandler,
  partySnapshot,
  type Applied,
  type Meta,
  type PartyDelegate,
} from './party.handler';

/** Applies operations for lenders — people the user took a loan from. */
@Injectable()
export class LenderHandler extends PartyHandler {
  constructor(changeLog: ChangeLogService, merges: MergeService) {
    super(changeLog, merges);
  }

  protected readonly entity = 'lender' as const;
  protected readonly label = 'lender';

  protected table(tx: TransactionClient): PartyDelegate {
    return tx.lender;
  }

  /**
   * Converts a legacy customer into a lender, keeping its id.
   *
   * Before lenders had their own table, the app stored them as customers and
   * synced them that way. When the app moves such a row into its lender table
   * it sends `lender/create` with the **same** id; this moves the server copy
   * across in one transaction instead of leaving a duplicate customer:
   *
   *   1. insert the lender;
   *   2. re-point that customer's entries to it;
   *   3. soft-delete the customer.
   *
   * Each step is written to the change log, so another device pulling later
   * sees the move rather than a lender appearing from nowhere.
   */
  protected override async adopt(
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
  ): Promise<Applied | null> {
    const legacy = await tx.customer.findFirst({
      where: { id: entityId, userId },
    });
    if (!legacy || legacy.deletedAt) return null;

    const lender = await tx.lender.create({
      data: {
        id: entityId,
        userId,
        chopdiId: fields.chopdiId ?? legacy.chopdiId,
        name: fields.name,
        phoneE164: fields.phone,
        notes: fields.notes,
        ...partyKeys(fields.name, fields.phone),
      },
    });

    await this.changeLog.append(tx, {
      userId,
      entity: 'lender',
      entityId,
      opType: 'create',
      snapshot: partySnapshot(lender),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    const entries = await tx.ledgerEntry.findMany({
      where: { customerId: entityId, userId },
      orderBy: { createdAt: 'asc' },
    });

    for (const entry of entries) {
      const moved = await tx.ledgerEntry.update({
        where: { id: entry.id },
        data: {
          customerId: null,
          lenderId: entityId,
          version: { increment: 1 },
        },
      });

      await this.changeLog.append(tx, {
        userId,
        entity: 'ledger_entry',
        entityId: entry.id,
        opType: 'update',
        snapshot: ledgerEntrySnapshot(moved),
        previous: ledgerEntrySnapshot(entry),
        deviceId: meta.deviceId,
        opId: meta.opId,
      });
    }

    const retired = await tx.customer.update({
      where: { id: entityId },
      data: { deletedAt: new Date(), version: { increment: 1 } },
    });

    // The result carries the last sequence of the move, so a pull from it
    // starts after the whole conversion rather than halfway through.
    const seq = await this.changeLog.append(tx, {
      userId,
      entity: 'customer',
      entityId,
      opType: 'void',
      snapshot: partySnapshot(retired),
      previous: partySnapshot(legacy),
      deviceId: meta.deviceId,
      opId: meta.opId,
    });

    return { snapshot: partySnapshot(lender), seq };
  }
}
