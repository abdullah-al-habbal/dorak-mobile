import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

void main() {
  group('ApiClient.get', () {
    test('parses success envelope and returns typed data', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: {'hero_image_url': 'http://x/hero.jpg', 'season': 'summer', 'locale': 'en'},
          ),
        ),
      );
      final client = clientWith(fake);

      final dto = await client.get(
        '/app/onboarding-config',
        queryParameters: {'verbose': true},
        parser: (json) => OnboardingConfigDto.fromJson(json as Map<String, dynamic>),
      );

      expect(dto.heroImageUrl, 'http://x/hero.jpg');
      expect(dto.season, 'summer');
      expect(fake.callCount, 1);
    });

    test('throws ValidationException for 422 VALIDATION_FAILED', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          statusCode: 422,
          data: errorEnvelope(
            code: 'VALIDATION_FAILED',
            statusCode: 422,
            errors: {'locale': ['The locale is invalid.']},
          ),
        ),
      );
      final client = clientWith(fake);

      await expectLater(
        client.get('/x', parser: (json) => json),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.errorsFor('locale'), 'locale errors', isNotEmpty),
        ),
      );
    });

    test('throws ApiException for 404 RESOURCE_NOT_FOUND', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          statusCode: 404,
          data: errorEnvelope(code: 'RESOURCE_NOT_FOUND', statusCode: 404),
        ),
      );
      final client = clientWith(fake);

      await expectLater(
        client.get('/x', parser: (json) => json),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.code, 'code', 'RESOURCE_NOT_FOUND'),
        ),
      );
    });

    test('throws INVALID_RESPONSE when payload is not an envelope', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(options, data: [1, 2, 3]),
      );
      final client = clientWith(fake);

      await expectLater(
        client.get('/x', parser: (json) => json),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_RESPONSE')),
      );
    });

    test('maps DioException to NetworkException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message: 'timed out',
              ),
            ),
          ),
        );
      final client = ApiClient(
        baseUrl: 'http://test/api/v1',
        dio: dio,
        enableLogging: false,
        maxRetries: 0,
      );

      await expectLater(
        client.get('/x', parser: (json) => json),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('ApiClient verbs', () {
    test('post sends body and parses created data', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            statusCode: 201,
            code: 'CREATED',
            data: {'id': 'u1', 'email': 'a@b.c'},
          ),
        ),
      );
      final client = clientWith(fake);

      final id = await client.post(
        '/clients',
        data: {'email': 'a@b.c'},
        parser: (json) => (json as Map<String, dynamic>)['id'] as String,
      );

      expect(id, 'u1');
    });

    test('put and patch send data and parse response', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(data: {'ok': true}),
        ),
      );
      final client = clientWith(fake);

      final putOk = await client.put('/clients/u1', data: {'name': 'x'}, parser: (json) => json);
      final patchOk = await client.patch('/clients/u1', data: {'name': 'y'}, parser: (json) => json);

      expect(putOk, isNotNull);
      expect(patchOk, isNotNull);
    });

    test('delete succeeds without data and throws on failure', () async {
      final okFake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(code: 'DELETED', data: null),
        ),
      );
      await clientWith(okFake).delete('/clients/u1');

      final failingFake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          statusCode: 500,
          data: errorEnvelope(code: 'SERVER_ERROR', statusCode: 500),
        ),
      );
      await expectLater(
        clientWith(failingFake, maxRetries: 0).delete('/clients/u1'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiClient.getPaginated', () {
    test('parses items and pagination meta', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [
              {'id': 'a'},
              {'id': 'b'},
            ],
            meta: {
              'pagination': {
                'total': 25,
                'count': 2,
                'per_page': 15,
                'current_page': 1,
                'total_pages': 2,
              },
            },
          ),
        ),
      );
      final client = clientWith(fake);

      final page = await client.getPaginated(
        '/explore/branches',
        queryParameters: {'page': 1, 'per_page': 15},
        itemParser: (json) => (json as Map<String, dynamic>)['id'] as String,
      );

      expect(page.data, ['a', 'b']);
      expect(page.meta.total, 25);
      expect(page.meta.totalPages, 2);
      expect(page.meta.currentPage, 1);
    });

    test('a failed envelope throws instead of yielding an empty page', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: errorEnvelope(
            code: 'RESOURCE_NOT_FOUND',
            statusCode: 404,
            message: 'core::messages.not_found',
          ),
        ),
      );

      await expectLater(
        clientWith(fake, maxRetries: 0).getPaginated<String>(
          '/explore/branches',
          itemParser: (json) => json.toString(),
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
        reason: 'an API failure must never be indistinguishable from a '
            'successful empty result',
      );
    });

    test('a 422 envelope throws ValidationException with field errors',
        () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: errorEnvelope(
            code: 'VALIDATION_FAILED',
            statusCode: 422,
            message: 'core::messages.validation_failed',
            errors: {
              'latitude': ['The latitude field is required.'],
            },
          ),
        ),
      );

      await expectLater(
        clientWith(fake, maxRetries: 0).getPaginated<String>(
          '/explore/branches',
          itemParser: (json) => json.toString(),
        ),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.errors['latitude'], 'latitude errors',
                  ['The latitude field is required.']),
        ),
      );
    });
  });
}
