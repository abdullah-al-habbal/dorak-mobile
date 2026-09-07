import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

Map<String, Object> branch({int id = 1}) => {
      'id': id,
      'name': 'Branch $id',
      'email': 'branch$id@example.com',
      'status': 'approved',
      'latitude': 24.7136,
      'longitude': 46.6753,
      'brand_id': 1,
      'distance': 3.5,
      'compatibility_score': 0.92,
      'rank': 1,
    };

void main() {
  group('DioExploreRepository', () {
    test('getBranches parses items and pagination meta', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [branch()],
            meta: {
              'pagination': {
                'total': 1,
                'count': 1,
                'per_page': 20,
                'current_page': 1,
                'total_pages': 1,
              },
            },
          ),
        ),
      );
      final client = clientWith(fake);
      final repository = DioExploreRepository(client);

      final page = await repository.getBranches(
        latitude: 24.7136,
        longitude: 46.6753,
        radius: 10,
        universe: 'men',
      );

      expect(page.data, hasLength(1));
      expect(page.data.first.name, 'Branch 1');
      expect(page.meta.totalPages, 1);
      expect(fake.callCount, 1);
    });

    test('getBranchesPayload keeps raw wire items and meta', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [branch()],
            meta: {
              'pagination': {
                'total': 1,
                'count': 1,
                'per_page': 20,
                'current_page': 1,
                'total_pages': 1,
              },
            },
          ),
        ),
      );
      final client = clientWith(fake);
      final repository = DioExploreRepository(client);

      final payload = await repository.getBranchesPayload(
        latitude: 24.7136,
        longitude: 46.6753,
        radius: 10,
        universe: 'men',
      );

      expect(payload.data.data, hasLength(1));
      expect(payload.data.data.first.name, 'Branch 1');
      expect(payload.rawItems, [branch()]);
      expect(
        (payload.rawMeta['pagination'] as Map<String, dynamic>)['total_pages'],
        1,
      );
    });

    test('sends universe, coordinates, radius and per_page', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope(data: const []));
        },
      );
      final client = clientWith(fake);
      final repository = DioExploreRepository(client);

      await repository.getBranches(
        latitude: 24.7136,
        longitude: 46.6753,
        radius: 10,
        universe: 'women',
        page: 2,
        perPage: 15,
      );

      expect(captured.path, ExploreEndpoints.branches);
      expect(captured.queryParameters['latitude'], 24.7136);
      expect(captured.queryParameters['longitude'], 46.6753);
      expect(captured.queryParameters['radius'], 10);
      expect(captured.queryParameters['universe'], 'women');
      expect(captured.queryParameters['page'], 2);
      expect(captured.queryParameters['per_page'], 15);
    });
  });
}