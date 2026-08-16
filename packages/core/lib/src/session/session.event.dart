import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => const [];
}

class RestoreRequested extends SessionEvent {}

class LoginRequested extends SessionEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends SessionEvent {
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;

  @override
  List<Object?> get props =>
      [name, email, password, passwordConfirmation, phone];
}

class SendVerificationCodeRequested extends SessionEvent {}

class VerifyEmailRequested extends SessionEvent {
  const VerifyEmailRequested({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}

class LogoutRequested extends SessionEvent {}

class UnauthorizedDetected extends SessionEvent {}

class RequireAuthentication extends SessionEvent {}

class NoticeAcknowledged extends SessionEvent {}
