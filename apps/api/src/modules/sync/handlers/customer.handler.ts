import { Injectable } from '@nestjs/common';

import {
  ChangeLogService,
  type TransactionClient,
} from '../change-log.service';
import { MergeService } from '../merge.service';
import { PartyHandler, type PartyDelegate } from './party.handler';

/** Applies operations for customers — people the user gave a loan to. */
@Injectable()
export class CustomerHandler extends PartyHandler {
  constructor(changeLog: ChangeLogService, merges: MergeService) {
    super(changeLog, merges);
  }

  protected readonly entity = 'customer' as const;
  protected readonly label = 'customer';

  protected table(tx: TransactionClient): PartyDelegate {
    return tx.customer;
  }
}
