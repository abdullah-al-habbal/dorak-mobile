// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  code: json['code'] as String,
  message: json['message'] as String?,
  timestamp: json['timestamp'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  meta: json['meta'] as Map<String, dynamic>?,
  errors: json['errors'],
);

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);
