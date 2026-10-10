import { Body, Controller, Get, Header, HttpCode, Post, Query } from '@nestjs/common';

import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PullQueryDto } from './dto/pull.dto';
import { PushBatchDto } from './dto/push.dto';
import { PullTreeService } from './pull-tree.service';
import { PullService } from './pull.service';
import { SyncService } from './sync.service';
import type {
  SyncPullResponse,
  SyncPullTreeResponse,
  SyncPushResponse,
} from './sync.types';

/**
 * Sync endpoints.
 *
 * Guarded globally: the JWT guard supplies the user, the device guard rejects a
 * revoked handset. Ownership is taken from the token via {@link CurrentUser} and
 * never from the body — no DTO here declares `userId`, so a request carrying one
 * is refused outright by the global ValidationPipe.
 */
@Controller('v1/sync')
export class SyncController {
  constructor(
    private readonly sync: SyncService,
    private readonly pulls: PullService,
  ) {}

  /**
   * Returns this user's changes after `cursor`, oldest first.
   *
   * Called with `cursor=0` when a user signs in on a device, to restore their
   * books, customers, lenders and entries; afterwards with the stored cursor to
   * pick up changes made on other devices. Page until `hasMore` is false.
   *
   * `no-store`: the body is someone's financial records, and no proxy or
   * on-device HTTP cache has any business keeping a copy.
   */
  @Get('pull')
  @Header('Cache-Control', 'no-store')
  pull(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: PullQueryDto,
  ): Promise<SyncPullResponse> {
    return this.pulls.pull(user, query);
  }

  /**
   * Applies a batch of offline changes.
   *
   * Answers `200` with a per-operation result array even when individual
   * operations fail. A non-2xx here means the whole request was unusable —
   * unauthenticated, too large, malformed — not that some change was rejected.
   * That distinction is what lets a client advance past the operations that
   * landed instead of retrying a batch forever because one entry is bad.
   */
  @Post('push')
  @HttpCode(200)
  push(
    @CurrentUser() user: AuthenticatedUser,
    @Body() batch: PushBatchDto,
  ): Promise<SyncPushResponse> {
    return this.sync.push(user, batch);
  }
}

/**
 * Version 2 of pull: the same pages, nested by book (chopdi → customers /
 * lenders → entries) so the app can file every record under its book directly.
 *
 * v1 stays as it is for installed builds. Cursors are shared: a device can
 * switch versions without re-pulling.
 */
@Controller('v2/sync')
export class SyncV2Controller {
  constructor(private readonly pulls: PullTreeService) {}

  @Get('pull')
  @Header('Cache-Control', 'no-store')
  pull(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: PullQueryDto,
  ): Promise<SyncPullTreeResponse> {
    return this.pulls.pull(user, query);
  }
}
