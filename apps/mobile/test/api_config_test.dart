import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/core/config/api_config.dart';

/// Guards how a build resolves its API address.
///
/// The address is a compile-time constant, so a forgotten `--dart-define` used
/// to produce an APK that installed, ran, and could not reach anything — the
/// failure surfacing at login, far from the mistake. Confirmed once by finding
/// no API URL anywhere in a shipped APK's compiled snapshot.
///
/// The resolution is now: fall back to the deployed URL so an accidental build
/// still works, **except** for production, which must state its target.
///
/// Every assertion holds whether or not defines were supplied, so this suite is
/// meaningful under a plain `flutter test` and under
/// `--dart-define-from-file=env/staging.env`.
void main() {
  group('URL resolution', () {
    test('a build always has a usable URL', () {
      // The property that matters: no build can end up pointing at nothing.
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl, startsWith('http'));
      expect(ApiConfig.isConfigured, isTrue);
    });

    test('falls back to the deployed API when nothing was supplied', () {
      if (!ApiConfig.usingDefaultUrl) {
        markTestSkipped('this build supplied an explicit URL');
        return;
      }

      expect(ApiConfig.baseUrl, ApiConfig.defaultBaseUrl);
      expect(ApiConfig.baseUrl, contains('/api'));
    });

    test('an explicit URL always wins over the default', () {
      if (ApiConfig.usingDefaultUrl) {
        markTestSkipped('no explicit URL in this build');
        return;
      }

      expect(ApiConfig.usingDefaultUrl, isFalse);
      expect(ApiConfig.baseUrl, startsWith('http'));
    });

    test('the default is a real remote host, never localhost', () {
      // Inside an installed app `localhost` is the phone itself, so a default
      // pointing there would be unreachable on every device.
      expect(ApiConfig.defaultBaseUrl, isNot(contains('localhost')));
      expect(ApiConfig.defaultBaseUrl, isNot(contains('127.0.0.1')));
      expect(ApiConfig.defaultBaseUrl, startsWith('https://'));
    });
  });

  group('production must be deliberate', () {
    test('a production build cannot rely on the default URL', () {
      if (!ApiConfig.isProduction) {
        markTestSkipped('not a production build');
        return;
      }

      expect(
        ApiConfig.usingDefaultUrl,
        isFalse,
        reason: 'a release must name its API rather than inherit a default '
            'that currently points at a dev-mode environment',
      );
    });

    test('a production build cannot carry a dev key', () {
      // Mirrors the server refusing to boot with APP_ENV=production and
      // AUTH_DEV_MODE=true. DEV_KEY gates a bypass accepting any phone number.
      if (!ApiConfig.isProduction) {
        markTestSkipped('not a production build');
        return;
      }

      expect(ApiConfig.devKey, isEmpty,
          reason: 'clear DEV_KEY in env/production.env');
    });

    test('non-production builds are usable as-is', () {
      if (ApiConfig.isProduction) {
        markTestSkipped('production is covered above');
        return;
      }

      expect(ApiConfig.misconfigurationReason, isNull);
      expect(ApiConfig.assertConfigured, returnsNormally);
    });
  });

  group('diagnostics', () {
    test('appEnv is one of the known environments', () {
      expect(['development', 'staging', 'production'],
          contains(ApiConfig.appEnv));
    });

    test('a problem is reported as a typed exception, not a bare error', () {
      // Typed so the UI can tell "this APK was built wrong" apart from "the
      // server is down" — otherwise both read as "something went wrong".
      expect(const ApiConfigException('x'), isA<Exception>());
      expect(const ApiConfigException('boom').toString(), contains('boom'));
    });
  });
}
