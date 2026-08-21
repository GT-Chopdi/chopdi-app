import { createHash } from 'node:crypto';

import { Injectable } from '@nestjs/common';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import type { TransactionClient } from './change-log.service';
import type { SyncOperationResult } from './sync.types';

/** A previously recorded outcome, replayed instead of re-applied. */
export interface RecordedResult {
  result: SyncOperationResult;
}

/**
 * Makes an operation apply at most once, however many times it is sent.
 *
 * ## The failure this exists for
 *
 * A client pushes an operation, the server commits it, and the response is lost
 * — a tunnel, a lift, a dropped handover. The client sees a timeout and cannot
 * tell that apart from "it never arrived". Retry and the user's ₹5,000 loan is
 * recorded twice; do not retry and it is lost. The information needed to decide
 * simply is not on the device.
 *
 * So the client always retries, with the same key, and the server recognises it.
 *
 * ## Why this lives in Postgres and not Redis
 *
 * The claim is written in the **same transaction** as the mutation. The
 * guarantee required is "recorded if and only if the row was written", and only
 * a shared transaction provides it. With a separate store, a crash between the
 * two writes could record the key without the row — and the retry would then be
 * told "already applied" for an entry that does not exist. Silent data loss,
 * undetectable from either side. Redis is faster and wrong.
 */
@Injectable()
export class IdempotencyService {
  /**
   * Canonical hash of the payload.
   *
   * Keys are sorted so `{a:1,b:2}` and `{b:2,a:1}` hash alike — otherwise a
   * client that serialised its map in a different order would look like an
   * attacker splicing a new payload onto a known-good key.
   */
  fingerprint(payload: unknown): string {
    return createHash('sha256').update(this.canonicalise(payload)).digest('hex');
  }

  private canonicalise(value: unknown): string {
    if (value === null || typeof value !== 'object') return JSON.stringify(value);

    if (Array.isArray(value)) {
      return `[${value.map((v) => this.canonicalise(v)).join(',')}]`;
    }

    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
      .map(([k, v]) => `${JSON.stringify(k)}:${this.canonicalise(v)}`);

    return `{${entries.join(',')}}`;
  }

  /**
   * Looks up a previous outcome for this key.
   *
   * A matching payload replays the stored response. A *different* payload under
   * the same key is refused: that is either a client bug reusing keys, or an
   * attacker splicing a new amount onto a request the server already trusts.
   * Applying it would let one key authorise two different writes.
   */
  async findRecorded(
    tx: TransactionClient,
    userId: string,
    opId: string,
    payloadHash: string,
  ): Promise<RecordedResult | null> {
    const existing = await tx.syncOperation.findUnique({
      where: { userId_opId: { userId, opId } },
      select: { payloadHash: true, resultBody: true },
    });

    if (!existing) return null;

    if (existing.payloadHash !== payloadHash) {
      throw new AppException(
        409,
        ErrorCode.IDEMPOTENCY_KEY_REUSE,
        'This operation id was already used with different content.',
        true,
        { opId },
      );
    }

    return { result: existing.resultBody as unknown as SyncOperationResult };
  }

  /**
   * Records the outcome, in the caller's transaction.
   *
   * The unique index is on `(userId, opId)` — scoped per user, never global. A
   * global key space would let anyone who learns a victim's opId submit it
   * first and silently swallow the victim's real operation, and would leak
   * whether a given key exists at all.
   */
  async record(
    tx: TransactionClient,
    params: {
      userId: string;
      opId: string;
      deviceId: string;
      entity: string;
      entityId: string;
      opType: string;
      payloadHash: string;
      result: SyncOperationResult;
    },
  ): Promise<void> {
    await tx.syncOperation.create({
      data: {
        userId: params.userId,
        opId: params.opId,
        deviceId: params.deviceId,
        entity: params.entity,
        entityId: params.entityId,
        opType: params.opType,
        payloadHash: params.payloadHash,
        resultStatus: params.result.status,
        resultBody: params.result as unknown as object,
      },
      select: { id: true },
    });
  }
}
