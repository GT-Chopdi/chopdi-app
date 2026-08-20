import { registerAs } from '@nestjs/config';

/**
 * Synchronisation configuration namespace.
 *
 * These are the limits that bound a single request. They exist to stop a
 * buggy or hostile client from submitting an unbounded batch or paging an
 * unbounded pull; see the sync R&D document, §12.9.
 */
export const syncConfig = registerAs('sync', () => ({
  /** Maximum operations accepted in one `POST /sync/push`. */
  maxBatchSize: parseInt(process.env.SYNC_MAX_BATCH_SIZE ?? '200', 10),

  /** Hard ceiling on `GET /sync/pull?limit=` regardless of what is requested. */
  maxPullLimit: parseInt(process.env.SYNC_MAX_PULL_LIMIT ?? '500', 10),

  /**
   * JSON body limit. Set explicitly because the framework default (100 KB) is
   * too small for a full 200-operation batch — relying on it would reject
   * legitimate pushes.
   */
  bodyLimit: process.env.SYNC_BODY_LIMIT ?? '1mb',
}));
