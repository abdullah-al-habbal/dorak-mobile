import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:dio/dio.dart';

class NetworkException extends ApiException {
  final DioExceptionType type;
  final bool retryable;

  const NetworkException({
    required this.type,
    required this.retryable,
    required super.message,
  }) : super(statusCode: 0, code: 'NETWORK_ERROR');
}
