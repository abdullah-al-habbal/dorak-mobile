import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.page = const Paged<ServiceHistoryDto>.initial(),
    this.rebookingId,
    this.rebooked = false,
    this.rebookError,
  });

  final Paged<ServiceHistoryDto> page;
  final String? rebookingId;
  final bool rebooked;
  final Object? rebookError;

  HistoryState copyWith({
    Paged<ServiceHistoryDto>? page,
    String? rebookingId,
    bool clearRebooking = false,
    bool? rebooked,
    Object? rebookError,
    bool clearRebookError = false,
  }) {
    return HistoryState(
      page: page ?? this.page,
      rebookingId: clearRebooking ? null : rebookingId ?? this.rebookingId,
      rebooked: rebooked ?? this.rebooked,
      rebookError: clearRebookError ? null : rebookError ?? this.rebookError,
    );
  }

  @override
  List<Object?> get props => [page, rebookingId, rebooked, rebookError];
}