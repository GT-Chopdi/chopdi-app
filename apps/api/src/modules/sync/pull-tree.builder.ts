import type { ChopdiRow } from './handlers/chopdi.handler';
import type { LedgerEntryRow } from './handlers/ledger-entry.snapshot';
import type { PartyRow } from './handlers/party.handler';
import type {
  PullTreeChopdi,
  PullTreeEntry,
  PullTreeParty,
  SyncPullTreeResponse,
} from './sync.types';

/** Everything one v2 page needs, already loaded and scoped to the user. */
export interface PullTreeInput {
  nextCursor: bigint;
  hasMore: boolean;
  serverCursor: bigint;
  chopdis: ChopdiRow[];
  customers: PartyRow[];
  lenders: PartyRow[];
  entries: LedgerEntryRow[];
  /** Party id → ids merged into it, transitively. */
  mergedIds: Map<string, string[]>;
}

/**
 * Nests one page of rows into the v2 shape: books → customers / lenders →
 * entries.
 *
 * Pure, so the exact wire format can be tested against the JSON agreed with
 * the app without a database. Every object is built literally, in the key
 * order of the interfaces in sync.types.ts, and every list is sorted oldest
 * first (`createdAt`, then `id` so ties are stable across pages).
 */
export function buildPullTree(input: PullTreeInput): SyncPullTreeResponse {
  const customers = new Map(
    input.customers.map((p) => [p.id, toParty(p, input.mergedIds)]),
  );
  const lenders = new Map(
    input.lenders.map((p) => [p.id, toParty(p, input.mergedIds)]),
  );

  for (const entry of sortRows(input.entries)) {
    // Every entry's party is loaded with the page. One missing would be a row
    // of another user's, which the scoped queries exclude — so drop it rather
    // than invent a parent.
    const parent = entry.customerId
      ? customers.get(entry.customerId)
      : entry.lenderId
        ? lenders.get(entry.lenderId)
        : undefined;
    parent?.entries.push(toEntry(entry));
  }

  const chopdis = new Map(input.chopdis.map((c) => [c.id, toChopdi(c)]));
  const unassigned = {
    customers: [] as PullTreeParty[],
    lenders: [] as PullTreeParty[],
  };

  const place = (
    rows: PartyRow[],
    index: Map<string, PullTreeParty>,
    side: 'customers' | 'lenders',
  ) => {
    for (const row of sortRows(rows)) {
      const party = index.get(row.id)!;
      const book = row.chopdiId ? chopdis.get(row.chopdiId) : undefined;
      (book ? book[side] : unassigned[side]).push(party);
    }
  };

  place(input.customers, customers, 'customers');
  place(input.lenders, lenders, 'lenders');

  return {
    nextCursor: input.nextCursor.toString(),
    hasMore: input.hasMore,
    serverCursor: input.serverCursor.toString(),
    chopdis: sortRows(input.chopdis).map((c) => chopdis.get(c.id)!),
    unassigned,
  };
}

function sortRows<T extends { id: string; createdAt: Date }>(rows: T[]): T[] {
  return [...rows].sort(
    (a, b) =>
      a.createdAt.getTime() - b.createdAt.getTime() ||
      (a.id < b.id ? -1 : a.id > b.id ? 1 : 0),
  );
}

function iso(value: Date | null): string | null {
  return value ? value.toISOString() : null;
}

function toChopdi(row: ChopdiRow): PullTreeChopdi {
  return {
    id: row.id,
    name: row.name,
    description: row.description,
    isDefault: row.isDefault,
    version: row.version,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    deletedAt: iso(row.deletedAt),
    customers: [],
    lenders: [],
  };
}

function toParty(
  row: PartyRow,
  mergedIds: Map<string, string[]>,
): PullTreeParty {
  return {
    id: row.id,
    name: row.name,
    phone: row.phoneE164,
    notes: row.notes,
    version: row.version,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    deletedAt: iso(row.deletedAt),
    mergedIds: mergedIds.get(row.id) ?? [],
    entries: [],
  };
}

function toEntry(row: LedgerEntryRow): PullTreeEntry {
  return {
    id: row.id,
    amountPaise: row.amountPaise.toString(),
    direction: row.direction,
    interestRateBp: row.interestRateBp,
    interestType: row.interestType,
    interestFrequency: row.interestFrequency,
    entryDate: row.entryDate.toISOString().slice(0, 10),
    description: row.description,
    paymentMode: row.paymentMode,
    version: row.version,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    voidedAt: iso(row.voidedAt),
    voidedReason: row.voidedReason,
  };
}
