import 'package:dio/dio.dart';

import 'package:core/core.dart';

abstract class ProfileRepository {
  Future<ClientDto> updateProfile({
    String? name,
    String? email,
    String? phone,
  });

  Future<AvatarDto> uploadAvatar(String filePath);

  Future<UniversePreferenceDto> updatePreferredUniverse(String universe);
}

class DioProfileRepository implements ProfileRepository {
  const DioProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ClientDto> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) {
    final data = <String, dynamic>{
      'name': ?name,
      'email': ?email,
      'phone': ?phone,
    };
    return _apiClient.patch<ClientDto>(
      ProfileEndpoints.update,
      data: data,
      parser: (json) => ClientDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<AvatarDto> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    return _apiClient.post<AvatarDto>(
      ProfileEndpoints.avatar,
      data: formData,
      parser: (json) => AvatarDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<UniversePreferenceDto> updatePreferredUniverse(String universe) {
    return _apiClient.patch<UniversePreferenceDto>(
      ProfileEndpoints.universe,
      data: {'preferred_universe': universe},
      parser: (json) => UniversePreferenceDto.fromJson(json as Map<String, dynamic>),
    );
  }
}