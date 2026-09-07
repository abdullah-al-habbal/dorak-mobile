import 'package:json_annotation/json_annotation.dart';

part 'booking_service.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BookingServiceDto {
  final String id;
  final String name;
  final double? price;

  const BookingServiceDto({
    required this.id,
    required this.name,
    this.price,
  });

  factory BookingServiceDto.fromJson(Map<String, dynamic> json) =>
      _$BookingServiceDtoFromJson(json);
}
