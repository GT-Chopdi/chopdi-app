/** Entities the sync protocol understands. */
export type SyncEntity = 'customer' | 'ledger_entry';

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

/** A row as the server describes it back to the client. */
export interface EntitySnapshot extends Record<string, unknown> {
  id: string;
  version: number;
}
