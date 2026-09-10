import 'package:core/core.dart';

abstract class ServiceCatalogRepository {
  Future<PaginatedData<CatalogItemDto>> getCatalogItems({
    int page = 1,
    int perPage = 100,
  });
}

class DioServiceCatalogRepository implements ServiceCatalogRepository {
  const DioServiceCatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedData<CatalogItemDto>> getCatalogItems({
    int page = 1,
    int perPage = 100,
  }) {
    return _apiClient.getPaginated<CatalogItemDto>(
      ServiceCatalogEndpoints.items,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      itemParser: (json) => CatalogItemDto.fromJson(json as Map<String, dynamic>),
    );
  }
}