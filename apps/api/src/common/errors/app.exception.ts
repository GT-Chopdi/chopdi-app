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

  // --- generic ---
  NOT_FOUND: 'NOT_FOUND',
  RATE_LIMITED: 'RATE_LIMITED',
  INTERNAL: 'INTERNAL',
  DB_UNAVAILABLE: 'DB_UNAVAILABLE',
} as const;

export type ErrorCodeValue = (typeof ErrorCode)[keyof typeof ErrorCode];
