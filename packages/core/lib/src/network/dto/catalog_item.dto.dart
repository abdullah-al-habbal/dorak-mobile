import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/catalog_price_range.dto.dart';

part 'catalog_item.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CatalogItemDto {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final CatalogPriceRangeDto? priceRange;
  final List<String> faceShapes;
  final String? stylePeriod;
  final bool isActive;

  const CatalogItemDto({
    required this.id,
    required this.name,
    this.description = const {},
    this.priceRange,
    this.faceShapes = const [],
    this.stylePeriod,
    this.isActive = true,
  });

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemDtoFromJson(json);
}