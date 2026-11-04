import 'package:dio/dio.dart';

class NetworkLogger extends Interceptor {
  final bool enabled;

  NetworkLogger({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      print('[REQUEST] ${options.method} ${options.uri}');

      if (options.data != null) {
        print('[REQUEST DATA] ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      print(
        '[RESPONSE] '
        '${response.statusCode} '
        '${response.requestOptions.uri}',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      print(
        '[ERROR] '
        '${err.response?.statusCode} '
        '${err.requestOptions.uri}',
      );

      print('[ERROR DATA] ${err.response?.data}');
    }

    handler.next(err);
  }
}
