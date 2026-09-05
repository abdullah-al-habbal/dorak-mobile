// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchDto _$BranchDtoFromJson(Map<String, dynamic> json) => BranchDto(
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
);
