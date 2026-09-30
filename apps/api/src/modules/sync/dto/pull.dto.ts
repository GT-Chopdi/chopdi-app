import { Type } from 'class-transformer';
import { IsInt, IsOptional, Matches, Max, Min } from 'class-validator';

/**
 * Query for `GET /v1/sync/pull`.
 *
 * Like the push DTO, this has no `userId`: whose changes are returned comes
 * from the access token alone. The global ValidationPipe runs with
 * `forbidNonWhitelisted`, so `?userId=` is refused rather than ignored.
 */
export class PullQueryDto {
  /**
   * The last sequence this device has applied. `0` (or omitted) means "from
   * the beginning" — what a device signing in for the first time sends.
   *
   * A decimal string, not a number: the sequence is a Postgres BIGINT, and a
   * JSON or JavaScript number silently loses precision above 2^53. At most 19
   * digits; the service also checks it fits a signed 64-bit value.
   */
  @IsOptional()
  @Matches(/^(0|[1-9][0-9]{0,18})$/, {
    message: 'cursor must be a non-negative whole number.',
  })
  cursor?: string;

  /**
   * Page size. Capped server-side at `SYNC_MAX_PULL_LIMIT`; anything above
   * that is served at the cap rather than refused, so raising or lowering the
   * cap never breaks an installed app.
   */
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'limit must be a whole number.' })
  @Min(1, { message: 'limit must be at least 1.' })
  @Max(100_000, { message: 'limit is unreasonably large.' })
  limit?: number;
}
