import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/face_photo.dto.dart';

part 'face_analysis_result.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FaceAnalysisResultDto extends Equatable {
  final String id;
  final String faceProfileId;
  final String detectedFaceShape;
  final double confidenceScore;
  final List<String>? recommendedCatalogItemIds;
  final DateTime? computedAt;
  final FacePhotoDto? faceProfile;
  final DateTime? createdAt;

  const FaceAnalysisResultDto({
    required this.id,
    required this.faceProfileId,
    required this.detectedFaceShape,
    this.confidenceScore = 0,
    this.recommendedCatalogItemIds,
    this.computedAt,
    this.faceProfile,
    this.createdAt,
  });

  factory FaceAnalysisResultDto.fromJson(Map<String, dynamic> json) =>
      _$FaceAnalysisResultDtoFromJson(json);

  @override
  List<Object?> get props => [
        id,
        faceProfileId,
        detectedFaceShape,
        confidenceScore,
        recommendedCatalogItemIds,
        computedAt,
        faceProfile,
        createdAt,
      ];
}