// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_chair.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FloorChairDto _$FloorChairDtoFromJson(Map<String, dynamic> json) =>
    FloorChairDto(
      id: json['id'] as String,
      label: json['label'] as String?,
      status: json['status'] as String,
      uiMetadata: json['ui_metadata'] as Map<String, dynamic>?,
      branchId: json['branch_id'] as String?,
      barber: json['barber'] == null
          ? null
          : BookingBarberDto.fromJson(json['barber'] as Map<String, dynamic>),
    );
