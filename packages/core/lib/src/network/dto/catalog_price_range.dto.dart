import 'package:json_annotation/json_annotation.dart';

part 'catalog_price_range.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CatalogPriceRangeDto {
  final num? min;
  final num? max;
  final String? currency;

  const CatalogPriceRangeDto({this.min, this.max, this.currency});

  factory CatalogPriceRangeDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogPriceRangeDtoFromJson(json);
}