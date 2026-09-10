import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ClientDto extends Equatable {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String email;
  final String? phone;
  final String? preferredUniverse;

  const ClientDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.preferredUniverse,
  });

  factory ClientDto.fromJson(Map<String, dynamic> json) =>
      _$ClientDtoFromJson(json);

  @override
  List<Object?> get props => [id, name, email, phone, preferredUniverse];
}
