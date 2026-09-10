// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barber_service.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarberServiceDto _$BarberServiceDtoFromJson(Map<String, dynamic> json) =>
    BarberServiceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currencyId: json['currency_id'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      atHome: json['at_home'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
