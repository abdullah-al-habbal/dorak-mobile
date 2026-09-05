import 'package:json_annotation/json_annotation.dart';

part 'branch.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BranchDto {
  final int id;
  final String name;
  final String email;
  final String status;
  final double latitude;
  final double longitude;
  final int brandId;
  final double? distance;
  final double? compatibilityScore;
  final int? rank;
  final DateTime? createdAt;

  const BranchDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.brandId,
    this.distance,
    this.compatibilityScore,
    this.rank,
    this.createdAt,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) =>
      _$BranchDtoFromJson(json);
}