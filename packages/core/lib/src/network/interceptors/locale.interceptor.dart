import 'package:dio/dio.dart';

class LocaleInterceptor extends Interceptor {
  final String Function() resolver;

  LocaleInterceptor({required this.resolver});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('Accept', () => 'application/json');
    options.headers.putIfAbsent('Accept-Language', resolver);
    handler.next(options);
  }
}
