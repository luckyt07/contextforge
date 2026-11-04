import 'package:dio/dio.dart';

import 'api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  ApiException _mapException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(message: 'Request timed out');

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Unable to connect to the server',
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(statusCode: statusCode, data: data);

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Invalid server certificate');

      case DioExceptionType.unknown:
        return NetworkException(
          message: error.message ?? 'Unknown network error',
        );
      case DioExceptionType.transformTimeout:
        return const NetworkException(message: 'Transform timeout');
    }
  }

  ApiException _mapStatusCode({required int? statusCode, dynamic data}) {
    final message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Invalid request',
          data: data,
        );

      case 401:
        return UnauthorizedException(message: message ?? 'Session expired');

      case 403:
        return ForbiddenException(message: message ?? 'Access forbidden');

      case 404:
        return NotFoundException(message: message ?? 'Resource not found');

      case 422:
        return ValidationException(
          message: message ?? 'Validation failed',
          data: data,
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message ?? 'Server error',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ServerException(
          message: message ?? 'Request failed',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String) {
        return message;
      }

      final error = data['error'];

      if (error is String) {
        return error;
      }
    }

    return null;
  }
}
