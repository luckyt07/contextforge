import 'package:dio/dio.dart';

import '../../api_endpoints.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'network_logger.dart';
import 'token_refresh_interceptor.dart';

class ApiService {
  late final Dio _dio;

  ApiService({
    required String baseUrl,
    TokenProvider? tokenProvider,
    RefreshTokenProvider? refreshTokenProvider,
    TokensRefreshed? onTokensRefreshed,
    RefreshFailureHandler? onRefreshFailure,
    bool enableLogging = false,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    );
    _dio = Dio(options);
    final refreshDio = Dio(options);

    if (tokenProvider != null) {
      _dio.interceptors.add(AuthInterceptor(tokenProvider: tokenProvider));
    }

    if (tokenProvider != null &&
        refreshTokenProvider != null &&
        onTokensRefreshed != null &&
        onRefreshFailure != null) {
      _dio.interceptors.add(
        TokenRefreshInterceptor(
          dio: _dio,
          refreshDio: refreshDio,
          refreshPath: ApiEndPoints.refresh,
          tokenProvider: tokenProvider,
          refreshTokenProvider: refreshTokenProvider,
          onTokensRefreshed: onTokensRefreshed,
          onRefreshFailure: onRefreshFailure,
        ),
      );
    }

    _dio.interceptors.add(ErrorInterceptor());

    _dio.interceptors.add(NetworkLogger(enabled: enableLogging));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Dio get client => _dio;
}
