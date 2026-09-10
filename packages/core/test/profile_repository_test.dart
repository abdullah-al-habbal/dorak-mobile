import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

Map<String, dynamic> catalogItem({
  String id = 'catalog-1',
  String name = 'Classic Fade',
  List<String> faceShapes = const ['oval', 'round'],
}) =>
    {
      'id': id,
      'category_id': 3,
      'name': {'en': name, 'ar': 'فيض كلاسيكي'},
      'description': {'en': 'A timeless fade.', 'ar': 'فيض عصري.'},
      'slug': 'classic-fade',
      'sku': 'SVC-1',
      'price_range': {'min': 45.0, 'max': 60.0, 'currency': 'SAR'},
      'maintenance_level': 'low',
      'style_period': 'timeless',
      'formality': 'casual',
      'face_shapes': faceShapes,
      'hair_textures': ['straight'],
      'metadata': null,
      'is_active': true,
      'created_at': '2026-09-01T09:00:00.000Z',
      'updated_at': '2026-09-01T09:00:00.000Z',
    };

void main() {
  group('DioProfileRepository', () {
    test('updateProfile sends only the provided fields and parses the client',
        () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {
                'id': 'client-1',
                'name': 'Ahmad',
                'email': 'ahmad@example.com',
                'phone': '+966500000001',
                'preferred_universe': 'men',
              },
            ),
          );
        },
      );
      final repository = DioProfileRepository(clientWith(fake));

      final client = await repository.updateProfile(name: 'Ahmad');

      expect(captured.path, ProfileEndpoints.update);
      expect(captured.method, 'PATCH');
      expect(captured.data, {'name': 'Ahmad'});
      expect(client.name, 'Ahmad');
      expect(client.preferredUniverse, 'men');
    });

    test('updateProfile omits not provided fields', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope(data: {
            'id': 'client-1',
            'name': '',
            'email': '',
            'phone': null,
            'preferred_universe': null,
          }));
        },
      );
      final repository = DioProfileRepository(clientWith(fake));

      await repository.updateProfile(phone: '+966500000002');

      expect(captured.data, {'phone': '+966500000002'});
    });

    test('uploadAvatar posts multipart and parses avatar_url', () async {
      late RequestOptions captured;
      final file = File('${Directory.systemTemp.path}/avatar.png')
        ..writeAsStringSync('avatar bytes');
      addTearDown(file.deleteSync);
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {'avatar_url': 'https://cdn.dorak.io/avatars/a1.jpg'},
            ),
          );
        },
      );
      final repository = DioProfileRepository(clientWith(fake));

      final avatar = await repository.uploadAvatar(file.path);

      expect(captured.path, ProfileEndpoints.avatar);
      expect(captured.method, 'POST');
      final formData = captured.data as FormData;
      expect(formData.files.single.key, 'avatar');
      expect(avatar.avatarUrl, 'https://cdn.dorak.io/avatars/a1.jpg');
    });

    test('updatePreferredUniverse sends the universe and parses the response',
        () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              statusCode: 200,
              data: {'preferred_universe': 'women'},
            ),
          );
        },
      );
      final repository = DioProfileRepository(clientWith(fake));

      final preference = await repository.updatePreferredUniverse('women');

      expect(captured.path, ProfileEndpoints.universe);
      expect(captured.method, 'PATCH');
      expect(captured.data, {'preferred_universe': 'women'});
      expect(preference.preferredUniverse, 'women');
    });
  });

  group('DioServiceCatalogRepository', () {
    test('getCatalogItems parses items with price range and face shapes',
        () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: [catalogItem()],
              meta: {
                'pagination': {
                  'total': 1,
                  'count': 1,
                  'per_page': 100,
                  'current_page': 1,
                  'total_pages': 1,
                },
              },
            ),
          );
        },
      );
      final repository = DioServiceCatalogRepository(clientWith(fake));

      final page = await repository.getCatalogItems();

      expect(captured.path, ServiceCatalogEndpoints.items);
      expect(captured.queryParameters['per_page'], 100);
      expect(captured.queryParameters['page'], 1);
      final item = page.data.single;
      expect(item.id, 'catalog-1');
      expect(item.name['en'], 'Classic Fade');
      expect(item.priceRange?.min, 45);
      expect(item.priceRange?.currency, 'SAR');
      expect(item.faceShapes, ['oval', 'round']);
      expect(item.stylePeriod, 'timeless');
      expect(item.isActive, isTrue);
    });

    test('getCatalogItems tolerates missing price range', () async {
      final raw = catalogItem();
      raw.remove('price_range');
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [raw],
            meta: {
              'pagination': {
                'total': 1,
                'count': 1,
                'per_page': 100,
                'current_page': 1,
                'total_pages': 1,
              },
            },
          ),
        ),
      );
      final repository = DioServiceCatalogRepository(clientWith(fake));

      final page = await repository.getCatalogItems();

      expect(page.data.single.priceRange, isNull);
    });
  });
}