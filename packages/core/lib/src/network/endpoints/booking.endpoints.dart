class BookingEndpoints {
  BookingEndpoints._();

  static const String bookings = '/bookings';
  static const String bookingDetail = '/bookings/{booking}';
  static const String cancelBooking = '/client/bookings/{booking}/cancel';
}
