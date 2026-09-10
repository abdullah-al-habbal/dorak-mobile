import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/booking_barber.dto.dart';

part 'floor_chair.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FloorChairDto {
  final String id;
  final String? label;
  final String status;
  final Map<String, dynamic>? uiMetadata;
  final String? branchId;
  final BookingBarberDto? barber;

  const FloorChairDto({
    required this.id,
    this.label,
    required this.status,
    this.uiMetadata,
    this.branchId,
    this.barber,
  });

  factory FloorChairDto.fromJson(Map<String, dynamic> json) =>
      _$FloorChairDtoFromJson(json);
}
