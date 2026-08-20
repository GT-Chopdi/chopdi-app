import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Persistent home for credentials and device identity.
///
/// Backed by the Keychain on iOS and EncryptedSharedPreferences on Android —
/// **not** `shared_preferences`, which is plain XML readable by anyone with a
/// rooted device or an ADB backup. The previous implementation kept a plain
/// `isLoggedIn` boolean there, which meant "log me in" was a one-line edit on
/// a rooted phone.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // v11 encrypts by default (AES-GCM with RSA key wrapping), so
              // the old `encryptedSharedPreferences: true` flag no longer
              // exists — plaintext storage is simply not an option any more.
              aOptions: AndroidOptions(),

              // `first_unlock_this_device` rather than `first_unlock`: the
              // suffix keeps these items out of iCloud backups, so credentials
              // never ride a restore onto a different handset. That matches
              // how the server treats them — tokens are bound to a device id
              // and would be rejected there anyway — and it means a restored
              // phone correctly registers as a new install.
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'chopdi.accessToken';
  static const _kRefreshToken = 'chopdi.refreshToken';
  static const _kDeviceId = 'chopdi.deviceId';
  static const _kInstallId = 'chopdi.installId';

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);
  Future<String?> get deviceId => _storage.read(key: _kDeviceId);

  /// A stable identifier for this installation.
  ///
  /// Minted once and kept here rather than in the local database, so it
  /// survives an Isar wipe or corruption. That is what lets the app recognise
  /// "my data is gone but I am still the same install" and enter recovery mode
  /// — pulling from the server instead of pushing local state that no longer
  /// has its outbox.
  Future<String> installId() async {
    final existing = await _storage.read(key: _kInstallId);
    if (existing != null && existing.isNotEmpty) return existing;

    final fresh = const Uuid().v7();
    await _storage.write(key: _kInstallId, value: fresh);
    return fresh;
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kDeviceId, value: deviceId),
    ]);
  }

  /// Replaces the token pair after a refresh, leaving device identity alone.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  /// Clears credentials on sign-out.
  ///
  /// [_kInstallId] is deliberately preserved: it identifies the handset, not
  /// the session, and regenerating it on every sign-out would create a new
  /// device row server-side each time.
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kDeviceId),
    ]);
  }

  Future<bool> hasSession() async {
    final token = await refreshToken;
    return token != null && token.isNotEmpty;
  }
}
