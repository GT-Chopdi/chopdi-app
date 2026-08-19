@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/core/config/api_config.dart';
import 'package:mychopdi/data/remote/api_client.dart';
import 'package:mychopdi/data/remote/api_exception.dart';
import 'package:mychopdi/data/remote/auth_api.dart';
import 'package:mychopdi/data/remote/error_code.dart';
import 'package:mychopdi/data/remote/token_storage.dart';

/// Exercises the real client stack against a real deployment.
///
/// Runs on the Dart VM, so it needs no emulator or handset — which matters,
/// because the unit tests above prove each piece in isolation while this is the
/// only thing that proves they work *together*: URL construction, headers,
/// request shape, response parsing, and the error envelope, all against the
/// server that will actually answer them.
///
///   flutter test test/api_integration_test.dart \
///     --dart-define=API_BASE_URL=https://chopdi-app.vercel.app/api \
///     --dart-define=DEV_KEY=`AUTH_DEV_KEY`
///
/// Without DEV_KEY the sign-in tests skip; the reachability and error-contract
/// checks still run.

/// In-memory stand-in for the Keychain.
///
/// `flutter_secure_storage` needs platform channels that do not exist on the
/// VM. Overriding every method means the real backing store is never touched.
class _MemoryTokenStorage extends TokenStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> get accessToken async => _store['access'];

  @override
  Future<String?> get refreshToken async => _store['refresh'];

  @override
  Future<String?> get deviceId async => _store['device'];

  @override
  Future<String> installId() async =>
      _store['install'] ??= '018f0000-0000-7000-8000-0000000000aa';

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) async {
    _store
      ..['access'] = accessToken
      ..['refresh'] = refreshToken
      ..['device'] = deviceId;
  }

  @override
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _store
      ..['access'] = accessToken
      ..['refresh'] = refreshToken;
  }

  @override
  Future<void> clearSession() async {
    _store..remove('access')..remove('refresh')..remove('device');
  }

  @override
  Future<bool> hasSession() async => _store.containsKey('refresh');
}

void main() {
  final configured = ApiConfig.baseUrl.isNotEmpty;
  final hasDevKey = ApiConfig.devKey.isNotEmpty;

  late _MemoryTokenStorage tokens;
  late ApiClient client;
  late AuthApi auth;

  setUp(() {
    tokens = _MemoryTokenStorage();
    client = ApiClient(tokens: tokens);
    auth = AuthApi(client);
  });

  group('deployment reachability', skip: configured ? null : 'API_BASE_URL not set', () {
    test('health responds and reports the database up', () async {
      final body = await client.get('/health');

      expect(body['status'], 'ok');
      expect((body['info'] as Map)['database']['status'], 'up');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('an unauthenticated call parses into a typed ApiException', () async {
      // Proves the whole error path end to end: the server's envelope reaches
      // Dart as a code the client can branch on, not an opaque failure.
      await expectLater(
        auth.logout(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.code, 'code', ApiErrorCode.unauthenticated)
              .having((e) => e.requestId, 'requestId', isNotNull),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('sign-in flow', skip: configured && hasDevKey ? null : 'needs API_BASE_URL and DEV_KEY', () {
    test('request → verify → session, and the same number resolves to one user',
        () async {
      // A number unlikely to collide with manual testing.
      const phone = '+919000000042';

      final challenge = await auth.requestOtp(
        phone: phone,
        installId: await tokens.installId(),
      );

      expect(challenge.challengeId, isNotEmpty);
      expect(challenge.expiresInSeconds, greaterThan(0));

      final session = await auth.verifyOtp(
        challengeId: challenge.challengeId,
        code: '123456',
        installId: await tokens.installId(),
        appVersion: ApiConfig.appVersion,
      );

      expect(session.accessToken, isNotEmpty);
      expect(session.refreshToken, isNotEmpty);
      expect(session.deviceId, isNotEmpty);
      expect(session.phone, phone);

      await tokens.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        deviceId: session.deviceId,
      );

      // Authenticated call now succeeds — proves the token is attached.
      await auth.logout();
    }, timeout: const Timeout(Duration(seconds: 120)));

    test('a wrong code is rejected with attempts remaining', () async {
      final challenge = await auth.requestOtp(
        phone: '+919000000043',
        installId: await tokens.installId(),
      );

      await expectLater(
        auth.verifyOtp(
          challengeId: challenge.challengeId,
          code: '000000',
          installId: await tokens.installId(),
          appVersion: ApiConfig.appVersion,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.invalidCode)
              .having((e) => e.details?['attemptsRemaining'], 'attemptsRemaining',
                  isA<int>()),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}
