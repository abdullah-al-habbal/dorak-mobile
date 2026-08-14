import 'package:core/src/network/pagination_meta.dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response.dto.g.dart';

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String code;
  final String? message;
  final String? timestamp;
  final T? data;
  final Map<String, dynamic>? meta;
  final dynamic errors;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.code,
    this.message,
    this.timestamp,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson<T>(json, fromJsonT);

  PaginationMeta? get pagination {
    final raw = meta?['pagination'];
    if (raw is! Map<String, dynamic>) return null;
    return PaginationMeta.fromJson(raw);
  }
}
