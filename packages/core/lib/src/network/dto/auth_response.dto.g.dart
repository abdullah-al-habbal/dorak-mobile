// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      token: json['token'] as String? ?? '',
      client: ClientDto.fromJson(json['client'] as Map<String, dynamic>),
    );
