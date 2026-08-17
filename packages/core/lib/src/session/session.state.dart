import 'package:equatable/equatable.dart';

import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/session/auth_status.entity.dart';
import 'package:core/src/session/session_signal.entity.dart';

class SessionState extends Equatable {
  const SessionState({
    this.status = AuthStatus.unknown,
    this.client,
    this.isLoading = false,
    this.error,
    this.signal = SessionSignal.none,
  });

  final AuthStatus status;
  final ClientDto? client;
  final bool isLoading;
  final Object? error;
  final SessionSignal signal;

  bool get isAuthenticated => status.isAuthenticated;

  SessionState copyWith({
    AuthStatus? status,
    ClientDto? client,
    bool clearClient = false,
    bool? isLoading,
    Object? error,
    bool clearError = false,
    SessionSignal? signal,
  }) {
    return SessionState(
      status: status ?? this.status,
      client: clearClient ? null : client ?? this.client,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      signal: signal ?? this.signal,
    );
  }

  @override
  List<Object?> get props => [status, client, isLoading, error, signal];
}
