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

    test('getBranchDetail parses detail with barbers and services', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {
                'id': 1,
                'name': 'Branch 1',
                'email': 'branch1@example.com',
                'status': 'approved',
                'latitude': 24.7136,
                'longitude': 46.6753,
                'brand_id': 7,
                'chairs_count': 2,
                'barbers': [
                  {'id': 'barber-1', 'name': 'Karim'},
                ],
                'services': [
                  {'id': 'service-1', 'name': 'Fade', 'price': 80.0},
                ],
              },
            ),
          );
        },
      );
      final repository = DioExploreRepository(clientWith(fake));

      final detail = await repository.getBranchDetail('1');

      expect(captured.path, '/explore/branches/1');
      expect(detail.name, 'Branch 1');
      expect(detail.chairsCount, 2);
      expect(detail.barbers.map((barber) => barber.name), ['Karim']);
      expect(detail.services.map((service) => service.price), [80.0]);
    });

    test('getBarberDetail parses profile with services', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {
                'id': 'barber-1',
                'name': 'Karim',
                'email': 'karim@example.com',
                'is_freelancer': true,
                'status': 'approved',
                'travel_radius': 15.0,
                'latitude': 24.7136,
                'longitude': 46.6753,
                'distance': 2.1,
                'compatibility_score': 0.88,
                'rank': 3,
                'created_at': '2026-01-15T10:00:00.000Z',
                'services': [
                  {
                    'id': 'service-1',
                    'name': 'Fade',
                    'description': 'A clean fade.',
                    'price': 80.0,
                    'currency_id': 'SAR',
                    'duration': 45,
                    'at_home': true,
                    'active': true,
                    'created_at': '2026-01-15T10:00:00.000Z',
                  },
                ],
              },
            ),
          );
        },
      );
      final repository = DioExploreRepository(clientWith(fake));

      final detail = await repository.getBarberDetail('barber-1');

      expect(captured.path, '/explore/barbers/barber-1');
      expect(detail.name, 'Karim');
      expect(detail.email, 'karim@example.com');
      expect(detail.isFreelancer, isTrue);
      expect(detail.status, 'approved');
      expect(detail.travelRadius, 15.0);
      expect(detail.latitude, 24.7136);
      expect(detail.longitude, 46.6753);
      expect(detail.distance, 2.1);
      expect(detail.compatibilityScore, 0.88);
      expect(detail.rank, 3);
      expect(detail.createdAt, isNotNull);
      final service = detail.services.single;
      expect(service.id, 'service-1');
      expect(service.name, 'Fade');
      expect(service.price, 80.0);
      expect(service.currencyId, 'SAR');
      expect(service.duration, 45);
      expect(service.atHome, isTrue);
      expect(service.active, isTrue);
      expect(service.createdAt, isNotNull);
    });
  });
}