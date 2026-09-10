import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

Map<String, Object?> booking({
  String id = 'booking-1',
  String status = 'confirmed',
}) =>
    {
      'id': id,
      'time_slot': '2026-09-10T14:30:00.000Z',
      'status': status,
      'chair': {'id': 'chair-1', 'label': 'Chair A', 'status': 'available'},
      'barber': {'id': 'barber-1', 'name': 'Karim'},
      'services': [
        {'id': 'service-1', 'name': 'Fade', 'price': 80.0},
      ],
      'created_at': '2026-09-02T10:00:00.000Z',
    };

void main() {
  group('DioBookingRepository', () {
    test('getBookings parses items with nested relations', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          data: successEnvelope(
            data: [booking()],
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
      final repository = DioBookingRepository(clientWith(fake));

      final page = await repository.getBookings(status: 'upcoming');

      expect(page.data, hasLength(1));
      final item = page.data.first;
      expect(item.id, 'booking-1');
      expect(item.status, 'confirmed');
      expect(
        item.timeSlot,
        DateTime.parse('2026-09-10T14:30:00.000Z'),
      );
      expect(item.chair?.label, 'Chair A');
      expect(item.barber?.name, 'Karim');
      expect(item.services.map((service) => service.name), ['Fade']);
      expect(fake.callCount, 1);
    });

    test('getBookings sends the status filter and pagination', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope(data: const []));
        },
      );
      final repository = DioBookingRepository(clientWith(fake));

      await repository.getBookings(status: 'past', page: 2);

      expect(captured.path, BookingEndpoints.bookings);
      expect(captured.queryParameters['status'], 'past');
      expect(captured.queryParameters['page'], 2);
      expect(captured.queryParameters['per_page'], 20);
    });

    test('getBookings omits the status filter when unset', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope(data: const []));
        },
      );
      final repository = DioBookingRepository(clientWith(fake));

      await repository.getBookings();

      expect(captured.queryParameters.containsKey('status'), isFalse);
    });

    test('createBooking posts the slot in server format', () async {
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
              data: booking(),
            ),
          );
        },
      );
      final repository = DioBookingRepository(clientWith(fake));

      final created = await repository.createBooking(
        chairId: 'chair-1',
        barberId: 'barber-1',
        timeSlot: DateTime.utc(2026, 9, 10, 14, 30),
        serviceIds: const ['service-1'],
      );

      expect(captured.path, BookingEndpoints.bookings);
      expect(captured.method, 'POST');
      expect(captured.data, {
        'chair_id': 'chair-1',
        'barber_id': 'barber-1',
        'time_slot': '2026-09-10 14:30:00',
        'service_ids': ['service-1'],
      });
      expect(created.id, 'booking-1');
    });

    test('createBooking conflict surfaces the status code', () async {
      final fake = fakeDio(
        handler: (options) => jsonResponse(
          options,
          statusCode: 409,
          data: errorEnvelope(
            code: 'CONFLICT',
            statusCode: 409,
            message: 'booking::messages.chair_not_available',
          ),
        ),
      );
      final repository = DioBookingRepository(clientWith(fake));

      await expectLater(
        repository.createBooking(
          chairId: 'chair-1',
          timeSlot: DateTime.utc(2026, 9, 10, 14, 30),
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('cancelBooking posts to the cancel route', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(options, data: successEnvelope());
        },
      );
      final repository = DioBookingRepository(clientWith(fake));

      await repository.cancelBooking('booking-1');

      expect(captured.path, '/client/bookings/booking-1/cancel');
      expect(captured.method, 'POST');
    });
  });
}
