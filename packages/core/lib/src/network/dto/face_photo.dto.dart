import 'package:json_annotation/json_annotation.dart';

part 'face_photo.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FacePhotoDto {
  final String id;
  final String imageUrl;
  final bool isPrimary;
  final DateTime? uploadedAt;

  const FacePhotoDto({
    required this.id,
    required this.imageUrl,
    this.isPrimary = false,
    this.uploadedAt,
  });

  factory FacePhotoDto.fromJson(Map<String, dynamic> json) =>
      _$FacePhotoDtoFromJson(json);
}