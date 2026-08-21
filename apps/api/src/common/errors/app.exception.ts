import { HttpException } from '@nestjs/common';

/**
 * An error the client is expected to handle programmatically.
 *
 * The `permanent` flag is the important field: it tells an offline client
 * whether retrying could ever succeed. It is stated explicitly rather than
 * inferred from the status code so the server can reclassify an error without
 * waiting for an app-store release — an installed APK keeps its retry logic
 * for months.
 *
 * Serialised by {@link AllExceptionsFilter} into:
 *   { error: { code, message, permanent, details }, requestId }
 */
export class AppException extends HttpException {
  constructor(
    status: number,
    readonly code: string,
    message: string,
    readonly permanent: boolean,
    readonly details?: Record<string, unknown>,
  ) {
    super({ code, message, permanent, details }, status);
  }
}

/**
 * Error codes shared with the Flutter client. Keep in sync with the client's
 * enum — these strings are a wire contract, not internal identifiers, so
 * renaming one breaks every installed app that branches on it.
 */
export const ErrorCode = {
  // --- auth ---
  VALIDATION_FAILED: 'VALIDATION_FAILED',
  UNAUTHENTICATED: 'UNAUTHENTICATED',
  INVALID_CODE: 'INVALID_CODE',
  CHALLENGE_EXPIRED: 'CHALLENGE_EXPIRED',
  TOO_MANY_ATTEMPTS: 'TOO_MANY_ATTEMPTS',
  REFRESH_REUSED: 'REFRESH_REUSED',
  REFRESH_INVALID: 'REFRESH_INVALID',
  DEVICE_REVOKED: 'DEVICE_REVOKED',
  DEV_KEY_REQUIRED: 'DEV_KEY_REQUIRED',
  SMS_NOT_CONFIGURED: 'SMS_NOT_CONFIGURED',
  USER_SUSPENDED: 'USER_SUSPENDED',

  // --- sync ---
  /** A create arrived for an id that already exists under this user. */
  ID_EXISTS: 'ID_EXISTS',
  /** The row moved on since the client last saw it; `serverState` is attached. */
  STALE_VERSION: 'STALE_VERSION',
  /** An entry arrived before the customer it belongs to. */
  PARENT_NOT_FOUND: 'PARENT_NOT_FOUND',
  /** An update or void targeted a row that is already voided or deleted. */
  ENTITY_VOIDED: 'ENTITY_VOIDED',
  /** Same idempotency key, different payload — a client bug, or a spliced request. */
  IDEMPOTENCY_KEY_REUSE: 'IDEMPOTENCY_KEY_REUSE',
  /** More operations or bytes than one request may carry. */
  BATCH_TOO_LARGE: 'BATCH_TOO_LARGE',

  // --- generic ---
  NOT_FOUND: 'NOT_FOUND',
  RATE_LIMITED: 'RATE_LIMITED',
  INTERNAL: 'INTERNAL',
  DB_UNAVAILABLE: 'DB_UNAVAILABLE',
} as const;

export type ErrorCodeValue = (typeof ErrorCode)[keyof typeof ErrorCode];
