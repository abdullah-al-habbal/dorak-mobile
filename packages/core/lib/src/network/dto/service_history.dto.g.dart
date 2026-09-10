// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_history.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHistoryDto _$ServiceHistoryDtoFromJson(Map<String, dynamic> json) =>
    ServiceHistoryDto(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String?,
      catalogItemId: json['catalog_item_id'] as String?,
      performedAt: json['performed_at'] == null
          ? null
          : DateTime.parse(json['performed_at'] as String),
      clientRating: json['client_rating'] as num?,
      clientNotes: json['client_notes'] as String?,
      barber: json['barber'] == null
          ? null
          : HistoryBarberDto.fromJson(json['barber'] as Map<String, dynamic>),
      branch: json['branch'] == null
          ? null
          : HistoryBranchDto.fromJson(json['branch'] as Map<String, dynamic>),
      catalogItem: json['catalog_item'] == null
          ? null
          : HistoryCatalogItemDto.fromJson(
              json['catalog_item'] as Map<String, dynamic>,
            ),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => HistoryMediaDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
