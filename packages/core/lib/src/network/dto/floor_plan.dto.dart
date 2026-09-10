import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/floor_chair.dto.dart';

part 'floor_plan.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class FloorPlanDto {
  final String branchId;
  final String branchName;
  final List<FloorChairDto> chairs;

  const FloorPlanDto({
    required this.branchId,
    required this.branchName,
    this.chairs = const [],
  });

  factory FloorPlanDto.fromJson(Map<String, dynamic> json) =>
      _$FloorPlanDtoFromJson(json);
}
