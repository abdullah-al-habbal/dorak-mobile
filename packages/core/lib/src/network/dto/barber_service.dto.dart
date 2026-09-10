import 'package:json_annotation/json_annotation.dart';

part 'barber_service.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class BarberServiceDto {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? currencyId;
  final int? duration;
  final bool atHome;
  final bool active;
  final DateTime? createdAt;

  const BarberServiceDto({
    required this.id,
    required this.name,
    this.description,
    this.price = 0,
    this.currencyId,
    this.duration,
    this.atHome = false,
    this.active = true,
    this.createdAt,
  });

  factory BarberServiceDto.fromJson(Map<String, dynamic> json) =>
      _$BarberServiceDtoFromJson(json);
}