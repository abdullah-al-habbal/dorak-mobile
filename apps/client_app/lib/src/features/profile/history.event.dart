import 'package:equatable/equatable.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

class HistoryRefreshRequested extends HistoryEvent {
  const HistoryRefreshRequested();
}

class HistoryLoadMoreRequested extends HistoryEvent {
  const HistoryLoadMoreRequested();
}

class HistoryRetryRequested extends HistoryEvent {
  const HistoryRetryRequested();
}

class HistoryRebookRequested extends HistoryEvent {
  const HistoryRebookRequested(this.id, this.timeSlot);

  final String id;
  final DateTime timeSlot;

  @override
  List<Object?> get props => [id, timeSlot];
}

class HistoryRebookAcknowledged extends HistoryEvent {
  const HistoryRebookAcknowledged();
}