import 'package:core/core.dart';

abstract class BookingRepository {
  Future<PaginatedData<BookingDto>> getBookings({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<BookingDto> createBooking({
    String? chairId,
    String? barberId,
    required DateTime timeSlot,
    List<String>? serviceIds,
    double? atHomeLatitude,
    double? atHomeLongitude,
  });

  Future<void> cancelBooking(String id);
}

class DioBookingRepository implements BookingRepository {
  const DioBookingRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedData<BookingDto>> getBookings({
    String? status,
    int page = 1,
    int perPage = 20,
  }) {
    return _apiClient.getPaginated<BookingDto>(
      BookingEndpoints.bookings,
      queryParameters: {
        'status': ?status,
        'page': page,
        'per_page': perPage,
      },
      itemParser: (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BookingDto> createBooking({
    String? chairId,
    String? barberId,
    required DateTime timeSlot,
    List<String>? serviceIds,
    double? atHomeLatitude,
    double? atHomeLongitude,
  }) {
    final slot = timeSlot.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final formatted =
        '${slot.year}-${two(slot.month)}-${two(slot.day)} ${two(slot.hour)}:${two(slot.minute)}:${two(slot.second)}';
    return _apiClient.post<BookingDto>(
      BookingEndpoints.bookings,
      data: {
        'chair_id': ?chairId,
        'barber_id': ?barberId,
        'time_slot': formatted,
        'service_ids': ?serviceIds,
        if (atHomeLatitude != null && atHomeLongitude != null)
          'at_home_location': {
            'latitude': atHomeLatitude,
            'longitude': atHomeLongitude,
          },
      },
      parser: (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<void> cancelBooking(String id) {
    return _apiClient.post<void>(
      BookingEndpoints.cancelBooking.replaceFirst('{booking}', id),
      parser: _discardBody,
    );
  }

  static void _discardBody(dynamic _) {}
}
