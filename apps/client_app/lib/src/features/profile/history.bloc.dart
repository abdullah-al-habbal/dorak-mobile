import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/profile/history.event.dart';
import 'package:client_app/src/features/profile/history.state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repository) : super(const HistoryState()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryRefreshRequested>(_onRefresh);
    on<HistoryLoadMoreRequested>(_onLoadMore);
    on<HistoryRetryRequested>(_onRetry);
    on<HistoryRebookRequested>(_onRebook);
    on<HistoryRebookAcknowledged>(_onRebookAcknowledged);
  }

  final HistoryRepository _repository;

  Future<void> _onStarted(
    HistoryStarted event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.page.items.isNotEmpty || state.page.isBusy) return;
    await _loadFirst(emit);
  }

  Future<void> _onRefresh(
    HistoryRefreshRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(page: state.page.refreshing(), clearRebookError: true));
    await _fetchFirst(emit);
  }

  Future<void> _onLoadMore(
    HistoryLoadMoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (!state.page.hasMore || state.page.isBusy) return;
    emit(state.copyWith(page: state.page.loadingMore()));
    try {
      final page = await _repository.getHistory(
        page: state.page.meta.currentPage + 1,
      );
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.succeeded(page)));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.failed(error)));
    }
  }

  Future<void> _onRetry(
    HistoryRetryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.page.hasFailedMore) {
      await _onLoadMore(const HistoryLoadMoreRequested(), emit);
      return;
    }
    await _loadFirst(emit);
  }

  Future<void> _onRebook(
    HistoryRebookRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.rebookingId != null) return;
    emit(state.copyWith(rebookingId: event.id));
    try {
      await _repository.rebookFromHistory(event.id, event.timeSlot);
      if (emit.isDone) return;
      emit(state.copyWith(clearRebooking: true, rebooked: true));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(clearRebooking: true, rebookError: error));
    }
  }

  void _onRebookAcknowledged(
    HistoryRebookAcknowledged event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(rebooked: false));
  }

  Future<void> _loadFirst(Emitter<HistoryState> emit) async {
    emit(state.copyWith(page: state.page.loadingFirst(), clearRebookError: true));
    await _fetchFirst(emit);
  }

  Future<void> _fetchFirst(Emitter<HistoryState> emit) async {
    try {
      final page = await _repository.getHistory();
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
            rebookError: error,
          ),
        );
      } else {
        emit(state.copyWith(page: state.page.failed(error)));
      }
    }
  }
}