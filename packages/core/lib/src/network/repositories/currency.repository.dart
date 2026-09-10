import 'package:core/core.dart';

abstract class CurrencyRepository {
  Future<List<CurrencyDto>> getCurrencies();
}

class DioCurrencyRepository implements CurrencyRepository {
  const DioCurrencyRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CurrencyDto>> getCurrencies() {
    return _apiClient.get<List<CurrencyDto>>(
      CurrencyEndpoints.currencies,
      parser: (json) => (json as List<dynamic>)
          .map(
            (item) => CurrencyDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}