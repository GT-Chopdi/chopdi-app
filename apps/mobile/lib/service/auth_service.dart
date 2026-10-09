import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/config/api_config.dart';
import '../data/remote/api_client.dart';
import '../data/remote/auth_api.dart';
import '../data/remote/token_storage.dart';
import '../model/user_session.dart';
import 'isar_service.dart';
import 'sync_service.dart'; // Added SyncService import

/// Authentication against the Chopdi API.
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

  ApiClient get client => _client;

  // ---------------------------------------------------------------------------
  // Logging
  // ---------------------------------------------------------------------------

  void _log(String message) {
    developer.log(
      message,
      name: 'AuthService',
    );
  }

  void _logApi({
    required String method,
    required String endpoint,
  }) {
    _log('========================================');
    _log('API REQUEST');
    _log('METHOD: $method');
    _log('ENDPOINT: $endpoint');
    _log('BASE URL: ${ApiConfig.baseUrl}');
    _log('FULL URL: ${ApiConfig.baseUrl}$endpoint');
    _log('ENVIRONMENT: ${ApiConfig.appEnv}');
    _log('APP VERSION: ${ApiConfig.appVersion}');
    _log('========================================');
  }

  /// Logs a token for local debugging.
  ///
  /// WARNING:
  /// Remove full token logging before production/release.
  void _logToken({
    required String name,
    required String token,
  }) {
    if (token.isEmpty) {
      _log('$name: EMPTY');
      return;
    }

    debugPrint('[$name] $token');
  }

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  /// Normalises user input to E.164.
  static String normalisePhone(
      String input, {
        String dialCode = '+91',
      }) {
    final trimmed = input.replaceAll(
      RegExp(r'[\s\-()]'),
      '',
    );

    if (trimmed.startsWith('+')) {
      return trimmed;
    }

    final national =
    trimmed.startsWith('0') ? trimmed.substring(1) : trimmed;

    return '$dialCode$national';
  }

  String _maskPhone(String phone) {
    if (phone.length < 4) {
      return '****';
    }

    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}';
  }

  // ---------------------------------------------------------------------------
  // Request OTP
  // ---------------------------------------------------------------------------

  /// Sends a verification code.
  Future<OtpChallenge> requestOtp(
      String phone, {
        String dialCode = '+91',
      }) async {
    _log('========================================');
    _log('requestOtp() STARTED');
    _log('========================================');

    try {
      ApiConfig.assertConfigured();

      _log('Environment: ${ApiConfig.appEnv}');
      _log('API configured successfully');
      _log('Base URL: ${ApiConfig.baseUrl}');
      _log('App Version: ${ApiConfig.appVersion}');

      final normalisedPhone = normalisePhone(
        phone,
        dialCode: dialCode,
      );

      _log('Original Phone: ${_maskPhone(phone)}');
      _log('Normalised Phone: ${_maskPhone(normalisedPhone)}');

      _logApi(
        method: 'POST',
        endpoint: '/v1/auth/otp/request',
      );

      final installId = await _tokens.installId();

      _log('Install ID obtained');
      _log('Install ID: $installId');

      _log('Calling AuthApi.requestOtp()...');

      final challenge = await _api.requestOtp(
        phone: normalisedPhone,
        installId: installId,
      );

      _log('API RESPONSE: POST /v1/auth/otp/request');
      _log('OTP request successful');
      _log('Challenge ID received');
      _log('Challenge ID: ${challenge.challengeId}');
      _log('Phone: ${_maskPhone(normalisedPhone)}');

      _log('========================================');
      _log('requestOtp() COMPLETED');
      _log('========================================');

      return challenge;
    } catch (e, stackTrace) {
      _log('========================================');
      _log('requestOtp() FAILED');
      _log('========================================');

      _log('API FAILED: POST /v1/auth/otp/request');
      _log('Error Type: ${e.runtimeType}');
      _log('Error: $e');

      developer.log(
        'OTP request error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  /// Verifies the code, stores the session, and records it locally.
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    _log('========================================');
    _log('verifyOtp() STARTED');
    _log('========================================');

    _log('Challenge ID: $challengeId');
    _log('OTP length: ${code.length}');
    _log('OTP verification request started');

    _logApi(
      method: 'POST',
      endpoint: '/v1/auth/otp/verify',
    );

    try {
      // -------------------------------------------------------
      // Install ID
      // -------------------------------------------------------

      _log('Getting Install ID...');

      final installId = await _tokens.installId();

      _log('Install ID obtained');
      _log('Install ID: $installId');

      // -------------------------------------------------------
      // API Request
      // -------------------------------------------------------

      _log('Calling AuthApi.verifyOtp()...');

      final session = await _api.verifyOtp(
        challengeId: challengeId,
        code: code,
        installId: installId,
        appVersion: ApiConfig.appVersion,
      );

      _log('API RESPONSE: POST /v1/auth/otp/verify');
      _log('OTP verification successful');
      _log('Session received from server');

      // -------------------------------------------------------
      // Session information
      // -------------------------------------------------------

      _log('Session phone: ${_maskPhone(session.phone)}');
      _log('Session device ID: ${session.deviceId}');
      _log('Access token received: ${session.accessToken.isNotEmpty}');
      _log('Refresh token received: ${session.refreshToken.isNotEmpty}');

      // -------------------------------------------------------
      // DEBUG TOKEN LOGGING
      // -------------------------------------------------------

      _log('----------------------------------------');
      _log('AUTH TOKENS');
      _log('----------------------------------------');

      _logToken(
        name: 'ACCESS TOKEN',
        token: session.accessToken,
      );

      _logToken(
        name: 'REFRESH TOKEN',
        token: session.refreshToken,
      );

      _log('DEVICE ID: ${session.deviceId}');

      _log('----------------------------------------');

      // -------------------------------------------------------
      // Save Session
      // -------------------------------------------------------

      _log('Saving session tokens...');

      await _tokens.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        deviceId: session.deviceId,
      );

      _log('Session tokens saved successfully');

      // -------------------------------------------------------
      // Verify saved token
      // -------------------------------------------------------

      _log('Checking saved access token...');

      final savedAccessToken = await _tokens.accessToken;

      if (savedAccessToken != null && savedAccessToken.isNotEmpty) {
        _log('Saved access token exists');
        _logToken(
          name: 'SAVED ACCESS TOKEN',
          token: savedAccessToken,
        );
      } else {
        _log('WARNING: Saved access token is EMPTY');
      }

      // -------------------------------------------------------
      // Local session
      // -------------------------------------------------------

      _log('Recording local user session...');

      await _recordLocalSession(
        session.phone,
      );

      _log('Local user session recorded');

      // -------------------------------------------------------
      // Initial Sync Pull
      // -------------------------------------------------------

      _log('Triggering initial sync pull for new device...');
      try {
        await SyncService.instance.pullData();
      } catch (e) {
        _log('Sync pull failed after login, will retry later: $e');
      }

      _log('========================================');
      _log('verifyOtp() COMPLETED SUCCESSFULLY');
      _log('========================================');

      return session;
    } catch (e, stackTrace) {
      _log('========================================');
      _log('verifyOtp() FAILED');
      _log('========================================');

      _log('API FAILED: POST /v1/auth/otp/verify');
      _log('Error Type: ${e.runtimeType}');
      _log('OTP verification failed: $e');

      developer.log(
        'OTP verification error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Login status
  // ---------------------------------------------------------------------------

  /// Whether a usable session exists.
  Future<bool> isLoggedIn() async {
    _log('========================================');
    _log('Checking login session');
    _log('========================================');

    try {
      final loggedIn = await _tokens.hasSession();

      _log('isLoggedIn: $loggedIn');

      if (loggedIn) {
        final accessToken = await _tokens.accessToken;

        _log(
          'Access token exists: '
              '${accessToken != null && accessToken.isNotEmpty}',
        );
      } else {
        _log('No active session found');
      }

      return loggedIn;
    } catch (e, stackTrace) {
      _log('isLoggedIn() FAILED');
      _log('Error: $e');

      developer.log(
        'Login status error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Signs out.

  /// Signs out only after the server confirms logout.
  Future<void> logout() async {
    _log('========================================');
    _log('logout() STARTED');
    _log('========================================');

    _logApi(
      method: 'POST',
      endpoint: '/v1/auth/logout',
    );

    try {
      _log('Calling server logout...');

      await _api.logout();

      _log('API RESPONSE: POST /v1/auth/logout');
      _log('Server logout successful');
    } catch (e, stackTrace) {
      _log('API FAILED: POST /v1/auth/logout');
      _log('Server logout failed: $e');

      developer.log(
        'Logout API error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      // Do not clear tokens or local data when server logout fails.
      rethrow;
    }

    // Clear local data ONLY after server logout succeeds.
    _log('Clearing local session...');

    await _clearLocalSession();

    _log('Local session cleared');
    _log('logout() COMPLETED');
  }


  // ---------------------------------------------------------------------------
  // Local session cleanup
  // ---------------------------------------------------------------------------

  Future<void> _clearLocalSession() async {
    _log('Clearing local authentication session');
    try {
      _log('Clearing TokenStorage...');

      await _tokens.clearSession();

      _log('TokenStorage cleared');

      _log('Clearing Sync cursor...');

      await SyncService.instance.clearLocalCursor();

      _log('Sync cursor cleared');

      _log('Clearing Isar user session...');

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.userSessions.clear();
      });

      _log('Isar user session cleared');
      _log('Local authentication session cleared');
    } catch (e, stackTrace) {
      _log('Failed to clear local authentication session');
      _log('Error: $e');

      developer.log(
        'Local session cleanup error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }


  // ---------------------------------------------------------------------------
  // Local session record
  // ---------------------------------------------------------------------------

  Future<void> _recordLocalSession(
      String phone,
      ) async {
    _log('Recording local user session');
    _log('Phone: ${_maskPhone(phone)}');

    try {
      await IsarService.isar.writeTxn(() async {
        _log('Clearing previous local sessions...');

        await IsarService.isar.userSessions.clear();

        _log('Creating new local user session...');

        await IsarService.isar.userSessions.put(
          UserSession()
            ..phoneNumber = phone
            ..isLoggedIn = true
            ..loginTime = DateTime.now(),
        );
      });

      _log('Local user session saved successfully');
      _log('Login time: ${DateTime.now()}');
    } catch (e, stackTrace) {
      _log('Failed to record local user session');
      _log('Error: $e');

      developer.log(
        'Local user session error',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}