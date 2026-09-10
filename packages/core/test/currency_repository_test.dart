import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

Map<String, dynamic> currency({
  String id = 'SAR',
  String code = 'SAR',
  Map<String, String> name = const {
    'en': 'Saudi Riyal',
    'ar': 'ريال سعودي',
  },
  String? symbol = 'ر.س',
  bool isDefault = false,
}) =>
    {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'is_default': isDefault,
    };

void main() {
  group('DioCurrencyRepository', () {
    test('getCurrencies parses the currency list', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: [
                currency(),
                currency(
                  id: 'USD',
                  code: 'USD',
                  name: const {'en': 'US Dollar', 'ar': 'دولار أمريكي'},
                  symbol: '\$',
                ),
              ],
            ),
          );
        },
      );
      final repository = DioCurrencyRepository(clientWith(fake));

      final currencies = await repository.getCurrencies();

      expect(captured.path, CurrencyEndpoints.currencies);
      expect(currencies, hasLength(2));
      final sar = currencies.first;
      expect(sar.id, 'SAR');
      expect(sar.code, 'SAR');
      expect(sar.symbol, 'ر.س');
      expect(sar.isDefault, isFalse);
      expect(currencies.last.code, 'USD');
    });

    test('getCurrencies parses the translatable name map and default flag',
        () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [
              currency(isDefault: true),
            ],
          ),
        ),
      );
      final repository = DioCurrencyRepository(clientWith(fake));

      final currencies = await repository.getCurrencies();

      final sar = currencies.single;
      expect(sar.name['en'], 'Saudi Riyal');
      expect(sar.name['ar'], 'ريال سعودي');
      expect(sar.name, containsPair('en', 'Saudi Riyal'));
      expect(sar.isDefault, isTrue);
    });

    test('getCurrencies returns an empty list when none are present', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(data: const []),
        ),
      );
      final repository = DioCurrencyRepository(clientWith(fake));

      final currencies = await repository.getCurrencies();

      expect(currencies, isEmpty);
      expect(fake.callCount, 1);
    });
  });
}