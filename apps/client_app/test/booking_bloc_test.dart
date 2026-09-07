import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/booking/booking.bloc.dart';
import 'package:client_app/src/features/booking/booking.event.dart';
import 'package:client_app/src/features/booking/booking.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeBookingRepository repository;

  setUp(() => repository = FakeBookingRepository());

  BookingBloc bloc() => BookingBloc(repository);

  group('BookingsStarted', () {
    blocTest<BookingBloc, BookingState>(
      'loads the upcoming page on first view',
      build: bloc,
      act: (bloc) => bloc.add(const BookingsStarted()),
      verify: (bloc) {
        expect(bloc.state.page.items, hasLength(1));
        expect(repository.lastStatus, 'upcoming');
      },
    );

    blocTest<BookingBloc, BookingState>(
      'second start is a no-op once items are loaded',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(testBookingPage()),
      ),
      act: (bloc) => bloc.add(const BookingsStarted()),
      expect: () => [],
      verify: (_) {
        expect(repository.getBookingsCalls, 0);
      },
    );

    blocTest<BookingBloc, BookingState>(
      'empty first load fails the page',
      build: bloc,
      setUp: () => repository.error = offline(),
      act: (bloc) => bloc.add(const BookingsStarted()),
      verify: (bloc) {
        expect(bloc.state.page.hasFailedFirst, isTrue);
      },
    );
  });

  group('BookingsFilterChanged', () {
    blocTest<BookingBloc, BookingState>(
      'switching filter resets and reloads with the new status',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(testBookingPage()),
      ),
      act: (bloc) => bloc.add(const BookingsFilterChanged('past')),
      verify: (bloc) {
        expect(bloc.state.filter, 'past');
        expect(repository.lastStatus, 'past');
      },
    );

    blocTest<BookingBloc, BookingState>(
      'same filter is a no-op',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(testBookingPage()),
      ),
      act: (bloc) => bloc.add(const BookingsFilterChanged('upcoming')),
      expect: () => [],
    );
  });

  group('BookingsCancelRequested', () {
    blocTest<BookingBloc, BookingState>(
      'cancel calls the repository then reloads the list',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(testBookingPage()),
      ),
      act: (bloc) => bloc.add(const BookingsCancelRequested('booking-1')),
      verify: (bloc) {
        expect(repository.cancelCalls, 1);
        expect(repository.lastCancelledId, 'booking-1');
        expect(repository.getBookingsCalls, 1);
        expect(bloc.state.cancellingId, isNull);
      },
    );

    blocTest<BookingBloc, BookingState>(
      'cancel failure keeps the list and records the error',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(testBookingPage()),
      ),
      setUp: () => repository.cancelError = offline(),
      act: (bloc) => bloc.add(const BookingsCancelRequested('booking-1')),
      verify: (bloc) {
        expect(bloc.state.page.items, hasLength(1));
        expect(bloc.state.error, isA<NetworkException>());
        expect(bloc.state.cancellingId, isNull);
      },
    );
  });

  group('pagination', () {
    blocTest<BookingBloc, BookingState>(
      'load more appends the next page',
      build: bloc,
      seed: () => BookingState(
        page: Paged<BookingDto>.initial().succeeded(
          testBookingPage(
            bookings: [testBooking(id: 'booking-1')],
            totalPages: 2,
          ),
        ),
      ),
      setUp: () {
        repository.morePage = testBookingPage(
          bookings: [testBooking(id: 'booking-2')],
          currentPage: 2,
          totalPages: 2,
        );
      },
      act: (bloc) => bloc.add(const BookingsLoadMoreRequested()),
      verify: (bloc) {
        expect(repository.lastPage, 2);
        expect(
          bloc.state.page.items.map((booking) => booking.id),
          ['booking-1', 'booking-2'],
        );
      },
    );
  });

  group('BookingsRetryRequested', () {
    blocTest<BookingBloc, BookingState>(
      'retry reloads the first page',
      build: bloc,
      act: (bloc) => bloc.add(const BookingsRetryRequested()),
      verify: (bloc) {
        expect(repository.getBookingsCalls, 1);
        expect(bloc.state.page.items, hasLength(1));
      },
    );
  });
}
