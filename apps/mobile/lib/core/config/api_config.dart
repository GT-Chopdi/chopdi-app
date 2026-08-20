/// Compile-time API configuration.
///
/// The base URL is supplied with `--dart-define` rather than hardcoded, so a
/// build targets an environment by flag instead of a code edit — which means
/// you cannot accidentally ship a store build pointing at localhost.
///
/// ```bash
/// # Android emulator against a local server (10.0.2.2 is the host's loopback)
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001/api
///
/// # iOS simulator shares the host network
/// flutter run --dart-define=API_BASE_URL=http://localhost:3001/api
///
/// # Build for testers
/// flutter build apk --dart-define=API_BASE_URL=https://chopdi-app.vercel.app/api \
///                   --dart-define=DEV_KEY=<the AUTH_DEV_KEY from Vercel>
/// ```
///
/// `localhost` inside an installed app means *the phone itself*, never your
/// development machine — which is why a physical device needs either the LAN
/// address or the deployed URL.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  /// Shared secret required by the API while it runs in dev-auth mode.
  ///
  /// Staging is internet-reachable and accepts a fixed OTP for any phone
  /// number, so it is gated behind this header. Empty in production builds,
  /// where the server ignores it entirely.
  static const String devKey = String.fromEnvironment('DEV_KEY');

  /// Reported to the server on sign-in and used for compatibility triage.
  /// Keep in sync with `version:` in pubspec.yaml.
  static const String appVersion = '0.1.0';

  static const Duration connectTimeout = Duration(seconds: 15);

  /// Generous on purpose. Neon's compute suspends when idle and a serverless
  /// function may cold-start on top of that, so a first request after a quiet
  /// period can legitimately take tens of seconds. Timing out early turns a
  /// slow-but-fine request into a spurious failure — and for sync, a timeout is
  /// the one outcome the client cannot interpret.
  static const Duration receiveTimeout = Duration(seconds: 30);

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Fails loudly at startup rather than producing confusing 404s later.
  static void assertConfigured() {
    if (!isConfigured) {
      throw StateError(
        'API_BASE_URL is not set. Run with '
        '--dart-define=API_BASE_URL=https://your-api/api',
      );
    }
  }
}
