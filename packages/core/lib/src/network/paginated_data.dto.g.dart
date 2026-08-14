// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_data.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedData<T> _$PaginatedDataFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedData<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);
