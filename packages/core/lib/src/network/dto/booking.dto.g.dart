// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingDto _$BookingDtoFromJson(Map<String, dynamic> json) => BookingDto(
  id: json['id'] as String,
  timeSlot: DateTime.parse(json['time_slot'] as String),
  status: json['status'] as String,
  chair: json['chair'] == null
      ? null
      : BookingChairDto.fromJson(json['chair'] as Map<String, dynamic>),
  barber: json['barber'] == null
      ? null
      : BookingBarberDto.fromJson(json['barber'] as Map<String, dynamic>),
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => BookingServiceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);
