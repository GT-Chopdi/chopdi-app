import 'api_client.dart';

/// Why one operation in a batch ended the way it did.
class SyncOperationError {
  const SyncOperationError({
    required this.code,
    required this.message,
    required this.permanent,
    this.details,
  });

  factory SyncOperationError.fromJson(Map<String, dynamic> json) =>
      SyncOperationError(
        code: json['code'] as String? ?? 'INTERNAL',
        message: json['message'] as String? ?? 'Something went wrong.',
        // Defaults to false for the same reason ApiException does: a wasted
        // retry costs a request, while wrongly assuming permanence discards a
        // ledger entry.
        permanent: json['permanent'] as bool? ?? false,
        details: (json['details'] as Map?)?.cast<String, dynamic>(),
      );

  final String code;
  final String message;
  final bool permanent;
  final Map<String, dynamic>? details;

  @override
  String toString() => '$code: $message';
}

/// The outcome of a single operation.
///
/// Mirrors `SyncResultStatus` in `apps/api/src/modules/sync/sync.types.ts`.
/// The status strings are a wire contract; an unknown one must not crash an
/// installed build, so [isSuccess] and friends test for what they know rather
/// than switching exhaustively.
class SyncOperationResult {
  const SyncOperationResult({
    required this.opId,
    required this.status,
    this.entityId,
    this.version,
    this.seq,
    this.error,
    this.serverState,
  });

  factory SyncOperationResult.fromJson(Map<String, dynamic> json) =>
      SyncOperationResult(
        opId: json['opId'] as String,
        status: json['status'] as String? ?? 'rejected',
        entityId: json['entityId'] as String?,
        version: json['version'] as int?,
        seq: json['seq'] as String?,
        error: json['error'] is Map
            ? SyncOperationError.fromJson(
                (json['error'] as Map).cast<String, dynamic>(),
              )
            : null,
        serverState: (json['serverState'] as Map?)?.cast<String, dynamic>(),
      );

  final String opId;

  /// `applied` | `duplicate` | `conflict` | `rejected`
  final String status;

  final String? entityId;
  final int? version;

  /// Change-log position. A string because it is a 64-bit value that would
  /// lose precision in a JavaScript number and, on some platforms, in Dart's.
  final String? seq;

  final SyncOperationError? error;

  /// Present on a conflict so the user can be shown both versions.
  final Map<String, dynamic>? serverState;

  /// `duplicate` is a success, not a warning: it means this exact operation
  /// already landed. That is the *expected* answer whenever a client retries
  /// after a lost response, which on a mobile network is routine. Treating it
  /// as a failure would dead-letter entries that are safely on the server.
  bool get isSuccess => status == 'applied' || status == 'duplicate';

  bool get isConflict => status == 'conflict';

  /// Retrying this exact operation can never succeed.
  bool get isPermanentFailure => !isSuccess && (error?.permanent ?? false);
}

class SyncPushResponse {
  const SyncPushResponse({required this.results, required this.serverCursor});

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) =>
      SyncPushResponse(
        results: (json['results'] as List? ?? const [])
            .map((r) => SyncOperationResult.fromJson(
                  (r as Map).cast<String, dynamic>(),
                ))
            .toList(),
        serverCursor: json['serverCursor'] as String? ?? '0',
      );

  final List<SyncOperationResult> results;
  final String serverCursor;
}

/// The sync endpoints.
class SyncApi {
  const SyncApi(this._client);

  final ApiClient _client;

  /// Applies a batch of offline changes.
  ///
  /// Answers 200 with a per-operation result array *even when individual
  /// operations fail*. A thrown [ApiException] therefore means the whole
  /// request was unusable — unauthenticated, malformed, unreachable — not that
  /// some entry was rejected. Keeping those apart is what lets the caller
  /// advance past the operations that landed instead of retrying a batch
  /// forever because one entry is bad.
  Future<SyncPushResponse> push({
    required List<Map<String, dynamic>> operations,
    String? syncSessionId,
  }) async {
    final json = await _client.post(
      '/v1/sync/push',
      body: {
        'operations': operations,
        'syncSessionId': ?syncSessionId,
      },
    );

    return SyncPushResponse.fromJson(json);
  }
}
