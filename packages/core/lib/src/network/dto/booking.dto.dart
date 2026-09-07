import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/booking_barber.dto.dart';
import 'package:core/src/network/dto/booking_chair.dto.dart';
import 'package:core/src/network/dto/booking_service.dto.dart';

part 'booking.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BookingDto {
  final String id;
  final DateTime timeSlot;
  final String status;
  final BookingChairDto? chair;
  final BookingBarberDto? barber;
  final List<BookingServiceDto> services;
  final DateTime? createdAt;

  const BookingDto({
    required this.id,
    required this.timeSlot,
    required this.status,
    this.chair,
    this.barber,
    this.services = const [],
    this.createdAt,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);
}
