import 'package:equatable/equatable.dart';

abstract class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();

  @override
  List<Object?> get props => const [];
}

class RecoveryCodeRequested extends PasswordRecoveryEvent {
  const RecoveryCodeRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class RecoveryCodeEntered extends PasswordRecoveryEvent {
  const RecoveryCodeEntered(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class RecoveryPasswordSubmitted extends PasswordRecoveryEvent {
  const RecoveryPasswordSubmitted({
    required this.password,
    required this.passwordConfirmation,
  });

  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [password, passwordConfirmation];
}

class RecoveryRestarted extends PasswordRecoveryEvent {}

class RecoverySignalAcknowledged extends PasswordRecoveryEvent {}
