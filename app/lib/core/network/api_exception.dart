class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() {
    return 'ApiException('
        'statusCode: $statusCode, '
        'message: $message'
        ')';
  }
}

class NetworkException extends ApiException {
  const NetworkException({required super.message});
}

class TimeoutException extends ApiException {
  const TimeoutException({required super.message});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized request'});
}

class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'Access forbidden'});
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found'});
}

class ValidationException extends ApiException {
  const ValidationException({required super.message, super.data});
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong on the server',
    super.statusCode,
    super.data,
  });
}
