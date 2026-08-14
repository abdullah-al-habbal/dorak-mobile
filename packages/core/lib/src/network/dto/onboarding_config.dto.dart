import 'package:json_annotation/json_annotation.dart';

part 'onboarding_config.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OnboardingConfigDto {
  @JsonKey(defaultValue: '')
  final String heroImageUrl;
  final String? season;
  @JsonKey(defaultValue: 'en')
  final String locale;

  const OnboardingConfigDto({
    required this.heroImageUrl,
    required this.season,
    required this.locale,
  });

  factory OnboardingConfigDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingConfigDtoFromJson(json);
}
