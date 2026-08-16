import 'package:bloc/bloc.dart';

import 'package:core/src/network/dto/auth_response.dto.dart';
import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/network/repositories/auth.repository.dart';
import 'package:core/src/session/auth.event.dart';
import 'package:core/src/session/auth.state.dart';
import 'package:core/src/session/session_signal.entity.dart';
import 'package:core/src/storage/token.storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._tokenStorage) : super(const AuthState()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<SendVerificationCodeRequested>(_onSendVerificationCode);
    on<VerifyEmailRequested>(_onVerifyEmail);
    on<AuthSignalAcknowledged>(_onSignalAcknowledged);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
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
      (state) => state.copyWith(client: client),
      signal: SessionSignal.loginSucceeded,
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
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
      (state) => state.copyWith(client: client),
      signal: SessionSignal.registrationSucceeded,
    );
  }

  Future<void> _onSendVerificationCode(
    SendVerificationCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.sendEmailVerification();
    } catch (_) {
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) {
    return _run(
      emit,
      () => _repository.verifyEmail(event.code),
      (state) => state,
      signal: SessionSignal.verificationSucceeded,
    );
  }

  void _onSignalAcknowledged(
    AuthSignalAcknowledged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(signal: SessionSignal.none));
  }

  Future<ClientDto> _acceptSession(AuthResponseDto response) async {
    if (response.token.isNotEmpty) {
      await _tokenStorage.write(response.token);
    }
    return response.client;
  }

  Future<void> _run(
    Emitter<AuthState> emit,
    Future<void> Function() action,
    AuthState Function(AuthState) onSuccess, {
    SessionSignal signal = SessionSignal.none,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
      signal: SessionSignal.none,
    ));
    try {
      await action();
      emit(onSuccess(state).copyWith(isSubmitting: false, signal: signal));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e,
        signal: SessionSignal.none,
      ));
    }
  }
}
