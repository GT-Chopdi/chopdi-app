import { Module } from '@nestjs/common';

import { ChangeLogService } from './change-log.service';
import { DefaultChopdiService } from './default-chopdi.service';
import { ChopdiHandler } from './handlers/chopdi.handler';
import { CustomerHandler } from './handlers/customer.handler';
import { LedgerEntryHandler } from './handlers/ledger-entry.handler';
import { LenderHandler } from './handlers/lender.handler';
import { IdempotencyService } from './idempotency.service';
import { MergeService } from './merge.service';
import { PullService } from './pull.service';
import { SyncController, SyncV2Controller } from './sync.controller';
import { PullTreeService } from './pull-tree.service';
import { SyncService } from './sync.service';

@Module({
  controllers: [SyncController, SyncV2Controller],
  providers: [
    SyncService,
    PullService,
    PullTreeService,
    IdempotencyService,
    ChangeLogService,
    MergeService,
    DefaultChopdiService,
    ChopdiHandler,
    CustomerHandler,
    LenderHandler,
    LedgerEntryHandler,
  ],
  exports: [ChangeLogService, DefaultChopdiService],
})
export class SyncModule {}
