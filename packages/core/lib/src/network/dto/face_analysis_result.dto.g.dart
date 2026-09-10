// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_analysis_result.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaceAnalysisResultDto _$FaceAnalysisResultDtoFromJson(
  Map<String, dynamic> json,
) => FaceAnalysisResultDto(
  id: json['id'] as String,
  faceProfileId: json['face_profile_id'] as String,
  detectedFaceShape: json['detected_face_shape'] as String,
  confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0,
  recommendedCatalogItemIds:
      (json['recommended_catalog_item_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  computedAt: json['computed_at'] == null
      ? null
      : DateTime.parse(json['computed_at'] as String),
  faceProfile: json['face_profile'] == null
      ? null
      : FacePhotoDto.fromJson(json['face_profile'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);
