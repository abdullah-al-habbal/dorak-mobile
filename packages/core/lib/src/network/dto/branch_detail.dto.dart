import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/booking_barber.dto.dart';
import 'package:core/src/network/dto/booking_service.dto.dart';

part 'branch_detail.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BranchDetailDto {
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
  final int chairsCount;
  final List<BookingBarberDto> barbers;
  final List<BookingServiceDto> services;

  const BranchDetailDto({
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
    this.chairsCount = 0,
    this.barbers = const [],
    this.services = const [],
  });

  factory BranchDetailDto.fromJson(Map<String, dynamic> json) =>
      _$BranchDetailDtoFromJson(json);
}
