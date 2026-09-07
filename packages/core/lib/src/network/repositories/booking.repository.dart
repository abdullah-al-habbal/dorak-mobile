import 'package:core/core.dart';

abstract class BookingRepository {
  Future<PaginatedData<BookingDto>> getBookings({
    String? status,
    int page = 1,
    int perPage = 20,
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
  Future<void> cancelBooking(String id) {
    return _apiClient.post<void>(
      BookingEndpoints.cancelBooking.replaceFirst('{booking}', id),
      parser: _discardBody,
    );
  }

  static void _discardBody(dynamic _) {}
}
