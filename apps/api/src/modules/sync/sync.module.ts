import { Module } from '@nestjs/common';

import { ChangeLogService } from './change-log.service';
import { ChopdiHandler } from './handlers/chopdi.handler';
import { CustomerHandler } from './handlers/customer.handler';
import { LedgerEntryHandler } from './handlers/ledger-entry.handler';
import { LenderHandler } from './handlers/lender.handler';
import { IdempotencyService } from './idempotency.service';
import { MergeService } from './merge.service';
import { PullService } from './pull.service';
import { SyncController } from './sync.controller';
import { SyncService } from './sync.service';

@Module({
  controllers: [SyncController],
  providers: [
    SyncService,
    PullService,
    IdempotencyService,
    ChangeLogService,
    MergeService,
    ChopdiHandler,
    CustomerHandler,
    LenderHandler,
    LedgerEntryHandler,
  ],
  exports: [ChangeLogService],
})
export class SyncModule {}
