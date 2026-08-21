import { Injectable } from '@nestjs/common';

import type { PrismaClient } from '../../generated/prisma/client';

/**
 * A Prisma client scoped to an open transaction.
 *
 * Every method here demands one. Assigning a sequence outside the transaction
 * that performs the mutation would release the row lock early and destroy the
 * ordering guarantee described below — so the type makes that mistake hard.
 */
export type TransactionClient = Omit<
  PrismaClient,
  '$connect' | '$disconnect' | '$on' | '$use' | '$extends'
>;

export interface ChangeLogEntry {
  userId: string;
  entity: 'customer' | 'ledger_entry';
  entityId: string;
  opType: 'create' | 'update' | 'void' | 'conflict';
  /** The row as it stands after the change. */
  snapshot: unknown;
  /** The row before it. Required for anything that is not a create. */
  previous?: unknown;
  deviceId?: string;
  opId?: string;
}

/**
 * Owns the per-user change sequence and the append-only audit log.
 *
 * ## Why the sequence is assigned this way
 *
 * A pull cursor must never skip a row. Two obvious designs both do:
 *
 * - **`updated_at > cursor`** — `now()` in Postgres is *transaction start*
 *   time, but rows become visible at *commit*. A transaction that starts early
 *   and commits late is stamped with an old timestamp, so a client that already
 *   read past that timestamp never sees it. The row is lost silently, forever.
 *
 * - **A plain `BIGSERIAL`** — has exactly the same flaw for the same reason:
 *   sequence values are allocated at insert time, not commit time. This is the
 *   trap most designs fall into *after* correctly rejecting timestamps.
 *
 * The fix is not a different column type, it is a lock. `UPDATE app_user SET
 * change_seq = change_seq + 1 ... RETURNING` takes a row-exclusive lock held
 * until commit, so two writers for one user serialise: the second blocks, gets
 * a higher number, and commits later. Sequence order and commit order become
 * the same order, which is precisely what a cursor needs.
 *
 * The cost is that one user's writes serialise here — a ceiling of a few
 * hundred operations per second per user, against a workload of tens per day.
 * Different users take different locks, so nothing about this limits scale.
 *
 * ## Never parallelise operations for one user
 *
 * Because every write for a user contends for the same row lock, running a
 * batch with `Promise.all` buys no throughput at all — the work still happens
 * one at a time — while each queued transaction holds a connection open while
 * it waits. Against Neon's pooled endpoint that exhausts the pool and fails
 * with `P2028: Unable to start a transaction in the given time`, which looks
 * like a database fault rather than the self-inflicted contention it is.
 *
 * Verified in test/verify-change-log.mjs: 20 concurrent appends for one user
 * fail this way, five succeed, and three *different* users proceed in parallel
 * without contending. Apply a push batch sequentially.
 */
@Injectable()
export class ChangeLogService {
  /**
   * Reserves the next sequence number for a user.
   *
   * **Must** be called with the same transaction as the mutation it describes.
   * The lock this takes is only useful while that transaction is open.
   */
  async nextSequence(tx: TransactionClient, userId: string): Promise<bigint> {
    const rows = await tx.$queryRaw<{ change_seq: bigint }[]>`
      UPDATE app_user
         SET change_seq = change_seq + 1
       WHERE id = ${userId}::uuid
      RETURNING change_seq
    `;

    if (rows.length === 0) {
      // The user was deleted mid-transaction, or the id is not one of ours.
      // Either way this must abort rather than write an orphaned log row.
      throw new Error(`Cannot assign a change sequence: unknown user ${userId}`);
    }

    return rows[0].change_seq;
  }

  /**
   * Appends one audit record and returns its sequence.
   *
   * Written in the caller's transaction so a change can never commit without
   * its audit row, and the audit row can never exist without the change.
   */
  async append(tx: TransactionClient, entry: ChangeLogEntry): Promise<bigint> {
    if (entry.opType !== 'create' && entry.previous === undefined) {
      // Also enforced by a CHECK constraint; caught here so the failure names
      // the caller rather than surfacing as a constraint violation.
      throw new Error(
        `A '${entry.opType}' change-log entry must carry its previous state`,
      );
    }

    const seq = await this.nextSequence(tx, entry.userId);

    await tx.syncChangeLog.create({
      data: {
        userId: entry.userId,
        seq,
        entity: entry.entity,
        entityId: entry.entityId,
        opType: entry.opType,
        snapshot: entry.snapshot as never,
        previous: (entry.previous ?? null) as never,
        deviceId: entry.deviceId ?? null,
        opId: entry.opId ?? null,
      },
      select: { id: true },
    });

    return seq;
  }
}
