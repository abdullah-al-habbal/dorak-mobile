import 'package:core/src/network/exceptions/api.exception.dart';

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  const ValidationException({
    required super.statusCode,
    required super.code,
    required super.message,
    required this.errors,
  });

  List<String>? errorsFor(String field) => errors[field];
}
