import 'package:json_annotation/json_annotation.dart';

part 'booking_barber.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BookingBarberDto {
  final String id;
  final String name;

  const BookingBarberDto({
    required this.id,
    required this.name,
  });

  factory BookingBarberDto.fromJson(Map<String, dynamic> json) =>
      _$BookingBarberDtoFromJson(json);
}
