import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class BookingState extends Equatable {
  const BookingState({
    this.filter = 'upcoming',
    this.page = const Paged<BookingDto>.initial(),
    this.cancellingId,
    this.error,
  });

  final String filter;
  final Paged<BookingDto> page;
  final String? cancellingId;
  final Object? error;

  BookingState copyWith({
    String? filter,
    Paged<BookingDto>? page,
    String? cancellingId,
    bool clearCancelling = false,
    Object? error,
    bool clearError = false,
  }) {
    return BookingState(
      filter: filter ?? this.filter,
      page: page ?? this.page,
      cancellingId: clearCancelling ? null : cancellingId ?? this.cancellingId,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [filter, page, cancellingId, error];
}
