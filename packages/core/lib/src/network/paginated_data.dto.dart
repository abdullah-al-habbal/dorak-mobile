import 'package:core/src/network/pagination_meta.dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_data.dto.g.dart';

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PaginatedData<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedData({required this.data, required this.meta});

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedDataFromJson<T>(json, fromJsonT);
}
