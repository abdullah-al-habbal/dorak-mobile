import 'package:equatable/equatable.dart';

import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/session/auth_signal.entity.dart';

class AuthState extends Equatable {
  const AuthState({
    this.client,
    this.isSubmitting = false,
    this.error,
    this.signal = AuthSignal.none,
  });

  final ClientDto? client;
  final bool isSubmitting;
  final Object? error;
  final AuthSignal signal;

  AuthState copyWith({
    ClientDto? client,
    bool? isSubmitting,
    Object? error,
    bool clearError = false,
    AuthSignal? signal,
  }) {
    return AuthState(
      client: client ?? this.client,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      signal: signal ?? this.signal,
    );
  }

  @override
  List<Object?> get props => [client, isSubmitting, error, signal];
}
