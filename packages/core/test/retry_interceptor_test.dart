import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

void main() {
  group('RetryInterceptor', () {
    test('retries idempotent GET on 500 until success', () async {
      final client = clientWithStatuses([500, 500, 200], maxRetries: 3);

      final result = await client.get('/x', parser: (json) => json);

      expect(result, isNotNull);
      final adapter = client.dio.httpClientAdapter as FakeHttpClientAdapter;
      expect(adapter.callCount, 3);
    });

    test('gives up after maxRetries and surfaces the error', () async {
      final client = clientWithStatuses([500], maxRetries: 2);

      await expectLater(
        client.get('/x', parser: (json) => json),
        throwsA(isA<ApiException>()),
      );
      final adapter = client.dio.httpClientAdapter as FakeHttpClientAdapter;
      expect(adapter.callCount, 3); 
    });

    test('does not retry non-idempotent POST', () async {
      final client = clientWithStatuses([500], maxRetries: 3);

      await expectLater(
        client.post('/x', data: {'a': 1}, parser: (json) => json),
        throwsA(isA<ApiException>()),
      );
      final adapter = client.dio.httpClientAdapter as FakeHttpClientAdapter;
      expect(adapter.callCount, 1);
    });
  });
}
