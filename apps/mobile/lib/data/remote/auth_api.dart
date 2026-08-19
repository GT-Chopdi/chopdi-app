import 'dart:io' show Platform;

import 'api_client.dart';

/// A pending OTP verification.
class OtpChallenge {
  const OtpChallenge({
    required this.challengeId,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
  });

  factory OtpChallenge.fromJson(Map<String, dynamic> json) => OtpChallenge(
        challengeId: json['challengeId'] as String,
        expiresInSeconds: json['expiresInSeconds'] as int? ?? 300,
        resendAfterSeconds: json['resendAfterSeconds'] as int? ?? 60,
      );

  final String challengeId;
  final int expiresInSeconds;
  final int resendAfterSeconds;
}

/// The result of a successful sign-in.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.deviceId,
    required this.userId,
    required this.phone,
    required this.isNewUser,
    required this.syncCursor,
    this.displayName,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map).cast<String, dynamic>();

    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      deviceId: json['deviceId'] as String,
      userId: user['id'] as String,
      phone: user['phone'] as String,
      displayName: user['displayName'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
      // Where sync should resume from. Always 0 until the change log exists.
      syncCursor: json['syncCursor'] as int? ?? 0,
    );
  }

  final String accessToken;
  final String refreshToken;
  final String deviceId;
  final String userId;
  final String phone;
  final String? displayName;
  final bool isNewUser;
  final int syncCursor;
}

/// Thin wrapper over the `/v1/auth` endpoints.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  static String get currentPlatform => Platform.isIOS ? 'ios' : 'android';

  /// Requests a verification code.
  ///
  /// The server answers identically for registered and unregistered numbers,
  /// so this reveals nothing about who already has an account.
  Future<OtpChallenge> requestOtp({
    required String phone,
    required String installId,
  }) async {
    final json = await _client.post(
      '/v1/auth/otp/request',
      body: {
        'phone': phone,
        'installId': installId,
        'platform': currentPlatform,
      },
    );

    return OtpChallenge.fromJson(json);
  }

  /// Verifies a code and returns a session.
  ///
  /// The phone number is taken from the challenge server-side, never from this
  /// request — a client cannot verify its own code and claim another identity.
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
    required String installId,
    required String appVersion,
  }) async {
    final json = await _client.post(
      '/v1/auth/otp/verify',
      body: {
        'challengeId': challengeId,
        'code': code,
        'installId': installId,
        'platform': currentPlatform,
        'appVersion': appVersion,
      },
    );

    return AuthSession.fromJson(json);
  }

  /// Revokes this device's tokens server-side. Local data is untouched.
  Future<void> logout() => _client.post('/v1/auth/logout');
}
