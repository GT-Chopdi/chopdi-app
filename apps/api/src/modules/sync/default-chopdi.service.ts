import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../common/prisma/prisma.service';
import { uuidv7 } from '../../common/utils/uuid';
import { ChangeLogService } from './change-log.service';
import { chopdiSnapshot, DEFAULT_CHOPDI } from './handlers/chopdi.handler';
import { MergeService } from './merge.service';

/**
 * Makes sure a user has their default book ("My Chopdi").
 *
 * ## Why the server creates it
 *
 * If the app created it, every device that signed in before syncing would make
 * its own — two "My Chopdi" books with different ids, both claiming to be the
 * default. Created here, there is exactly one, and its id reaches the app in
 * the sign-in response before the app has written anything.
 *
 * Users that existed before this service get theirs from the
 * default_chopdi_and_index_cleanup migration; this covers everyone after, and
 * anyone whose default was later deleted.
 */
@Injectable()
export class DefaultChopdiService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly changeLog: ChangeLogService,
    private readonly merges: MergeService,
  ) {}

  /** Returns the id of the user's live default book, creating it if needed. */
  async ensure(userId: string, deviceId: string): Promise<string> {
    // Fast path, outside a transaction: true for every sign-in but the first.
    const existing = await this.findLive(this.prisma, userId);
    if (existing) return existing.id;

    return this.prisma.$transaction(async (tx) => {
      // Two sign-ins at once both miss the fast path. The user lock makes the
      // second wait, then find the first one's book instead of making another.
      // The partial unique index is the backstop for any other write path.
      await this.merges.lockUser(tx, userId);

      const raced = await this.findLive(tx, userId);
      if (raced) return raced.id;

      // Millisecond precision, so the row and its logged snapshot agree.
      const now = new Date();
      const row = await tx.chopdi.create({
        data: {
          id: uuidv7(),
          userId,
          name: DEFAULT_CHOPDI.name,
          description: DEFAULT_CHOPDI.description,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        },
      });

      await this.changeLog.append(tx, {
        userId,
        entity: 'chopdi',
        entityId: row.id,
        opType: 'create',
        snapshot: chopdiSnapshot(row),
        deviceId,
      });

      return row.id;
    });
  }

  private findLive(
    client: Pick<PrismaService, 'chopdi'>,
    userId: string,
  ): Promise<{ id: string } | null> {
    return client.chopdi.findFirst({
      where: { userId, isDefault: true, deletedAt: null },
      select: { id: true },
    });
  }
}
