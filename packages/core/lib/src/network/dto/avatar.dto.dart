import 'package:json_annotation/json_annotation.dart';

part 'avatar.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class AvatarDto {
  final String avatarUrl;

  const AvatarDto({required this.avatarUrl});

  factory AvatarDto.fromJson(Map<String, dynamic> json) =>
      _$AvatarDtoFromJson(json);
}