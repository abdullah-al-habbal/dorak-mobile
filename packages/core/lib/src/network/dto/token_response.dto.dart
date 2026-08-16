import 'package:json_annotation/json_annotation.dart';

part 'token_response.dto.g.dart';

@JsonSerializable(createToJson: false)
class TokenResponseDto {
  @JsonKey(defaultValue: '')
  final String token;

  const TokenResponseDto({required this.token});

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
}
