import 'error_code.dart';

/// A parsed error from the Chopdi API.
///
/// The server always answers a failure with the same envelope:
///
/// ```json
/// { "error": { "code": "...", "message": "...", "permanent": false,
///              "details": { } }, "requestId": "018f..." }
/// ```
///
/// [permanent] is the field that matters operationally. It is sent explicitly
/// rather than inferred from the status code, so the server can reclassify an
/// error without waiting for an app-store release — an installed build keeps
/// its retry logic for months.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    required this.permanent,
    this.statusCode,
    this.details,
    this.requestId,
  });

  final String code;
  final String message;

  /// True when retrying this exact request can never succeed.
  final bool permanent;

  final int? statusCode;
  final Map<String, dynamic>? details;

  /// Correlates with the server log line. Worth showing in bug reports.
  final String? requestId;

  /// Raised when the network failed or the response never arrived.
  ///
  /// Deliberately **not** permanent: the request may well have succeeded on the
  /// server with only the response lost. Treating that as failure is how you
  /// lose data; treating it as unknown and retrying is why every write carries
  /// an idempotency key.
  factory ApiException.network(Object error) => ApiException(
        code: 'NETWORK_UNAVAILABLE',
        message: 'Could not reach the server.',
        permanent: false,
        details: {'cause': error.toString()},
      );

  /// Parses the standard envelope, falling back gracefully when the body is
  /// not the shape we expect — a proxy error page, an HTML 502, a truncated
  /// response. A parser that throws here would mask the original failure.
  factory ApiException.fromResponse(int? statusCode, dynamic body) {
    if (body is Map && body['error'] is Map) {
      final error = (body['error'] as Map).cast<String, dynamic>();

      return ApiException(
        code: error['code'] as String? ?? ApiErrorCode.internal,
        message: error['message'] as String? ?? 'Something went wrong.',
        // Default to false: assuming an unlabelled error is retryable risks a
        // wasted retry, while assuming it is permanent risks discarding a
        // user's ledger entry. The asymmetry is not close.
        permanent: error['permanent'] as bool? ?? false,
        statusCode: statusCode,
        details: (error['details'] as Map?)?.cast<String, dynamic>(),
        requestId: body['requestId'] as String?,
      );
    }

    return ApiException(
      code: ApiErrorCode.internal,
      message: 'Unexpected response from the server.',
      permanent: false,
      statusCode: statusCode,
      details: {'body': body.toString()},
    );
  }

  /// The session is gone; the user must authenticate again.
  bool get requiresReauth => ApiErrorCode.requiresReauth.contains(code);

  /// The server was reachable but rejected the request. Distinguishing this
  /// from "we could not reach the server" matters in the UI: one means *your
  /// entry has a problem*, the other means *we have a problem*.
  bool get isServerRejection => statusCode != null;

  @override
  String toString() =>
      'ApiException($code, status: $statusCode, permanent: $permanent): $message'
      '${requestId != null ? ' [req=$requestId]' : ''}';
}
