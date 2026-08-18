import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/auth/password_recovery.event.dart';
import 'package:client_app/src/features/auth/password_recovery.state.dart';
import 'package:client_app/src/features/auth/recovery_signal.entity.dart';

class PasswordRecoveryBloc
    extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  PasswordRecoveryBloc(this._repository)
      : super(const PasswordRecoveryState()) {
    on<RecoveryCodeRequested>(_onCodeRequested);
    on<RecoveryCodeEntered>(_onCodeEntered);
    on<RecoveryPasswordSubmitted>(_onPasswordSubmitted);
    on<RecoveryRestarted>(_onRestarted);
    on<RecoverySignalAcknowledged>(_onSignalAcknowledged);
  }

  final AuthRepository _repository;

  Future<void> _onCodeRequested(
    RecoveryCodeRequested event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(
      email: event.email,
      isSubmitting: true,
      clearError: true,
      clearFieldErrors: true,
      signal: RecoverySignal.none,
    ));

    try {
      await _repository.forgotPassword(event.email);
    } on ValidationException {
      emit(state.copyWith(isSubmitting: false, signal: RecoverySignal.codeSent));
      return;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e));
      return;
    }

    emit(state.copyWith(isSubmitting: false, signal: RecoverySignal.codeSent));
  }

  void _onCodeEntered(
    RecoveryCodeEntered event,
    Emitter<PasswordRecoveryState> emit,
  ) {
    emit(state.copyWith(
      code: event.code,
      clearError: true,
      clearFieldErrors: true,
      signal: RecoverySignal.codeAccepted,
    ));
  }

  Future<void> _onPasswordSubmitted(
    RecoveryPasswordSubmitted event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFieldErrors: true,
      signal: RecoverySignal.none,
    ));

    try {
      await _repository.resetPassword(
        email: state.email,
        code: state.code,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
    } on ValidationException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e,
        fieldErrors: e.errors,
      ));
      return;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e));
      return;
    }

    emit(state.copyWith(
      isSubmitting: false,
      signal: RecoverySignal.passwordReset,
    ));
  }

  void _onRestarted(
    RecoveryRestarted event,
    Emitter<PasswordRecoveryState> emit,
  ) {
    emit(const PasswordRecoveryState());
  }

  void _onSignalAcknowledged(
    RecoverySignalAcknowledged event,
    Emitter<PasswordRecoveryState> emit,
  ) {
    emit(state.copyWith(signal: RecoverySignal.none));
  }
}
