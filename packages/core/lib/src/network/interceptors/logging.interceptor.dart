import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final bool enabled;

  LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled && kDebugMode) {
      debugPrint(
        '--> ${options.method} ${options.baseUrl}${options.path}'
        '${options.queryParameters.isEmpty ? '' : ' ?${options.queryParameters}'}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enabled && kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled && kDebugMode) {
      debugPrint('<-- ${err.type.name} ${err.requestOptions.path} :: ${err.message}');
    }
    handler.next(err);
  }
}
