import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:core/src/network/dto/auth_response.dto.dart';
import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/exceptions/network.exception.dart';
import 'package:core/src/network/repositories/auth.repository.dart';
import 'package:core/src/session/auth_status.entity.dart';
import 'package:core/src/session/session.event.dart';
import 'package:core/src/session/session.state.dart';
import 'package:core/src/session/session_notice.entity.dart';
import 'package:core/src/storage/token.storage.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._repository, this._tokenStorage)
      : super(const SessionState()) {
    on<RestoreRequested>(_onRestore);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<SendVerificationCodeRequested>(_onSendVerificationCode);
    on<VerifyEmailRequested>(_onVerifyEmail);
    on<LogoutRequested>(_onLogout);
    on<UnauthorizedDetected>(_onUnauthorizedDetected);
    on<RequireAuthentication>(_onRequireAuthentication);
    on<NoticeAcknowledged>(_onNoticeAcknowledged);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<void>? _restoration;

  /// Completes once the session status resolves (leaves [AuthStatus.unknown]).
  /// Memoised: concurrent callers join the same in-flight restore.
  Future<void> get ready => _restoration ??= _restoreUntilResolved();

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
      notice: SessionNotice.none,
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

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<SessionState> emit,
  ) async {
    ClientDto? client;
    await _run(
      emit,
      () async {
        final response = await _repository.login(
          email: event.email,
          password: event.password,
        );
        client = await _acceptSession(response);
      },
      (state) => state.copyWith(
        status: AuthStatus.authenticated,
        client: client,
      ),
      notice: SessionNotice.loginSucceeded,
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<SessionState> emit,
  ) async {
    ClientDto? client;
    await _run(
      emit,
      () async {
        final response = await _repository.register(
          name: event.name,
          email: event.email,
          password: event.password,
          passwordConfirmation: event.passwordConfirmation,
          phone: event.phone,
        );
        client = await _acceptSession(response);
      },
      (state) => state.copyWith(
        status: AuthStatus.authenticated,
        client: client,
      ),
      notice: SessionNotice.registrationSucceeded,
    );
  }

  Future<void> _onSendVerificationCode(
    SendVerificationCodeRequested event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _repository.sendEmailVerification();
    } catch (_) {
      // Registration already succeeded; a failed dispatch must not block
      // reaching the verify screen, which has Resend.
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailRequested event,
    Emitter<SessionState> emit,
  ) {
    return _run(
      emit,
      () => _repository.verifyEmail(event.code),
      (state) => state,
      notice: SessionNotice.verificationSucceeded,
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      notice: SessionNotice.none,
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
        notice: SessionNotice.none,
      ));
    }
  }

  Future<void> _onUnauthorizedDetected(
    UnauthorizedDetected event,
    Emitter<SessionState> emit,
  ) async {
    if (state.notice == SessionNotice.sessionExpired) return;
    emit(state.copyWith(notice: SessionNotice.sessionExpired));
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
      notice: SessionNotice.sessionExpired,
    ));
  }

  void _onRequireAuthentication(
    RequireAuthentication event,
    Emitter<SessionState> emit,
  ) {
    emit(state.copyWith(notice: SessionNotice.authenticationRequired));
  }

  void _onNoticeAcknowledged(
    NoticeAcknowledged event,
    Emitter<SessionState> emit,
  ) {
    emit(state.copyWith(notice: SessionNotice.none));
  }

  Future<ClientDto> _acceptSession(AuthResponseDto response) async {
    if (response.token.isNotEmpty) {
      await _tokenStorage.write(response.token);
    }
    return response.client;
  }

  Future<void> _run(
    Emitter<SessionState> emit,
    Future<void> Function() action,
    SessionState Function(SessionState) onSuccess, {
    SessionNotice notice = SessionNotice.none,
  }) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      notice: SessionNotice.none,
    ));
    try {
      await action();
      emit(onSuccess(state).copyWith(isLoading: false, notice: notice));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e,
        notice: SessionNotice.none,
      ));
    }
  }
}
