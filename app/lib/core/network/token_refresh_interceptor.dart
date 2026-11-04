import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

typedef RefreshTokenProvider = Future<String?> Function();
typedef TokensRefreshed =
    Future<void> Function(String accessToken, String refreshToken);
typedef RefreshFailureHandler = Future<void> Function();

/// Refreshes one expired access-token session and retries each failed request
/// once. The refresh request uses a separate Dio instance to avoid recursion.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required this.refreshPath,
    required this.tokenProvider,
    required this.refreshTokenProvider,
    required this.onTokensRefreshed,
    required this.onRefreshFailure,
  }) : _dio = dio,
       _refreshDio = refreshDio;

  final Dio _dio;
  final Dio _refreshDio;
  final String refreshPath;
  final TokenProvider tokenProvider;
  final RefreshTokenProvider refreshTokenProvider;
  final TokensRefreshed onTokensRefreshed;
  final RefreshFailureHandler onRefreshFailure;

  Future<bool>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        request.extra['skipTokenRefresh'] != true &&
        request.extra['retriedAfterRefresh'] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    // A request that used an older token can be retried after another request
    // has already completed the rotation, without rotating again.
    final currentToken = await tokenProvider();
    if (currentToken != null &&
        currentToken.isNotEmpty &&
        currentToken != request.extra['accessToken']) {
      await _retry(request, handler);
      return;
    }

    final refreshed = await (_refreshing ??= _refreshTokens());
    if (!refreshed) {
      handler.next(err);
      return;
    }

    await _retry(request, handler);
  }

  Future<bool> _refreshTokens() async {
    try {
      final refreshToken = await refreshTokenProvider();
      if (refreshToken == null || refreshToken.isEmpty) {
        await onRefreshFailure();
        return false;
      }

      // FastAPI's `refresh_token: str = Body(...)` expects a JSON string,
      // rather than an object containing a refresh_token property.
      final response = await _refreshDio.post<Map<String, dynamic>>(
        refreshPath,
        data: jsonEncode(refreshToken),
        options: Options(extra: {'skipTokenRefresh': true}),
      );
      final data = response.data;
      final accessToken = data?['access_token'];
      final newRefreshToken = data?['refresh_token'];
      if (accessToken is! String || newRefreshToken is! String) {
        await onRefreshFailure();
        return false;
      }

      await onTokensRefreshed(accessToken, newRefreshToken);
      return true;
    } catch (_) {
      await onRefreshFailure();
      return false;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _retry(
    RequestOptions request,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      request.extra['retriedAfterRefresh'] = true;
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (error) {
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(DioException(requestOptions: request, error: error));
      }
    }
  }
}
