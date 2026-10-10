import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import type { ChopdiRow } from './handlers/chopdi.handler';
import type { LedgerEntryRow } from './handlers/ledger-entry.snapshot';
import type { PartyRow } from './handlers/party.handler';
import { buildPullTree, type PullTreeInput } from './pull-tree.builder';
import type {
  PullTreeEntry,
  PullTreeParty,
  SyncPullTreeResponse,
} from './sync.types';

/**
 * The response agreed with the Flutter app: three books, the first two with
 * one customer and one lender each, the third with a customer only. The
 * builder must reproduce it byte for byte — key order included — because the
 * app was written against this exact text.
 */
const FIXTURE = readFileSync(
  join(__dirname, '__fixtures__', 'pull-v2-three-books.json'),
  'utf8',
);

const USER = '01a00000-0000-7000-8000-0000000000aa';
const date = (iso: string | null) => (iso ? new Date(iso) : null);

function entryRow(
  e: PullTreeEntry,
  parent: { customerId: string | null; lenderId: string | null },
): LedgerEntryRow {
  return {
    id: e.id,
    ...parent,
    amountPaise: BigInt(e.amountPaise),
    direction: e.direction,
    ledgerSide: parent.customerId ? 'lent' : 'borrowed',
    interestRateBp: e.interestRateBp,
    interestType: e.interestType,
    interestFrequency: e.interestFrequency,
    entryDate: new Date(`${e.entryDate}T00:00:00.000Z`),
    description: e.description,
    paymentMode: e.paymentMode,
    version: e.version,
    createdAt: new Date(e.createdAt),
    updatedAt: new Date(e.updatedAt),
    voidedAt: date(e.voidedAt),
    voidedReason: e.voidedReason,
  };
}

function partyRow(p: PullTreeParty, chopdiId: string | null): PartyRow {
  return {
    id: p.id,
    userId: USER,
    chopdiId,
    name: p.name,
    phoneE164: p.phone,
    notes: p.notes,
    version: p.version,
    createdAt: new Date(p.createdAt),
    updatedAt: new Date(p.updatedAt),
    deletedAt: date(p.deletedAt),
  };
}

/** The table rows the fixture describes, as the service would load them. */
function rowsOf(tree: SyncPullTreeResponse): PullTreeInput {
  const input: PullTreeInput = {
    nextCursor: BigInt(tree.nextCursor),
    hasMore: tree.hasMore,
    serverCursor: BigInt(tree.serverCursor),
    chopdis: [],
    customers: [],
    lenders: [],
    entries: [],
    mergedIds: new Map(),
  };

  const addParties = (
    parties: PullTreeParty[],
    side: 'customers' | 'lenders',
    chopdiId: string | null,
  ) => {
    for (const p of parties) {
      input[side].push(partyRow(p, chopdiId));
      if (p.mergedIds.length) input.mergedIds.set(p.id, p.mergedIds);
      for (const e of p.entries) {
        input.entries.push(
          entryRow(
            e,
            side === 'customers'
              ? { customerId: p.id, lenderId: null }
              : { customerId: null, lenderId: p.id },
          ),
        );
      }
    }
  };

  for (const c of tree.chopdis) {
    const row: ChopdiRow = {
      id: c.id,
      name: c.name,
      description: c.description,
      isDefault: c.isDefault,
      version: c.version,
      createdAt: new Date(c.createdAt),
      updatedAt: new Date(c.updatedAt),
      deletedAt: date(c.deletedAt),
    };
    input.chopdis.push(row);
    addParties(c.customers, 'customers', c.id);
    addParties(c.lenders, 'lenders', c.id);
  }
  addParties(tree.unassigned.customers, 'customers', null);
  addParties(tree.unassigned.lenders, 'lenders', null);

  return input;
}

/** Rows arrive from the database in no particular order. */
function shuffled(input: PullTreeInput): PullTreeInput {
  return {
    ...input,
    chopdis: [...input.chopdis].reverse(),
    customers: [...input.customers].reverse(),
    lenders: [...input.lenders].reverse(),
    entries: [...input.entries].reverse(),
  };
}

describe('buildPullTree', () => {
  const agreed = JSON.parse(FIXTURE) as SyncPullTreeResponse;

  it('reproduces the response agreed with the app, byte for byte', () => {
    const built = buildPullTree(shuffled(rowsOf(agreed)));
    expect(`${JSON.stringify(built, null, 2)}\n`).toBe(FIXTURE);
  });

  it('nests each party and entry under its own book only', () => {
    const built = buildPullTree(rowsOf(agreed));
    const [mine, teat, harsh] = built.chopdis;

    expect(built.chopdis.map((c) => c.name)).toEqual([
      'My Chopdi',
      'Teat',
      'Harsh',
    ]);
    expect(mine.customers.map((p) => p.name)).toEqual(['Ravi Kumar']);
    expect(teat.lenders.map((p) => p.name)).toEqual(['Mahesh Gupta']);
    expect(harsh.customers.map((p) => p.name)).toEqual(['Neha Verma']);
    expect(harsh.lenders).toEqual([]);
    expect(mine.customers[0].entries.map((e) => e.direction)).toEqual(['gave']);
    expect(mine.lenders[0].entries.map((e) => e.direction)).toEqual([
      'received',
    ]);
  });

  it('puts parties without a book in unassigned', () => {
    const input = rowsOf(agreed);
    input.customers[0].chopdiId = null;

    const built = buildPullTree(input);

    expect(built.unassigned.customers.map((p) => p.name)).toEqual([
      'Ravi Kumar',
    ]);
    expect(built.unassigned.customers[0].entries).toHaveLength(1);
    expect(built.chopdis[0].customers).toEqual([]);
  });

  it('returns deleted records in place, marked deleted', () => {
    const input = rowsOf(agreed);
    input.customers[0].deletedAt = new Date('2026-10-09T11:00:00.000Z');
    input.entries[0].voidedAt = new Date('2026-10-09T11:00:00.000Z');
    input.entries[0].voidedReason = 'Party deleted';

    const ravi = buildPullTree(input).chopdis[0].customers[0];

    expect(ravi.deletedAt).toBe('2026-10-09T11:00:00.000Z');
    expect(ravi.entries[0].voidedAt).toBe('2026-10-09T11:00:00.000Z');
    expect(ravi.entries[0].voidedReason).toBe('Party deleted');
  });

  it('lists merged ids on the surviving party', () => {
    const input = rowsOf(agreed);
    const ravi = input.customers[0].id;
    input.mergedIds.set(ravi, ['01a12177-0c3d-7e55-9a01-7b2c4d6e8f90']);

    const built = buildPullTree(input);

    expect(built.chopdis[0].customers[0].mergedIds).toEqual([
      '01a12177-0c3d-7e55-9a01-7b2c4d6e8f90',
    ]);
    expect(built.chopdis[1].customers[0].mergedIds).toEqual([]);
  });

  it('carries the 64-bit fields as strings', () => {
    const input = rowsOf(agreed);
    input.entries[0].amountPaise = 9_007_199_254_740_993n; // 2^53 + 1
    input.nextCursor = 9_007_199_254_740_993n;

    const built = buildPullTree(input);

    expect(built.nextCursor).toBe('9007199254740993');
    expect(
      built.chopdis
        .flatMap((c) => c.customers)
        .flatMap((p) => p.entries)
        .some((e) => e.amountPaise === '9007199254740993'),
    ).toBe(true);
  });

  it('answers an empty page with the full empty shape', () => {
    const built = buildPullTree({
      nextCursor: 12n,
      hasMore: false,
      serverCursor: 12n,
      chopdis: [],
      customers: [],
      lenders: [],
      entries: [],
      mergedIds: new Map(),
    });

    expect(built).toEqual({
      nextCursor: '12',
      hasMore: false,
      serverCursor: '12',
      chopdis: [],
      unassigned: { customers: [], lenders: [] },
    });
  });
});
