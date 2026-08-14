import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

void main() {
  group('DioOnboardingConfigRepository', () {
    test('fetches config without a locale query param and parses DTO', () async {
      final fake = fakeDio(
        handler: (options) {
          expect(options.queryParameters.containsKey('locale'), isFalse);
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {
                'hero_image_url': 'http://x/hero.jpg',
                'season': 'summer',
                'locale': 'en',
              },
            ),
          );
        },
      );
      final repo = DioOnboardingConfigRepository(clientWith(fake));

      final dto = await repo.fetchOnboardingConfig(locale: 'en');

      expect(dto.heroImageUrl, 'http://x/hero.jpg');
      expect(dto.season, 'summer');
      expect(dto.locale, 'en');
    });

    test('caches per locale', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: {'hero_image_url': 'http://x/h.jpg', 'season': null, 'locale': 'x'},
          ),
        ),
      );
      final repo = DioOnboardingConfigRepository(clientWith(fake));

      await repo.fetchOnboardingConfig(locale: 'en');
      await repo.fetchOnboardingConfig(locale: 'en');
      await repo.fetchOnboardingConfig(locale: 'ar');

      expect(fake.callCount, 2);
    });

    test('surfaces validation errors as ValidationException', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          statusCode: 422,
          data: errorEnvelope(
            code: 'VALIDATION_FAILED',
            statusCode: 422,
            errors: {'season': ['The season is invalid.']},
          ),
        ),
      );
      final repo = DioOnboardingConfigRepository(clientWith(fake));

      await expectLater(
        repo.fetchOnboardingConfig(),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
