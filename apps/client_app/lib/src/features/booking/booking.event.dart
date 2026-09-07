import 'package:equatable/equatable.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingsStarted extends BookingEvent {
  const BookingsStarted();
}

class BookingsFilterChanged extends BookingEvent {
  const BookingsFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

class BookingsRefreshRequested extends BookingEvent {
  const BookingsRefreshRequested();
}

class BookingsLoadMoreRequested extends BookingEvent {
  const BookingsLoadMoreRequested();
}

class BookingsCancelRequested extends BookingEvent {
  const BookingsCancelRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class BookingsRetryRequested extends BookingEvent {
  const BookingsRetryRequested();
}
