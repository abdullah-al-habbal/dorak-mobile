// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_media.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryMediaDto _$HistoryMediaDtoFromJson(Map<String, dynamic> json) =>
    HistoryMediaDto(
      id: json['id'] as String,
      photoUrl: json['photo_url'] as String,
      uploadedAt: json['uploaded_at'] == null
          ? null
          : DateTime.parse(json['uploaded_at'] as String),
    );
