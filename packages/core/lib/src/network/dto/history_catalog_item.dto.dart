import 'package:json_annotation/json_annotation.dart';

part 'history_catalog_item.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HistoryCatalogItemDto {
  final String id;
  final Map<String, String> name;

  const HistoryCatalogItemDto({
    required this.id,
    required this.name,
  });

  factory HistoryCatalogItemDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryCatalogItemDtoFromJson(json);
}