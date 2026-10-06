import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { AppException, ErrorCode } from '../../common/errors/app.exception';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PullQueryDto } from './dto/pull.dto';
import {
  SYNC_ENTITIES,
  type SyncChange,
  type SyncEntity,
  type SyncOpType,
  type SyncPullResponse,
} from './sync.types';

const MAX_BIGINT = 9_223_372_036_854_775_807n;
const DEFAULT_LIMIT = 200;

/** Change-log op types a client applies. `conflict` rows are forensics only. */
const PULLABLE_OPS: SyncOpType[] = ['create', 'update', 'void', 'merge'];

/**
 * Serves a user's data back to their devices.
 *
 * ## One endpoint for first sign-in and for catching up
 *
 * A device signing in with an empty database pulls from cursor 0 and receives
 * every change the account has ever made, oldest first; a device that is
 * merely behind pulls from where it stopped. There is no separate "snapshot"
 * endpoint to keep consistent with this one.
 *
 * ## Why the change log, and why by `seq`
 *
 * `seq` is assigned under a per-user row lock held until commit (see
 * {@link ChangeLogService}), so the rows visible at any moment are always a
 * contiguous prefix of the sequence. Paging by `seq > cursor` therefore cannot
 * skip a change that commits late — which paging by timestamp, or by the
 * table's own BIGSERIAL, can.
 *
 * Every change carries the full row after it, so a client applies a change by
 * replacing its copy, in order. Parents are always logged before the rows
 * that reference them, so applying in `seq` order never meets an entry whose
 * customer has not arrived yet.
 */
@Injectable()
export class PullService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async pull(
    user: AuthenticatedUser,
    query: PullQueryDto,
  ): Promise<SyncPullResponse> {
    const cursor = this.parseCursor(query.cursor);
    const limit = this.effectiveLimit(query.limit);

    const account = await this.prisma.appUser.findUnique({
      where: { id: user.userId },
      select: { changeSeq: true },
    });

    // The guard already confirmed the user and device. An account vanishing
    // between the two reads is not something a client can recover from by
    // retrying differently, so it is reported as a plain not-found.
    if (!account) {
      throw new AppException(
        404,
        ErrorCode.NOT_FOUND,
        'Account not found.',
        true,
      );
    }

    if (cursor > account.changeSeq) {
      // A cursor from the future means the device's sync state came from
      // somewhere else — another account on this phone, a restored backup, a
      // different database. Answering "nothing new" would leave the user
      // looking at data that is not theirs, or missing their own for good.
      throw new AppException(
        409,
        ErrorCode.CURSOR_AHEAD,
        'This device is ahead of the server. Reset sync and pull again from the start.',
        true,
        {
          cursor: cursor.toString(),
          serverCursor: account.changeSeq.toString(),
        },
      );
    }

    // One extra row answers "is there more?" without a second query.
    const rows = await this.prisma.syncChangeLog.findMany({
      where: {
        userId: user.userId,
        seq: { gt: cursor },
        opType: { in: PULLABLE_OPS },
      },
      orderBy: { seq: 'asc' },
      take: limit + 1,
      select: {
        seq: true,
        entity: true,
        entityId: true,
        opType: true,
        snapshot: true,
      },
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    const changes: SyncChange[] = page
      // Defensive: the DB CHECK already limits entity, but an unknown value
      // must not reach an installed app that would choke on it.
      .filter((r) => (SYNC_ENTITIES as readonly string[]).includes(r.entity))
      .map((r) => ({
        seq: r.seq.toString(),
        entity: r.entity as SyncEntity,
        entityId: r.entityId,
        opType: r.opType as SyncOpType,
        data: r.snapshot as Record<string, unknown>,
      }));

    // Advance past everything examined, including any row filtered out above,
    // so a skipped row cannot pin the cursor and loop the client forever.
    const nextCursor = page.length > 0 ? page[page.length - 1].seq : cursor;

    // Writes can commit between the two reads; never report a server cursor
    // behind the page just returned.
    const serverCursor =
      account.changeSeq > nextCursor ? account.changeSeq : nextCursor;

    return {
      changes,
      nextCursor: nextCursor.toString(),
      hasMore,
      serverCursor: serverCursor.toString(),
    };
  }

  private parseCursor(value: string | undefined): bigint {
    if (value === undefined) return 0n;

    const cursor = BigInt(value);

    // The DTO bounds the digit count; this bounds the value to what the
    // BIGINT column can hold, so a 19-digit cursor above 2^63 is a 400 rather
    // than a database error.
    if (cursor > MAX_BIGINT) {
      throw new AppException(
        400,
        ErrorCode.VALIDATION_FAILED,
        'cursor is out of range.',
        true,
        {
          field: 'cursor',
        },
      );
    }

    return cursor;
  }

  private effectiveLimit(requested: number | undefined): number {
    const cap = this.config.get<number>('sync.maxPullLimit') ?? 500;
    const safeCap = Number.isInteger(cap) && cap > 0 ? cap : 500;
    return Math.min(requested ?? DEFAULT_LIMIT, safeCap);
  }
}
