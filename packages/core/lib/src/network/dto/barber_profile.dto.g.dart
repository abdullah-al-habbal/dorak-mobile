// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barber_profile.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarberProfileDto _$BarberProfileDtoFromJson(Map<String, dynamic> json) =>
    BarberProfileDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isFreelancer: json['is_freelancer'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      travelRadius: (json['travel_radius'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      compatibilityScore: (json['compatibility_score'] as num?)?.toDouble(),
      rank: (json['rank'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => BarberServiceDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
