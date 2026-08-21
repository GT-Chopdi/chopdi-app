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

  /// The deployed API, used when no URL was supplied at build time.
  ///
  /// A forgotten `--dart-define` previously produced an APK that installed and
  /// ran but could not reach anything — a whole build cycle lost to a missing
  /// flag. Defaulting means an accidental build is merely pointed at the wrong
  /// environment rather than at nothing at all.
  ///
  /// Production does **not** get this convenience; see
  /// [misconfigurationReason].
  static const String defaultBaseUrl = 'https://chopdi-app.vercel.app/api';

  /// Exactly what was passed at build time — empty when nothing was.
  ///
  /// Kept separate from [baseUrl] so the two cases stay distinguishable. A
  /// production build must state its URL deliberately, and that check is only
  /// possible if "defaulted" and "explicitly set to the same value" are not
  /// collapsed into one.
  static const String _explicitBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// True when the build fell back to [defaultBaseUrl].
  static bool get usingDefaultUrl => _explicitBaseUrl.isEmpty;

  static String get baseUrl =>
      _explicitBaseUrl.isEmpty ? defaultBaseUrl : _explicitBaseUrl;

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

  /// Which environment this build targets: development | staging | production.
  ///
  /// Ours, not the platform's, and the only thing the interlock below trusts.
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static bool get isProduction => appEnv == 'production';

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Human-readable reason the build is unusable, or null when it is fine.
  static String? get misconfigurationReason {
    // Mirrors the server, which refuses to boot with APP_ENV=production and
    // AUTH_DEV_MODE=true. The client should not be able to ship the other half
    // of that bypass: a production build carrying a dev key would let anyone
    // holding it sign in as any phone number. Failing here means it fails on a
    // developer's machine rather than in the store.
    if (isProduction && devKey.isNotEmpty) {
      return 'This is a production build, but a DEV_KEY was compiled into it.\n\n'
          'DEV_KEY gates a bypass that accepts any phone number. Clear it in '
          'env/production.env and rebuild.';
    }

    // Everything else may fall back to the deployed URL, but a store build may
    // not. Silently defaulting there would point production users at whichever
    // environment happens to be the default — today one that runs dev-mode
    // auth. A release has to say where it points.
    if (isProduction && usingDefaultUrl) {
      return 'This is a production build, but no API_BASE_URL was supplied.\n\n'
          'Production must name its API explicitly:\n\n'
          'flutter build appbundle \\\n'
          '  --dart-define-from-file=env/production.env';
    }

    if (!baseUrl.startsWith('http')) {
      return 'API_BASE_URL is not a URL: "$baseUrl"';
    }

    // A build pointing at localhost cannot work on a handset: inside an
    // installed app `localhost` is the phone itself, never the machine that
    // built it. Worth naming, because the resulting connection error looks
    // like a server outage.
    if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')) {
      return 'API_BASE_URL points at localhost ("$baseUrl").\n\n'
          'On a phone that means the phone itself. Use the deployed URL, or '
          'your machine\'s LAN address.';
    }

    return null;
  }

  /// Throws when the build cannot possibly reach an API.
  ///
  /// A typed exception rather than a bare `StateError` so callers can tell a
  /// build mistake apart from a genuine runtime failure — the difference
  /// between "this APK was built wrong" and "the server is down", which look
  /// identical to a user otherwise.
  static void assertConfigured() {
    final reason = misconfigurationReason;
    if (reason != null) throw ApiConfigException(reason);
  }
}

/// The app was built without usable API configuration.
///
/// Always a build-time mistake, never something a user can resolve, so it is
/// reported verbatim instead of behind a generic "something went wrong".
class ApiConfigException implements Exception {
  const ApiConfigException(this.message);

  final String message;

  @override
  String toString() => 'ApiConfigException: $message';
}
