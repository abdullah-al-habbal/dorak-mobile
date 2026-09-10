import 'package:json_annotation/json_annotation.dart';

part 'history_barber.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HistoryBarberDto {
  final String id;
  final String name;

  const HistoryBarberDto({
    required this.id,
    required this.name,
  });

  factory HistoryBarberDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryBarberDtoFromJson(json);
}