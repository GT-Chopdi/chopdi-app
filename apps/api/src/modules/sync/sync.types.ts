/**
 * Entities the sync protocol understands.
 *
 * `customer` is someone the user gave a loan to, `lender` someone they took one
 * from, `chopdi` the book both belong to. Kept as one list so the DTO, the
 * change log and the pull response cannot disagree about the vocabulary.
 */
export const SYNC_ENTITIES = ['chopdi', 'customer', 'lender', 'ledger_entry'] as const;

export type SyncEntity = (typeof SYNC_ENTITIES)[number];

/**
 * What a change did to a row.
 *
 * `merge` only ever comes back from a pull — a client cannot send one. It says
 * that `entityId` was a duplicate of `data.mergedInto`: the device should move
 * anything it holds under the first id to the second.
 */
export type SyncOpType = 'create' | 'update' | 'void' | 'merge';

/**
 * Outcome of one operation.
 *
 * `duplicate` is a success, not a warning: it means this exact operation was
 * already applied. That is the expected answer whenever a client retries after
 * a response went missing, which on a mobile network is routine.
 */
export type SyncResultStatus = 'applied' | 'duplicate' | 'conflict' | 'rejected';

export interface SyncOperationResult {
  opId: string;
  status: SyncResultStatus;
  entityId?: string;
  /** Version the row now holds. The client must store it to update again. */
  version?: number;
  /** Change-log position, as a string because it is a 64-bit value. */
  seq?: string;
  error?: {
    code: string;
    message: string;
    /** Whether retrying this exact operation could ever succeed. */
    permanent: boolean;
    details?: Record<string, unknown>;
  };
  /** Attached on a conflict so the client can show the user both versions. */
  serverState?: Record<string, unknown>;
  /**
   * Set when a customer or lender create matched one that already exists
   * (same name and phone, created on another device). Nothing was inserted:
   * the client should re-key its row, and everything pointing at it, to this
   * id. Operations still sent with the old id keep working regardless.
   */
  mergedInto?: string;
}

export interface SyncPushResponse {
  results: SyncOperationResult[];
  /** This user's highest change-log sequence after the batch. */
  serverCursor: string;
}

/** One change as `GET /v1/sync/pull` reports it. */
export interface SyncChange {
  /** Change-log position, as a string because it is a 64-bit value. */
  seq: string;
  entity: SyncEntity;
  entityId: string;
  opType: SyncOpType;
  /** The full row after the change — apply it, don't merge it. */
  data: Record<string, unknown>;
}

export interface SyncPullResponse {
  changes: SyncChange[];
  /** Pass back as `cursor` on the next page. Store it only once the page is applied. */
  nextCursor: string;
  /** More changes exist past `nextCursor`; request again straight away. */
  hasMore: boolean;
  /** This user's highest change-log sequence right now. */
  serverCursor: string;
}

/** A row as the server describes it back to the client. */
export interface EntitySnapshot extends Record<string, unknown> {
  id: string;
  version: number;
}

// ------------------------------------------------------------- pull v2 (tree)
//
// `GET /v2/sync/pull`: the same pages as v1, nested by book for the app. Key
// order in these interfaces is the order on the wire — PullTreeBuilder builds
// each object in it — and is part of the contract shared with the Flutter app.
// A record absent from a page means "unchanged"; a deleted one is present with
// `deletedAt` / `voidedAt` set.

/** One movement of money. Its party, and so its book, is whatever it is nested under. */
export interface PullTreeEntry {
  id: string;
  /** Paise, as a string: 64-bit. */
  amountPaise: string;
  direction: string;
  interestRateBp: number;
  interestType: string;
  interestFrequency: string;
  /** YYYY-MM-DD */
  entryDate: string;
  description: string;
  paymentMode: string;
  version: number;
  createdAt: string;
  updatedAt: string;
  voidedAt: string | null;
  voidedReason: string | null;
}

/** A customer (entries are I Gave) or a lender (entries are I Took). */
export interface PullTreeParty {
  id: string;
  name: string;
  phone: string | null;
  notes: string;
  version: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
  /** Earlier ids of this same person, merged into it. Re-key them to `id`. */
  mergedIds: string[];
  entries: PullTreeEntry[];
}

export interface PullTreeChopdi {
  id: string;
  name: string;
  description: string;
  isDefault: boolean;
  version: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
  customers: PullTreeParty[];
  lenders: PullTreeParty[];
}

export interface SyncPullTreeResponse {
  nextCursor: string;
  hasMore: boolean;
  serverCursor: string;
  chopdis: PullTreeChopdi[];
  /** Parties synced before books were; the app files them in its default book. */
  unassigned: {
    customers: PullTreeParty[];
    lenders: PullTreeParty[];
  };
}
