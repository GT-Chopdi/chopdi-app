import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PullQueryDto } from './dto/pull.dto';
import { buildPullTree } from './pull-tree.builder';
import { PullService } from './pull.service';
import type { SyncPullTreeResponse } from './sync.types';

/** Bound on merge chains followed, matching MergeService.resolve. */
const MAX_MERGE_HOPS = 8;

/**
 * Serves `GET /v2/sync/pull`: v1's pages, nested by book.
 *
 * ## Same pages as v1
 *
 * The change-log page, its cursors and its validation come from
 * {@link PullService.readPage}, so the two versions can never disagree about
 * what a cursor means. A device can move from v1 to v2 keeping its cursor.
 *
 * ## Current rows, not logged snapshots
 *
 * The page says *which* records changed; their state is read from the tables
 * now. That is what lets an entry be nested under the right parent even when
 * it moved (a legacy customer converted to a lender re-points its entries),
 * and it costs nothing in correctness: state only moves forward, and the app
 * skips anything whose `version` it already has.
 *
 * ## Parents come along
 *
 * A page can hold an entry whose customer and book did not change. The nested
 * shape still needs them to hang the entry under, so they are included as
 * they stand. The app recognises them by `version` and leaves them alone.
 *
 * Five queries per page beyond the change-log read, whatever its size.
 */
@Injectable()
export class PullTreeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pulls: PullService,
  ) {}

  async pull(
    user: AuthenticatedUser,
    query: PullQueryDto,
  ): Promise<SyncPullTreeResponse> {
    const page = await this.pulls.readPage(user, query);
    const userId = user.userId;

    const chopdiIds = new Set<string>();
    const customerIds = new Set<string>();
    const lenderIds = new Set<string>();
    const entryIds = new Set<string>();

    for (const row of page.rows) {
      // A merge row names the duplicate's id, which is no row of its own; the
      // survivor is what changed — it gained a mergedIds entry.
      const id =
        row.opType === 'merge'
          ? ((row.snapshot as { mergedInto?: string }).mergedInto ??
            row.entityId)
          : row.entityId;

      if (row.entity === 'chopdi') chopdiIds.add(id);
      else if (row.entity === 'customer') customerIds.add(id);
      else if (row.entity === 'lender') lenderIds.add(id);
      else if (row.entity === 'ledger_entry') entryIds.add(id);
    }

    const entries = entryIds.size
      ? await this.prisma.ledgerEntry.findMany({
          where: { userId, id: { in: [...entryIds] } },
        })
      : [];

    for (const entry of entries) {
      if (entry.customerId) customerIds.add(entry.customerId);
      if (entry.lenderId) lenderIds.add(entry.lenderId);
    }

    const [customers, lenders] = await Promise.all([
      customerIds.size
        ? this.prisma.customer.findMany({
            where: { userId, id: { in: [...customerIds] } },
          })
        : [],
      lenderIds.size
        ? this.prisma.lender.findMany({
            where: { userId, id: { in: [...lenderIds] } },
          })
        : [],
    ]);

    for (const party of [...customers, ...lenders]) {
      if (party.chopdiId) chopdiIds.add(party.chopdiId);
    }

    const [chopdis, mergedIds] = await Promise.all([
      chopdiIds.size
        ? this.prisma.chopdi.findMany({
            where: { userId, id: { in: [...chopdiIds] } },
          })
        : [],
      this.mergedIds(
        userId,
        [...customers, ...lenders].map((p) => p.id),
      ),
    ]);

    return buildPullTree({
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      serverCursor: page.serverCursor,
      chopdis,
      customers,
      lenders,
      entries,
      mergedIds,
    });
  }

  /**
   * Every id merged into each party, following chains: the cleanup script can
   * merge a survivor into an older duplicate later, and a device still holding
   * the first alias has to learn where it ended up.
   */
  private async mergedIds(
    userId: string,
    partyIds: string[],
  ): Promise<Map<string, string[]>> {
    const result = new Map<string, string[]>();
    if (partyIds.length === 0) return result;

    // Merges are rare — a handful per account — so one indexed read of the
    // user's merges beats a query per hop.
    const merges = await this.prisma.partyMerge.findMany({
      where: { userId },
      select: { aliasId: true, mainId: true },
    });
    if (merges.length === 0) return result;

    const aliasesOf = new Map<string, string[]>();
    for (const m of merges) {
      aliasesOf.set(m.mainId, [...(aliasesOf.get(m.mainId) ?? []), m.aliasId]);
    }

    for (const partyId of partyIds) {
      const found: string[] = [];
      let frontier = [partyId];

      for (let hop = 0; hop < MAX_MERGE_HOPS && frontier.length > 0; hop++) {
        frontier = frontier.flatMap((id) => aliasesOf.get(id) ?? []);
        found.push(...frontier);
      }

      if (found.length > 0) result.set(partyId, [...new Set(found)].sort());
    }

    return result;
  }
}
