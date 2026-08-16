import 'package:equatable/equatable.dart';

import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/session/auth_status.entity.dart';
import 'package:core/src/session/session_notice.entity.dart';

class SessionState extends Equatable {
  const SessionState({
    this.status = AuthStatus.unknown,
    this.client,
    this.isLoading = false,
    this.error,
    this.notice = SessionNotice.none,
  });

  final AuthStatus status;
  final ClientDto? client;
  final bool isLoading;
  final Object? error;
  final SessionNotice notice;

  bool get isAuthenticated => status.isAuthenticated;

  SessionState copyWith({
    AuthStatus? status,
    ClientDto? client,
    bool? isLoading,
    Object? error,
    bool clearError = false,
    SessionNotice? notice,
  }) {
    return SessionState(
      status: status ?? this.status,
      client: client ?? this.client,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [status, client, isLoading, error, notice];
}
