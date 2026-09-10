// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogItemDto _$CatalogItemDtoFromJson(Map<String, dynamic> json) =>
    CatalogItemDto(
      id: json['id'] as String,
      name: Map<String, String>.from(json['name'] as Map),
      description:
          (json['description'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      priceRange: json['price_range'] == null
          ? null
          : CatalogPriceRangeDto.fromJson(
              json['price_range'] as Map<String, dynamic>,
            ),
      faceShapes:
          (json['face_shapes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      stylePeriod: json['style_period'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
