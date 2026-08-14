import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/client.dto.dart';

part 'auth_response.dto.g.dart';

@JsonSerializable(createToJson: false)
class AuthResponseDto {
  @JsonKey(defaultValue: '')
  final String token;
  final ClientDto client;

  const AuthResponseDto({
    required this.token,
    required this.client,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}
