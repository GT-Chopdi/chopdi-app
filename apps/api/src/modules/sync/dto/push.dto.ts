import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsObject,
  IsOptional,
  IsUUID,
  Min,
  ValidateNested,
} from 'class-validator';

/**
 * One change the client wants applied.
 *
 * Note what is **absent**: `userId`. Ownership comes from the access token and
 * nowhere else. Because the global ValidationPipe runs with
 * `forbidNonWhitelisted`, a request carrying `userId` is rejected outright
 * rather than silently ignored — but that protection only holds while no DTO
 * declares the field, so it must never be added here.
 *
 * Also absent: `version`, `createdAt`, `updatedAt`. Those are the server's to
 * assign; accepting them would let a client claim version 9999 and win every
 * future conflict.
 */
export class SyncOperationDto {
  /**
   * Idempotency key, generated once by the client and never regenerated on
   * retry. This is what makes a lost response survivable: the server recognises
   * the key and answers without writing again, so one loan cannot become two.
   */
  @IsUUID()
  opId!: string;

  @IsIn(['customer', 'ledger_entry'])
  entity!: 'customer' | 'ledger_entry';

  /** The row's client-generated UUIDv7. */
  @IsUUID()
  entityId!: string;

  @IsIn(['create', 'update', 'void'])
  opType!: 'create' | 'update' | 'void';

  /**
   * The version the client last saw. Required for update and void.
   *
   * Its absence on a create is meaningful: a create has nothing to conflict
   * with. Its presence on an update is what turns a silent overwrite into a
   * detectable conflict.
   */
  @IsOptional()
  @IsInt()
  @Min(0)
  expectedVersion?: number;

  /**
   * Entity fields. Validated by the handler that owns the entity rather than
   * here, because the shape differs per entity and per operation.
   */
  @IsObject()
  payload!: Record<string, unknown>;
}

export class PushBatchDto {
  /**
   * Operations in the order the client recorded them.
   *
   * Order matters — a create must reach the server before the update that
   * follows it — but the server re-sorts anyway rather than trusting it. A
   * client bug shipped months ago should not become server-side data loss.
   */
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200, {
    message:
      'Too many operations in one batch. Split it and retry; the limit bounds ' +
      'how long a single request can hold a database connection.',
  })
  @ValidateNested({ each: true })
  @Type(() => SyncOperationDto)
  operations!: SyncOperationDto[];

  /** Correlates every log line from one drain cycle. Optional. */
  @IsOptional()
  @IsUUID()
  syncSessionId?: string;
}
