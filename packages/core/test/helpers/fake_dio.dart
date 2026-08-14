import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

class FakeDioInterceptor extends Interceptor {
  FakeDioInterceptor(this.handler);

  final Response<dynamic> Function(RequestOptions options) handler;

  int callCount = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    callCount++;
    handler.resolve(this.handler(options));
  }
}

FakeDioInterceptor fakeDio({
  required Response<dynamic> Function(RequestOptions options) handler,
}) =>
    FakeDioInterceptor(handler);

ApiClient clientWith(FakeDioInterceptor fake, {int maxRetries = 1}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..interceptors.add(fake);
  return ApiClient(
    baseUrl: 'http://test/api/v1',
    dio: dio,
    enableLogging: false,
    maxRetries: maxRetries,
  );
}

Response<dynamic> jsonResponse(
  RequestOptions options, {
  Object? data,
  int statusCode = 200,
}) {
  return Response<dynamic>(
    requestOptions: options,
    statusCode: statusCode,
    data: data,
  );
}

Map<String, dynamic> successEnvelope({
  Object? data,
  Map<String, dynamic>? meta,
  int statusCode = 200,
  String code = 'SUCCESS',
}) {
  return {
    'success': true,
    'statusCode': statusCode,
    'code': code,
    'message': 'Success',
    'timestamp': '2026-08-14T00:00:00.000Z',
    'data': data,
    'meta': ?meta,
  };
}

Map<String, dynamic> errorEnvelope({
  String code = 'RESOURCE_NOT_FOUND',
  int statusCode = 404,
  String message = 'Not found',
  Object? errors,
}) {
  return {
    'success': false,
    'statusCode': statusCode,
    'code': code,
    'message': message,
    'timestamp': '2026-08-14T00:00:00.000Z',
    'errors': ?errors,
  };
}

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    callCount++;
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ApiClient clientWithStatuses(
  List<int> statuses, {
  int maxRetries = 3,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
  late final FakeHttpClientAdapter adapter;
  adapter = FakeHttpClientAdapter((options) {
    final index =
        adapter.callCount - 1 < statuses.length ? adapter.callCount - 1 : statuses.length - 1;
    final status = statuses[index];
    final body = status >= 400
        ? errorEnvelope(code: 'SERVER_ERROR', statusCode: status)
        : successEnvelope(data: {'ok': true});
    return Future.value(
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {'content-type': ['application/json']},
      ),
    );
  });
  dio.httpClientAdapter = adapter;
  return ApiClient(
    baseUrl: 'http://test/api/v1',
    dio: dio,
    enableLogging: false,
    maxRetries: maxRetries,
  );
}
