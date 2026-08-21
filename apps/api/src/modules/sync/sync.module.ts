import { Module } from '@nestjs/common';

import { ChangeLogService } from './change-log.service';
import { CustomerHandler } from './handlers/customer.handler';
import { LedgerEntryHandler } from './handlers/ledger-entry.handler';
import { IdempotencyService } from './idempotency.service';
import { SyncController } from './sync.controller';
import { SyncService } from './sync.service';

@Module({
  controllers: [SyncController],
  providers: [
    SyncService,
    IdempotencyService,
    ChangeLogService,
    CustomerHandler,
    LedgerEntryHandler,
  ],
  exports: [ChangeLogService],
})
export class SyncModule {}
