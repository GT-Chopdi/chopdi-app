import type { EntitySnapshot } from '../sync.types';

export interface LedgerEntryRow {
  id: string;
  customerId: string | null;
  lenderId: string | null;
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
}

/** An entry as the server describes it back — in push results, the log and pulls. */
export function ledgerEntrySnapshot(row: LedgerEntryRow): EntitySnapshot {
  return {
    id: row.id,
    customerId: row.customerId,
    lenderId: row.lenderId,
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
