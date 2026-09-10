import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/barber_service.dto.dart';

part 'barber_profile.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BarberProfileDto {
  final String id;
  final String name;
  final String email;
  final bool isFreelancer;
  final String status;
  final double? travelRadius;
  final double latitude;
  final double longitude;
  final double? distance;
  final double? compatibilityScore;
  final int? rank;
  final DateTime? createdAt;
  final List<BarberServiceDto> services;

  const BarberProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.isFreelancer = false,
    this.status = '',
    this.travelRadius,
    this.latitude = 0,
    this.longitude = 0,
    this.distance,
    this.compatibilityScore,
    this.rank,
    this.createdAt,
    this.services = const [],
  });

  factory BarberProfileDto.fromJson(Map<String, dynamic> json) =>
      _$BarberProfileDtoFromJson(json);
}