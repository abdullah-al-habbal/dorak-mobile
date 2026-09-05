import 'package:core/core.dart';

abstract class ExploreRepository {
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
  });
}