import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/exceptions/network.exception.dart';
import 'package:core/src/network/repositories/auth.repository.dart';
import 'package:core/src/session/auth.bloc.dart';
import 'package:core/src/session/auth.state.dart';
import 'package:core/src/session/auth_status.entity.dart';
import 'package:core/src/session/session.event.dart';
import 'package:core/src/session/session.state.dart';
import 'package:core/src/session/session_signal.entity.dart';
import 'package:core/src/storage/token.storage.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._repository, this._tokenStorage, this._authBloc)
      : super(const SessionState()) {
    on<RestoreRequested>(_onRestore);
    on<LogoutRequested>(_onLogout);
    on<UnauthorizedDetected>(_onUnauthorizedDetected);
    on<RequireAuthentication>(_onRequireAuthentication);
    on<SignalAcknowledged>(_onSignalAcknowledged);
    on<AuthSessionMirror>(_onAuthSessionMirror);
    _authSubscription = _authBloc.stream.listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _authSubscription;

  Future<void>? _restoration;

  Future<void> get ready => _restoration ??= _restoreUntilResolved();

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  void _onAuthChanged(AuthState authState) {
    if (authState.client == null) return;
    if (state.status == AuthStatus.authenticated &&
        state.client == authState.client) {
      return;
    }
    add(AuthSessionMirror(authState.client!));
  }

  void _onAuthSessionMirror(
    AuthSessionMirror event,
    Emitter<SessionState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      client: event.client,
    ));
  }

  Future<void> _restoreUntilResolved() async {
    if (state.status != AuthStatus.unknown) return;
    final completer = Completer<void>();
    late final StreamSubscription<SessionState> subscription;
    subscription = stream.listen((next) {
      if (next.status != AuthStatus.unknown && !completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });
    add(RestoreRequested());
    await completer.future;
  }

  Future<void> _onRestore(
    RestoreRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      signal: SessionSignal.none,
    ));
    var next = state;
    try {
      final stored = await _tokenStorage.read();
      if (stored == null) {
        next = state.copyWith(status: AuthStatus.guest);
      } else {
        try {
          final rotated = await _repository.refreshToken();
          if (rotated.isNotEmpty) {
            await _tokenStorage.write(rotated);
          }
          next = state.copyWith(status: AuthStatus.authenticated);
        } on NetworkException catch (e) {
          next = state.copyWith(status: AuthStatus.authenticated, error: e);
        } on ApiException catch (e) {
          if (e.isUnauthorized || e.isForbidden) {
            await _tokenStorage.clear();
            next = state.copyWith(status: AuthStatus.guest);
          } else {
            next = state.copyWith(status: AuthStatus.authenticated, error: e);
          }
        }
      }
    } finally {
      emit(next.copyWith(isLoading: false));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      signal: SessionSignal.none,
    ));
    Object? error;
    try {
      await _repository.logout();
    } catch (e) {
      error = e;
    } finally {
      try {
        await _tokenStorage.clear();
      } catch (e) {
        error ??= e;
      }
      emit(SessionState(
        status: AuthStatus.guest,
        isLoading: false,
        error: error,
        signal: SessionSignal.none,
      ));
    }
  }

  Future<void> _onUnauthorizedDetected(
    UnauthorizedDetected event,
    Emitter<SessionState> emit,
  ) async {
    if (state.signal == SessionSignal.sessionExpired) return;
    emit(state.copyWith(signal: SessionSignal.sessionExpired));
    Object? error;
    try {
      await _tokenStorage.clear();
    } catch (e) {
      error = e;
    }
    emit(state.copyWith(
      status: AuthStatus.guest,
      client: null,
      isLoading: false,
      error: error,
      signal: SessionSignal.sessionExpired,
    ));
  }

  void _onRequireAuthentication(
    RequireAuthentication event,
    Emitter<SessionState> emit,
  ) {
    emit(state.copyWith(signal: SessionSignal.authenticationRequired));
  }

  void _onSignalAcknowledged(
    SignalAcknowledged event,
    Emitter<SessionState> emit,
  ) {
    emit(state.copyWith(signal: SessionSignal.none));
  }
}
