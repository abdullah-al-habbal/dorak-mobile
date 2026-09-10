// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyDto _$CurrencyDtoFromJson(Map<String, dynamic> json) => CurrencyDto(
  id: json['id'] as String,
  code: json['code'] as String,
  name:
      (json['name'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  symbol: json['symbol'] as String?,
  isDefault: json['is_default'] as bool? ?? false,
);
