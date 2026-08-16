import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => const [];
}

class RestoreRequested extends SessionEvent {}

class LogoutRequested extends SessionEvent {}

class UnauthorizedDetected extends SessionEvent {}

class RequireAuthentication extends SessionEvent {}

class SignalAcknowledged extends SessionEvent {}
