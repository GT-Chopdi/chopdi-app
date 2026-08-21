import '../core/config/api_config.dart';
import '../data/remote/api_client.dart';
import '../data/remote/auth_api.dart';
import '../data/remote/token_storage.dart';
import '../model/user_session.dart';
import 'isar_service.dart';

/// Authentication against the Chopdi API.
///
/// There is deliberately no client-side notion of "the correct code" here. The
/// previous implementation compared against a `validOtp` constant and, in the
/// OTP screen, against a literal `"123456"` — both compiled into the APK and
/// both extractable in minutes with `apktool`. Anyone could sign in as any
/// phone number.
///
/// The fixed-code convenience still exists, but it lives on the server behind
/// `AUTH_DEV_MODE`, which cannot be switched on in production: the API refuses
/// to boot if it is. The client cannot authenticate itself under any build.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final TokenStorage _tokens = TokenStorage();

  late final ApiClient _client = ApiClient(
    tokens: _tokens,
    onSessionExpired: _clearLocalSession,
  );

  late final AuthApi _api = AuthApi(_client);

  TokenStorage get tokens => _tokens;

  /// Normalises user input to E.164, which is what the API requires.
  ///
  /// Without this, `9876543210`, `09876543210`, and `+919876543210` would
  /// become three different accounts for the same person.
  static String normalisePhone(String input, {String dialCode = '+91'}) {
    final trimmed = input.replaceAll(RegExp(r'[\s\-()]'), '');
    if (trimmed.startsWith('+')) return trimmed;

    final national = trimmed.startsWith('0') ? trimmed.substring(1) : trimmed;
    return '$dialCode$national';
  }

  /// Sends a verification code. Returns the challenge to pass to [verifyOtp].
  Future<OtpChallenge> requestOtp(String phone, {String dialCode = '+91'}) async {
    ApiConfig.assertConfigured();

    return _api.requestOtp(
      phone: normalisePhone(phone, dialCode: dialCode),
      installId: await _tokens.installId(),
    );
  }

  /// Verifies the code, stores the session, and records it locally.
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final session = await _api.verifyOtp(
      challengeId: challengeId,
      code: code,
      installId: await _tokens.installId(),
      appVersion: ApiConfig.appVersion,
    );

    // Credentials go to the Keychain / EncryptedSharedPreferences, never to
    // the local database or shared_preferences.
    await _tokens.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      deviceId: session.deviceId,
    );

    await _recordLocalSession(session.phone);

    return session;
  }

  /// Whether a usable session exists.
  ///
  /// Keyed on the presence of a refresh token, not on a local flag. The old
  /// `isLoggedIn` boolean in shared_preferences could be flipped by hand on a
  /// rooted device; a refresh token cannot be forged.
  Future<bool> isLoggedIn() => _tokens.hasSession();

  /// Signs out: revokes the device's tokens server-side, then clears locally.
  ///
  /// The server call is best-effort. If it fails — offline, expired token —
  /// the local session is cleared anyway, because a sign-out that appears to
  /// do nothing is worse than one that leaves a token to expire on its own.
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Intentionally ignored; local cleanup below is what the user sees.
    }

    await _clearLocalSession();
  }

  // ---------------------------------------------------------------- internals

  Future<void> _clearLocalSession() async {
    await _tokens.clearSession();

    // Ledger data is deliberately left intact. Entries that have not synced
    // yet exist only on this device, and discarding them because a token
    // expired would destroy a user's records.
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.userSessions.clear();
    });
  }

  Future<void> _recordLocalSession(String phone) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.userSessions.clear();
      await IsarService.isar.userSessions.put(
        UserSession()
          ..phoneNumber = phone
          ..isLoggedIn = true
          ..loginTime = DateTime.now(),
      );
    });
  }
}
