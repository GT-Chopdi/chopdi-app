import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/data/remote/api_exception.dart';
import 'package:mychopdi/data/remote/error_code.dart';

void main() {
  group('ApiException.fromResponse', () {
    test('parses the standard envelope', () {
      final e = ApiException.fromResponse(401, {
        'error': {
          'code': 'INVALID_CODE',
          'message': 'Invalid or expired code.',
          'permanent': true,
          'details': {'attemptsRemaining': 3},
        },
        'requestId': '018f-abc',
      });

      expect(e.code, ApiErrorCode.invalidCode);
      expect(e.permanent, isTrue);
      expect(e.statusCode, 401);
      expect(e.details?['attemptsRemaining'], 3);
      expect(e.requestId, '018f-abc');
    });

    test('defaults permanent to false when the field is absent', () {
      // The asymmetry matters: wrongly assuming "retryable" costs one wasted
      // retry, wrongly assuming "permanent" discards a user's ledger entry.
      final e = ApiException.fromResponse(500, {
        'error': {'code': 'INTERNAL', 'message': 'boom'},
      });

      expect(e.permanent, isFalse);
    });

    test('survives a non-JSON body without throwing', () {
      // Proxies and gateways return HTML error pages. A parser that threw here
      // would replace a diagnosable server error with a confusing crash.
      final e = ApiException.fromResponse(502, '<html>Bad Gateway</html>');

      expect(e.code, ApiErrorCode.internal);
      expect(e.permanent, isFalse);
      expect(e.statusCode, 502);
    });

    test('survives a JSON body that is not our envelope', () {
      final e = ApiException.fromResponse(400, {'message': 'nope'});
      expect(e.code, ApiErrorCode.internal);
    });
  });

  group('classification', () {
    test('network failures are never permanent', () {
      // The server may have committed the write and only the response was
      // lost. Treating that as permanent is how data goes missing.
      final e = ApiException.network(Exception('connection reset'));

      expect(e.permanent, isFalse);
      expect(e.isServerRejection, isFalse);
    });

    test('session-ending codes are flagged for reauth', () {
      for (final code in ApiErrorCode.requiresReauth) {
        final e = ApiException.fromResponse(401, {
          'error': {'code': code, 'message': 'x', 'permanent': true},
        });
        expect(e.requiresReauth, isTrue, reason: '$code should force reauth');
      }
    });

    test('an ordinary rejection does not force reauth', () {
      final e = ApiException.fromResponse(400, {
        'error': {'code': 'VALIDATION_FAILED', 'message': 'x', 'permanent': true},
      });
      expect(e.requiresReauth, isFalse);
    });
  });
}
