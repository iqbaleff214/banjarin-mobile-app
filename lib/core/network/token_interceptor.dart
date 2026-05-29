import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';

class TokenInterceptor extends QueuedInterceptorsWrapper {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;

  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/verify-email',
    '/auth/refresh',
  ];

  TokenInterceptor({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
  })  : _tokenStorage = tokenStorage,
        _refreshDio = refreshDio;

  @visibleForTesting
  bool isPublicPath(String path) {
    return _publicPaths.any((p) => path.endsWith(p));
  }

  /// Attaches Bearer token to [options] if the path is protected and a token
  /// is available. Returns `true` when a token was attached.
  @visibleForTesting
  Future<bool> attachToken(RequestOptions options) async {
    if (isPublicPath(options.path)) return false;
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return false;
    options.headers['Authorization'] = 'Bearer $token';
    return true;
  }

  /// Attempts a token refresh for a 401 error on a protected path.
  /// Resolves [handler] with the retried response on success, or rejects it
  /// (after clearing tokens) on failure.
  @visibleForTesting
  Future<void> handleRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      await _tokenStorage.clearTokens();
      handler.next(err);
      return;
    }

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _refreshDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _tokenStorage.clearTokens();
      handler.next(err);
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await attachToken(options);
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;

    if (!isUnauthorized || isPublicPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    await handleRefresh(err, handler);
  }
}
