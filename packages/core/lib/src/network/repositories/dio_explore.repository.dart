import 'package:core/core.dart';

class DioExploreRepository implements ExploreRepository {
  const DioExploreRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedData<BranchDto>> getBranches({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  }) {
    final query = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'universe': universe,
      'per_page': perPage,
    };
    if (catalogItemIds != null && catalogItemIds.isNotEmpty) {
      query['catalog_item_ids'] = catalogItemIds;
    }
    if (availableNow != null) {
      query['available_now'] = availableNow;
    }
    if (priceRangeMin != null || priceRangeMax != null) {
      query['price_range'] = <String, dynamic>{
        // ignore: use_null_aware_elements
        if (priceRangeMin case final min?) 'min': min,
        // ignore: use_null_aware_elements
        if (priceRangeMax case final max?) 'max': max,
      };
    }
    if (ratingMin != null) {
      query['rating_min'] = ratingMin;
    }
    if (faceShapeCompatible != null) {
      query['face_shape_compatible'] = faceShapeCompatible;
    }

    return _apiClient.getPaginated<BranchDto>(
      ExploreEndpoints.branches,
      queryParameters: query,
      itemParser: (json) => BranchDto.fromJson(json as Map<String, dynamic>),
    );
  }
}