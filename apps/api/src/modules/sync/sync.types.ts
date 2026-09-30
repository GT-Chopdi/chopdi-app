/**
 * Entities the sync protocol understands.
 *
 * `customer` is someone the user gave a loan to, `lender` someone they took one
 * from, `chopdi` the book both belong to. Kept as one list so the DTO, the
 * change log and the pull response cannot disagree about the vocabulary.
 */
export const SYNC_ENTITIES = ['chopdi', 'customer', 'lender', 'ledger_entry'] as const;

export type SyncEntity = (typeof SYNC_ENTITIES)[number];

/** What an operation does to a row. */
export type SyncOpType = 'create' | 'update' | 'void';

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
