import 'package:dio/dio.dart';

import 'package:core/core.dart';

abstract class FaceProfileRepository {
  Future<FacePhotoDto> uploadFacePhoto(String filePath, {bool isPrimary = false});

  Future<List<FaceAnalysisResultDto>> getRecommendations();
}

class DioFaceProfileRepository implements FaceProfileRepository {
  const DioFaceProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FacePhotoDto> uploadFacePhoto(
    String filePath, {
    bool isPrimary = false,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
      'is_primary': isPrimary,
    });
    return _apiClient.post<FacePhotoDto>(
      FaceProfileEndpoints.upload,
      data: formData,
      parser: (json) => FacePhotoDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<List<FaceAnalysisResultDto>> getRecommendations() {
    return _apiClient.get<List<FaceAnalysisResultDto>>(
      FaceProfileEndpoints.recommendations,
      parser: (json) => (json as List<dynamic>)
          .map((item) => FaceAnalysisResultDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}