import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

Map<String, Object?> history({
  String id = 'history-1',
  String? branchId = 'branch-1',
}) =>
    {
      'id': id,
      'client_id': 'client-1',
      'booking_id': 'booking-1',
      'barber_id': 'barber-1',
      'branch_id': branchId,
      'offered_service_id': 'service-1',
      'catalog_item_id': 'catalog-1',
      'performed_at': '2026-08-30T11:00:00.000Z',
      'client_rating': 5,
      'client_notes': 'Great fade',
      'barber_notes': null,
      'metadata': null,
      'barber': {'id': 'barber-1', 'name': 'Karim'},
      'branch': {'id': branchId, 'name': 'Riyadh Downtown'},
      'catalog_item': {
        'id': 'catalog-1',
        'name': {'en': 'Classic Fade', 'ar': 'فيض كلاسيكي'},
      },
      'media': [
        {
          'id': 'media-1',
          'photo_url': 'https://cdn.dorak.io/history/media-1.jpg',
          'photo_type': 'after',
          'uploaded_at': '2026-08-30T12:00:00.000Z',
        },
      ],
      'created_at': '2026-08-30T12:00:00.000Z',
      'updated_at': '2026-08-30T12:00:00.000Z',
    };

void main() {
  group('DioHistoryRepository', () {
    test('getHistory parses items with nested relations', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [history()],
            meta: {
              'pagination': {
                'total': 1,
                'count': 1,
                'per_page': 15,
                'current_page': 1,
                'total_pages': 1,
              },
            },
          ),
        ),
      );
      final repository = DioHistoryRepository(clientWith(fake));

      final page = await repository.getHistory();

      expect(page.data, hasLength(1));
      final item = page.data.first;
      expect(item.id, 'history-1');
      expect(item.bookingId, 'booking-1');
      expect(item.catalogItemId, 'catalog-1');
      expect(item.performedAt, DateTime.parse('2026-08-30T11:00:00.000Z'));
      expect(item.clientRating, 5);
      expect(item.clientNotes, 'Great fade');
      expect(item.barber?.name, 'Karim');
      expect(item.branch?.name, 'Riyadh Downtown');
      expect(item.catalogItem?.name, {
        'en': 'Classic Fade',
        'ar': 'فيض كلاسيكي',
      });
      expect(item.media, hasLength(1));
      expect(
        item.media.first.photoUrl,
        'https://cdn.dorak.io/history/media-1.jpg',
      );
      expect(fake.callCount, 1);
    });

    test('getHistory sends pagination parameters', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope(data: const []));
        },
      );
      final repository = DioHistoryRepository(clientWith(fake));

      await repository.getHistory(page: 2, perPage: 30);

      expect(captured.path, HistoryEndpoints.history);
      expect(captured.queryParameters['page'], 2);
      expect(captured.queryParameters['per_page'], 30);
    });

    test('rebookFromHistory posts the slot in server format', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            statusCode: 201,
            data: successEnvelope(
              statusCode: 201,
              code: 'CREATED',
              data: {
                'id': 'booking-2',
                'time_slot': '2026-09-20 09:00:00',
                'status': 'pending',
                'barber_id': 'barber-1',
              },
            ),
          );
        },
      );
      final repository = DioHistoryRepository(clientWith(fake));

      final created = await repository.rebookFromHistory(
        'history-1',
        DateTime.utc(2026, 9, 20, 9),
      );

      expect(captured.path, '/client/history/history-1/rebook');
      expect(captured.method, 'POST');
      expect(captured.data, {'time_slot': '2026-09-20 09:00:00'});
      expect(created.id, 'booking-2');
      expect(created.status, 'pending');
      expect(created.barber?.name, isNull);
    });
  });
}