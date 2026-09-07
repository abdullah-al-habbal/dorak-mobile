import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/booking/booking.event.dart';
import 'package:client_app/src/features/booking/booking.state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._repository) : super(const BookingState()) {
    on<BookingsStarted>(_onStarted);
    on<BookingsFilterChanged>(_onFilterChanged);
    on<BookingsRefreshRequested>(_onRefresh);
    on<BookingsLoadMoreRequested>(_onLoadMore);
    on<BookingsCancelRequested>(_onCancel);
    on<BookingsRetryRequested>(_onRetry);
  }

  final BookingRepository _repository;

  Future<void> _onStarted(
    BookingsStarted event,
    Emitter<BookingState> emit,
  ) async {
    if (state.page.items.isNotEmpty || state.page.isBusy) return;
    await _loadFirst(emit);
  }

  Future<void> _onFilterChanged(
    BookingsFilterChanged event,
    Emitter<BookingState> emit,
  ) async {
    if (event.filter == state.filter) return;
    emit(
      state.copyWith(
        filter: event.filter,
        page: state.page.reset(),
        clearError: true,
      ),
    );
    await _loadFirst(emit);
  }

  Future<void> _onRefresh(
    BookingsRefreshRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(page: state.page.refreshing(), clearError: true));
    await _fetchFirst(emit);
  }

  Future<void> _onLoadMore(
    BookingsLoadMoreRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (!state.page.hasMore || state.page.isBusy) return;
    emit(state.copyWith(page: state.page.loadingMore()));
    try {
      final page = await _repository.getBookings(
        status: state.filter,
        page: state.page.meta.currentPage + 1,
      );
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.succeeded(page)));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.failed(error)));
    }
  }

  Future<void> _onCancel(
    BookingsCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (state.cancellingId != null) return;
    emit(state.copyWith(cancellingId: event.id, clearError: true));
    try {
      await _repository.cancelBooking(event.id);
      if (emit.isDone) return;
      emit(
        state.copyWith(
          clearCancelling: true,
          page: state.page.refreshing(),
        ),
      );
      await _fetchFirst(emit);
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(clearCancelling: true, error: error));
    }
  }

  Future<void> _onRetry(
    BookingsRetryRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (state.page.hasFailedMore) {
      await _onLoadMore(const BookingsLoadMoreRequested(), emit);
      return;
    }
    await _loadFirst(emit);
  }

  Future<void> _loadFirst(Emitter<BookingState> emit) async {
    emit(state.copyWith(page: state.page.loadingFirst(), clearError: true));
    await _fetchFirst(emit);
  }

  Future<void> _fetchFirst(Emitter<BookingState> emit) async {
    try {
      final page = await _repository.getBookings(status: state.filter);
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.succeeded(page)));
    } catch (error) {
      if (emit.isDone) return;
      if (state.page.items.isNotEmpty) {
        emit(
          state.copyWith(
            page: state.page.succeeded(
              PaginatedData(
                data: state.page.items,
                meta: state.page.meta,
              ),
            ),
            error: error,
          ),
        );
      } else {
        emit(state.copyWith(page: state.page.failed(error)));
      }
    }
  }
}
