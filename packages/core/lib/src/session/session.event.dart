import 'package:equatable/equatable.dart';

import 'package:core/src/network/dto/client.dto.dart';

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

class SessionAuthenticated extends SessionEvent {
  const SessionAuthenticated(this.client);

  final ClientDto client;

  @override
  List<Object?> get props => [client];
}
