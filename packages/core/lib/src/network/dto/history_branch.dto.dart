import 'package:json_annotation/json_annotation.dart';

part 'history_branch.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HistoryBranchDto {
  final String id;
  final String name;

  const HistoryBranchDto({
    required this.id,
    required this.name,
  });

  factory HistoryBranchDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryBranchDtoFromJson(json);
}