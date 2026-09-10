// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_detail.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchDetailDto _$BranchDetailDtoFromJson(Map<String, dynamic> json) =>
    BranchDetailDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      brandId: (json['brand_id'] as num).toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      compatibilityScore: (json['compatibility_score'] as num?)?.toDouble(),
      rank: (json['rank'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      chairsCount: (json['chairs_count'] as num?)?.toInt() ?? 0,
      barbers:
          (json['barbers'] as List<dynamic>?)
              ?.map((e) => BookingBarberDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      services:
          (json['services'] as List<dynamic>?)
              ?.map(
                (e) => BookingServiceDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
