import 'dart:async';

import 'package:dio/dio.dart';

import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/exceptions/network.exception.dart';
import 'package:core/src/network/exceptions/validation.exception.dart';
import 'package:core/src/network/interceptors/auth.interceptor.dart';
import 'package:core/src/network/interceptors/locale.interceptor.dart';
import 'package:core/src/network/interceptors/logging.interceptor.dart';
import 'package:core/src/network/interceptors/retry.interceptor.dart';
import 'package:core/src/network/paginated_data.dto.dart';
import 'package:core/src/network/pagination_meta.dto.dart';

typedef JsonParser<T> = T Function(dynamic json);

class ApiClient {
  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 30);

  final Dio dio;
  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  bool _unauthorizedFired = false;

  Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  bool get unauthorizedSignalFired => _unauthorizedFired;

  ApiClient({
    required String baseUrl,
    Dio? dio,
    String Function()? localeResolver,
    Future<String?> Function()? tokenProvider,
    bool enableLogging = true,
    int maxRetries = 3,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: defaultConnectTimeout,
                receiveTimeout: defaultReceiveTimeout,
              ),
            ) {
    this.dio.interceptors
      ..add(LocaleInterceptor(resolver: localeResolver ?? () => 'en'))
      ..addAll([
        if (tokenProvider != null)
          AuthInterceptor(
            tokenProvider: tokenProvider,
            reportUnauthorized: reportUnauthorized,
          ),
        if (enableLogging) LoggingInterceptor(),
        RetryInterceptor(dio: this.dio, maxRetries: maxRetries),
      ]);
  }

  void reportUnauthorized() {
    if (_unauthorizedFired) return;
    _unauthorizedFired = true;
    _unauthorizedController.add(null);
  }

  void resetUnauthorizedSignal() {
    _unauthorizedFired = false;
  }

  void dispose() {
    _unauthorizedController.close();
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required JsonParser<T> parser,
  }) async {
    final response =
        await _guard(() => dio.get<dynamic>(path, queryParameters: queryParameters));
    return _parse(response, parser);
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required JsonParser<T> parser,
  }) async {
    final response = await _guard(
      () => dio.post<dynamic>(path, data: data, queryParameters: queryParameters),
    );
    return _parse(response, parser);
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required JsonParser<T> parser,
  }) async {
    final response = await _guard(
      () => dio.put<dynamic>(path, data: data, queryParameters: queryParameters),
    );
    return _parse(response, parser);
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required JsonParser<T> parser,
  }) async {
    final response = await _guard(
      () => dio.patch<dynamic>(path, data: data, queryParameters: queryParameters),
    );
    return _parse(response, parser);
  }

  Future<void> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _guard(
      () => dio.delete<dynamic>(path, data: data, queryParameters: queryParameters),
    );
    _throwIfFailure(_bodyOf(response), response.statusCode ?? 200);
  }

  Future<PaginatedData<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required JsonParser<T> itemParser,
  }) async {
    final response =
        await _guard(() => dio.get<dynamic>(path, queryParameters: queryParameters));
    final body = _bodyOf(response);
    _throwIfFailure(body, response.statusCode ?? 200);
    final rawData = body['data'];
    final items = (rawData is List ? rawData : const <dynamic>[])
        .map(itemParser)
        .toList();
    final rawMeta = body['meta'];
    final pagination =
        rawMeta is Map<String, dynamic> ? rawMeta['pagination'] : null;
    final meta = pagination is Map<String, dynamic>
        ? PaginationMeta.fromJson(pagination)
        : const PaginationMeta.empty();

    return PaginatedData(data: items, meta: meta);
  }

  Future<Response<dynamic>> _guard(
    Future<Response<dynamic>> Function() action,
  ) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (e.response != null && body is Map<String, dynamic>) {
        throw _exceptionFrom(body, e.response!.statusCode ?? 0);
      }
      throw NetworkException(
        type: e.type,
        retryable: RetryInterceptor.isRetryable(e),
        message: e.message ?? 'Network request failed',
      );
    }
  }

  Map<String, dynamic> _bodyOf(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode ?? 0,
        code: 'INVALID_RESPONSE',
        message: 'Unexpected response payload',
      );
    }
    return data;
  }

  T _parse<T>(Response<dynamic> response, JsonParser<T> parser) {
    final body = _bodyOf(response);
    _throwIfFailure(body, response.statusCode ?? 200);
    return parser(body['data']);
  }

  void _throwIfFailure(Map<String, dynamic> body, int statusCode) {
    final success = body['success'] as bool? ?? true;
    final codeStatus = body['statusCode'] as int? ?? statusCode;
    if (!success || codeStatus >= 400) {
      throw _exceptionFrom(body, codeStatus);
    }
  }

  ApiException _exceptionFrom(Map<String, dynamic> body, int statusCode) {
    final code = body['code'] as String? ?? 'UNKNOWN';
    final message = body['message'] as String? ?? 'Request failed';

    if (code == 'VALIDATION_FAILED') {
      final errors = <String, List<String>>{};
      final rawErrors = body['errors'];
      if (rawErrors is Map<String, dynamic>) {
        rawErrors.forEach((key, value) {
          errors[key] = value is List
              ? value.map((e) => e.toString()).toList()
              : <String>[value.toString()];
        });
      }
      return ValidationException(
        statusCode: statusCode,
        code: code,
        message: message,
        errors: errors,
      );
    }

    return ApiException(statusCode: statusCode, code: code, message: message);
  }
}
