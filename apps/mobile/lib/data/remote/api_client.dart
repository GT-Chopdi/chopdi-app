// `prefer_initializing_formals` would have us write `required this._tokens`,
// which in Dart creates a *private* named parameter — unusable from any other
// file, since privacy is library-scoped. Public names with an initializer list
// keep the constructor callable.
// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// HTTP client for the Chopdi API.
///
/// Owns three things the rest of the app should never repeat: attaching
/// credentials, refreshing an expired access token, and turning transport
/// failures into a single [ApiException] shape.
class ApiClient {
  ApiClient({
    required TokenStorage tokens,
    Dio? dio,
    Future<void> Function()? onSessionExpired,
  })  : _tokens = tokens,
        _onSessionExpired = onSessionExpired,
        _dio = dio ?? Dio(),
        // A bare client with no interceptors, used only to refresh. Refreshing
        // through the main client would re-enter the same error handler and
        // recurse.
        _refreshDio = Dio() {
    final options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    _dio.options = options;
    _refreshDio.options = options;

    // Queued, not plain, interceptors. This is load-bearing: several requests
    // can fail with 401 at once, and a plain interceptor would let each start
    // its own refresh. The server rotates refresh tokens and treats a second
    // use of one as theft — it revokes the entire token family — so parallel
    // refreshes would log the user out precisely when everything was fine.
    // Queueing serialises them so exactly one refresh happens.
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _attachCredentials,
        onError: _handleError,
      ),
    );
  }

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokens;
  final Future<void> Function()? _onSessionExpired;

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>(path, data: body));

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  // ---------------------------------------------------------------- internals

  Future<void> _attachCredentials(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokens.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    final deviceId = await _tokens.deviceId;
    if (deviceId != null && deviceId.isNotEmpty) {
      options.headers['X-Device-Id'] = deviceId;
    }

    // Only present while the server runs in dev-auth mode; ignored otherwise.
    if (ApiConfig.devKey.isNotEmpty) {
      options.headers['X-Dev-Key'] = ApiConfig.devKey;
    }

    options.headers['X-App-Version'] = ApiConfig.appVersion;

    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = error.response?.statusCode == 401;
    final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');

    if (!isUnauthorized || isRefreshCall) {
      return handler.next(error);
    }

    final refreshed = await _refreshSession(error.requestOptions);
    if (!refreshed) {
      return handler.next(error);
    }

    try {
      final retried = await _retry(error.requestOptions);
      return handler.resolve(retried);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Obtains a new token pair. Returns false when the session is unrecoverable.
  Future<bool> _refreshSession(RequestOptions failed) async {
    final refreshToken = await _tokens.refreshToken;
    final deviceId = await _tokens.deviceId;

    if (refreshToken == null || deviceId == null) return false;

    // Another queued request may already have refreshed while this one waited.
    // Spending a second rotation here would be wasteful and, worse, is the
    // exact pattern the server reads as a stolen token. If the stored access
    // token no longer matches the one this request carried, a refresh has
    // already happened — just retry.
    final current = await _tokens.accessToken;
    final used = failed.headers['Authorization'] as String?;

    if (current != null && used != null && used != 'Bearer $current') {
      return true;
    }

    try {
      final response = await _refreshDio.post<dynamic>(
        '/v1/auth/refresh',
        data: {'refreshToken': refreshToken, 'deviceId': deviceId},
        options: Options(
          headers: ApiConfig.devKey.isNotEmpty
              ? {'X-Dev-Key': ApiConfig.devKey}
              : null,
        ),
      );

      final body = (response.data as Map).cast<String, dynamic>();

      await _tokens.updateTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );

      return true;
    } on DioException catch (error) {
      final failure = ApiException.fromResponse(
        error.response?.statusCode,
        error.response?.data,
      );

      // REFRESH_REUSED / REFRESH_INVALID / DEVICE_REVOKED mean this session is
      // finished. Clear credentials so the app stops retrying — but never
      // touch local ledger data. Losing a user's unsynced entries because a
      // token expired would be far worse than asking them to sign in again.
      if (failure.requiresReauth || error.response?.statusCode == 401) {
        await _tokens.clearSession();
        await _onSessionExpired?.call();
      }

      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final accessToken = await _tokens.accessToken;
    final headers = Map<String, dynamic>.from(options.headers);

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return _dio.fetch<dynamic>(
      options.copyWith(headers: headers),
    );
  }

  /// Runs a request and normalises every failure into [ApiException].
  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;

      // 204 No Content (logout) has no body.
      if (data == null || (data is String && data.isEmpty)) return const {};

      if (data is Map) return data.cast<String, dynamic>();

      throw ApiException(
        code: 'UNEXPECTED_RESPONSE',
        message: 'Server returned an unexpected response.',
        permanent: false,
      );
    } on DioException catch (error) {
      // No response at all: DNS failure, no connectivity, or a timeout. A
      // timeout is deliberately *not* treated as failure — the server may have
      // processed the request and only the reply was lost. Callers retry, and
      // idempotency on the server makes that safe.
      if (error.response == null) {
        throw ApiException.network(error.error ?? error);
      }

      throw ApiException.fromResponse(
        error.response?.statusCode,
        error.response?.data,
      );
    }
  }
}
