import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

void main() {
  const clientPayload = {
    'id': 'uuid-1',
    'name': 'Sara',
    'email': 'sara@example.com',
    'phone': null,
  };

  test('login posts credentials and decodes token + client', () async {
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(
          options,
          data: successEnvelope(
            data: {'token': '1|abc', 'client': clientPayload},
          ),
        );
      },
    );

    final result = await DioAuthRepository(clientWith(fake)).login(
      email: 'sara@example.com',
      password: 'secret123',
    );

    expect(captured!.path, '/client/login');
    expect(captured!.data, {
      'email': 'sara@example.com',
      'password': 'secret123',
    });
    expect(result.token, '1|abc');
    expect(result.client.name, 'Sara');
  });

  test('register sends password_confirmation', () async {
    // Backend RegisterRequest applies Laravel's `confirmed` rule; omitting this
    // key made every signup fail validation.
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(
          options,
          statusCode: 201,
          data: successEnvelope(
            statusCode: 201,
            code: 'CREATED',
            data: {'token': '2|def', 'client': clientPayload},
          ),
        );
      },
    );

    final result = await DioAuthRepository(clientWith(fake)).register(
      name: 'Sara',
      email: 'sara@example.com',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );

    final body = captured!.data as Map<String, dynamic>;
    expect(captured!.path, '/client/register');
    expect(body['password_confirmation'], 'secret123');
    expect(body.containsKey('phone'), isFalse);
    expect(result.token, '2|def');
  });

  test('register includes phone only when provided', () async {
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(
          options,
          data: successEnvelope(
            data: {'token': '3|ghi', 'client': clientPayload},
          ),
        );
      },
    );

    await DioAuthRepository(clientWith(fake)).register(
      name: 'Sara',
      email: 'sara@example.com',
      password: 'secret123',
      passwordConfirmation: 'secret123',
      phone: '0500000000',
    );

    expect((captured!.data as Map<String, dynamic>)['phone'], '0500000000');
  });

  test('refreshToken returns the rotated token', () async {
    final fake = fakeDio(
      handler: (options) => jsonResponse(
        options,
        data: successEnvelope(data: {'token': '4|rotated'}),
      ),
    );

    final token = await DioAuthRepository(clientWith(fake)).refreshToken();

    expect(token, '4|rotated');
  });

  test('logout tolerates a response with no data key', () async {
    // `noContent()` on the backend answers 200 with the `data` key omitted.
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(
          options,
          data: {
            'success': true,
            'statusCode': 200,
            'code': 'SUCCESS',
            'message': 'Success',
            'timestamp': '2026-08-15T00:00:00.000Z',
          },
        );
      },
    );

    await DioAuthRepository(clientWith(fake)).logout();

    expect(captured!.path, '/client/logout');
  });

  test('verifyEmail posts the code', () async {
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(options, data: successEnvelope());
      },
    );

    await DioAuthRepository(clientWith(fake)).verifyEmail('123456');

    expect(captured!.path, '/client/email/verify');
    expect(captured!.data, {'code': '123456'});
  });

  test('sendEmailVerification hits the dispatch route', () async {
    RequestOptions? captured;
    final fake = fakeDio(
      handler: (options) {
        captured = options;
        return jsonResponse(options, data: successEnvelope());
      },
    );

    await DioAuthRepository(clientWith(fake)).sendEmailVerification();

    expect(captured!.path, '/client/email/verify/send');
  });

  test('rejected login surfaces as an unauthorized ApiException', () async {
    final fake = fakeDio(
      handler: (options) => jsonResponse(
        options,
        statusCode: 401,
        data: errorEnvelope(
          code: 'UNAUTHORIZED',
          statusCode: 401,
          // The backend really does return the raw translation key here.
          message: 'core::messages.invalid_credentials',
        ),
      ),
    );

    await expectLater(
      DioAuthRepository(clientWith(fake)).login(
        email: 'sara@example.com',
        password: 'wrong',
      ),
      throwsA(
        isA<ApiException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
      ),
    );
  });

  test('invalid verification code surfaces field errors', () async {
    final fake = fakeDio(
      handler: (options) => jsonResponse(
        options,
        statusCode: 422,
        data: errorEnvelope(
          code: 'VALIDATION_FAILED',
          statusCode: 422,
          message: 'core::messages.invalid_verification_code',
          errors: {'code': ['The code is invalid.']},
        ),
      ),
    );

    await expectLater(
      DioAuthRepository(clientWith(fake)).verifyEmail('000000'),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.errorsFor('code'),
          'errorsFor(code)',
          ['The code is invalid.'],
        ),
      ),
    );
  });
}
