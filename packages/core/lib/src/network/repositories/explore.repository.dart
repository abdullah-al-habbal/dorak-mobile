import 'package:core/core.dart';

abstract class ExploreRepository {
  Future<PaginatedData<BranchDto>> getBranches({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  });

  Future<RawPaginated<BranchDto>> getBranchesPayload({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  });

  Future<BranchDetailDto> getBranchDetail(String branchId);

  Future<BarberProfileDto> getBarberDetail(String barberId);
}

class DioExploreRepository implements ExploreRepository {
  const DioExploreRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedData<BranchDto>> getBranches({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  }) async {
    final payload = await _fetch(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      universe: universe,
      page: page,
      perPage: perPage,
      catalogItemIds: catalogItemIds,
      availableNow: availableNow,
      priceRangeMin: priceRangeMin,
      priceRangeMax: priceRangeMax,
      ratingMin: ratingMin,
      faceShapeCompatible: faceShapeCompatible,
    );
    return payload.data;
  }

  @override
  Future<RawPaginated<BranchDto>> getBranchesPayload({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    int page = 1,
    int perPage = 20,
    List<int>? catalogItemIds,
    bool? availableNow,
    double? priceRangeMin,
    double? priceRangeMax,
    double? ratingMin,
    String? faceShapeCompatible,
  }) {
    return _fetch(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      universe: universe,
      page: page,
      perPage: perPage,
      catalogItemIds: catalogItemIds,
      availableNow: availableNow,
      priceRangeMin: priceRangeMin,
      priceRangeMax: priceRangeMax,
      ratingMin: ratingMin,
      faceShapeCompatible: faceShapeCompatible,
    );
  }

  Future<RawPaginated<BranchDto>> _fetch({
    required double latitude,
    required double longitude,
    required double radius,
    required String universe,
    required int page,
    required int perPage,
    required List<int>? catalogItemIds,
    required bool? availableNow,
    required double? priceRangeMin,
    required double? priceRangeMax,
    required double? ratingMin,
    required String? faceShapeCompatible,
  }) {
    final query = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'universe': universe,
      'page': page,
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

    return _apiClient.getRawPaginated<BranchDto>(
      ExploreEndpoints.branches,
      queryParameters: query,
      itemParser: (json) => BranchDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BranchDetailDto> getBranchDetail(String branchId) {
    return _apiClient.get<BranchDetailDto>(
      ExploreEndpoints.branchDetail.replaceFirst('{branch}', branchId),
      parser: (json) => BranchDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BarberProfileDto> getBarberDetail(String barberId) {
    return _apiClient.get<BarberProfileDto>(
      ExploreEndpoints.barberDetail.replaceFirst('{barber}', barberId),
      parser: (json) => BarberProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }
}