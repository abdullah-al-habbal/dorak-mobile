import 'package:json_annotation/json_annotation.dart';

import 'package:core/src/network/dto/history_barber.dto.dart';
import 'package:core/src/network/dto/history_branch.dto.dart';
import 'package:core/src/network/dto/history_catalog_item.dto.dart';
import 'package:core/src/network/dto/history_media.dto.dart';

part 'service_history.dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ServiceHistoryDto {
  final String id;
  final String? bookingId;
  final String? catalogItemId;
  final DateTime? performedAt;
  final num? clientRating;
  final String? clientNotes;
  final HistoryBarberDto? barber;
  final HistoryBranchDto? branch;
  final HistoryCatalogItemDto? catalogItem;
  final List<HistoryMediaDto> media;
  final DateTime? createdAt;

  const ServiceHistoryDto({
    required this.id,
    this.bookingId,
    this.catalogItemId,
    this.performedAt,
    this.clientRating,
    this.clientNotes,
    this.barber,
    this.branch,
    this.catalogItem,
    this.media = const [],
    this.createdAt,
  });

  factory ServiceHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceHistoryDtoFromJson(json);
}