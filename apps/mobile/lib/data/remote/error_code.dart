/// Error codes returned by the Chopdi API.
///
/// **This is a wire contract, not an internal enum.** Every value here must
/// match `ErrorCode` in `apps/api/src/common/errors/app.exception.ts` exactly.
/// The server sends these strings; this client branches on them to decide
/// whether an operation can be retried. Renaming one on either side silently
/// breaks every installed app until users update — which, for a mobile client,
/// can be months.
///
/// Unknown codes are tolerated on purpose: a newer server may introduce a code
/// this build has never heard of, and an old app must degrade rather than
/// crash. See [ApiErrorCode.parse].
class ApiErrorCode {
  const ApiErrorCode._();

  // --- auth ---
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String invalidCode = 'INVALID_CODE';
  static const String challengeExpired = 'CHALLENGE_EXPIRED';
  static const String tooManyAttempts = 'TOO_MANY_ATTEMPTS';
  static const String refreshReused = 'REFRESH_REUSED';
  static const String refreshInvalid = 'REFRESH_INVALID';
  static const String deviceRevoked = 'DEVICE_REVOKED';
  static const String devKeyRequired = 'DEV_KEY_REQUIRED';
  static const String smsNotConfigured = 'SMS_NOT_CONFIGURED';
  static const String userSuspended = 'USER_SUSPENDED';

  // --- generic ---
  static const String notFound = 'NOT_FOUND';
  static const String rateLimited = 'RATE_LIMITED';
  static const String internal = 'INTERNAL';
  static const String dbUnavailable = 'DB_UNAVAILABLE';

  /// Codes that mean the current session is gone and the user must sign in
  /// again. The queue must stop rather than retry, and local data is kept —
  /// losing a user's unsynced ledger because their token expired would be far
  /// worse than asking them to log in.
  static const Set<String> requiresReauth = {
    refreshReused,
    refreshInvalid,
    deviceRevoked,
    userSuspended,
  };

  /// Every code this build knows about. Used only to detect a server that has
  /// moved ahead of the app.
  static const Set<String> known = {
    validationFailed,
    unauthenticated,
    invalidCode,
    challengeExpired,
    tooManyAttempts,
    refreshReused,
    refreshInvalid,
    deviceRevoked,
    devKeyRequired,
    smsNotConfigured,
    userSuspended,
    notFound,
    rateLimited,
    internal,
    dbUnavailable,
  };

  static bool isKnown(String code) => known.contains(code);
}
