import 'package:equatable/equatable.dart';

sealed class StylistProfileEvent extends Equatable {
  const StylistProfileEvent();

  @override
  List<Object?> get props => [];
}

class StylistProfileStarted extends StylistProfileEvent {
  const StylistProfileStarted(this.barberId);

  final String barberId;

  @override
  List<Object?> get props => [barberId];
}

class StylistProfileRetried extends StylistProfileEvent {
  const StylistProfileRetried();
}
