import 'package:json_annotation/json_annotation.dart';

part 'universe_preference.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class UniversePreferenceDto {
  final String? preferredUniverse;

  const UniversePreferenceDto({this.preferredUniverse});

  factory UniversePreferenceDto.fromJson(Map<String, dynamic> json) =>
      _$UniversePreferenceDtoFromJson(json);
}