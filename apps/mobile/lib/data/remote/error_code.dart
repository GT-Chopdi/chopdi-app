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

  // --- sync ---
  //
  // Returned per-operation by `/v1/sync/push`, not as a request-level failure.
  // Whether to retry is taken from the `permanent` flag on the error itself,
  // never inferred from the code here — that is what lets the server reclassify
  // one without waiting for an app-store release. These constants exist so the
  // client can *recognise* a code, not so it can second-guess it.

  /// The row's id already exists. Permanent: a create cannot become valid.
  static const String idExists = 'ID_EXISTS';

  /// The row moved on since this client last saw it. Answered as a `conflict`,
  /// not a rejection — both versions are kept and the user chooses, because
  /// financial fields must never be merged automatically.
  static const String staleVersion = 'STALE_VERSION';

  /// The owning customer has not arrived yet.
  ///
  /// Explicitly **not** permanent, and the one code here where that matters
  /// most: an entry and its customer are usually created in the same batch, and
  /// a customer whose own operation failed may well succeed on the next
  /// attempt. Treating this as fatal would dead-letter a perfectly valid entry.
  static const String parentNotFound = 'PARENT_NOT_FOUND';

  /// The target was soft-deleted. Permanent.
  static const String entityVoided = 'ENTITY_VOIDED';

  /// The same `opId` arrived carrying different bytes.
  ///
  /// Permanent, and a client bug rather than a user one: it means a payload was
  /// re-serialised at send time instead of frozen at enqueue. See
  /// [SyncOp.payload].
  static const String idempotencyKeyReuse = 'IDEMPOTENCY_KEY_REUSE';

  /// More operations than one request may carry. Permanent for that batch;
  /// [SyncEngine.batchSize] mirrors the server's limit so it should not occur.
  static const String batchTooLarge = 'BATCH_TOO_LARGE';

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
    idExists,
    staleVersion,
    parentNotFound,
    entityVoided,
    idempotencyKeyReuse,
    batchTooLarge,
    notFound,
    rateLimited,
    internal,
    dbUnavailable,
  };

  static bool isKnown(String code) => known.contains(code);
}
