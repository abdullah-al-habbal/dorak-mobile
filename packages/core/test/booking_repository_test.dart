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
