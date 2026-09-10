import 'package:equatable/equatable.dart';

sealed class BranchDetailEvent extends Equatable {
  const BranchDetailEvent();

  @override
  List<Object?> get props => [];
}

class BranchDetailStarted extends BranchDetailEvent {
  const BranchDetailStarted(this.branchId);

  final String branchId;

  @override
  List<Object?> get props => [branchId];
}

class BranchDetailChairSelected extends BranchDetailEvent {
  const BranchDetailChairSelected(this.chairId);

  final String? chairId;

  @override
  List<Object?> get props => [chairId];
}

class BranchDetailServicesChanged extends BranchDetailEvent {
  const BranchDetailServicesChanged(this.serviceIds);

  final List<String> serviceIds;

  @override
  List<Object?> get props => [serviceIds];
}

class BranchDetailTimeChanged extends BranchDetailEvent {
  const BranchDetailTimeChanged(this.time);

  final DateTime? time;

  @override
  List<Object?> get props => [time];
}

class BranchDetailBookingSubmitted extends BranchDetailEvent {
  const BranchDetailBookingSubmitted();
}

class BranchDetailRetried extends BranchDetailEvent {
  const BranchDetailRetried();
}
