import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PaginationMeta {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  const PaginationMeta.empty()
      : total = 0,
        count = 0,
        perPage = 0,
        currentPage = 1,
        totalPages = 1;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}
