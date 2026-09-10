import 'package:json_annotation/json_annotation.dart';

part 'currency.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CurrencyDto {
  final String id;
  final String code;
  final Map<String, String> name;
  final String? symbol;
  final bool isDefault;

  const CurrencyDto({
    required this.id,
    required this.code,
    this.name = const {},
    this.symbol,
    this.isDefault = false,
  });

  factory CurrencyDto.fromJson(Map<String, dynamic> json) =>
      _$CurrencyDtoFromJson(json);
}