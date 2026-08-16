import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
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
  List<Object?> get props => [name, email, password, passwordConfirmation, phone];
}

class SendVerificationCodeRequested extends AuthEvent {}

class VerifyEmailRequested extends AuthEvent {
  const VerifyEmailRequested({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}

class AuthSignalAcknowledged extends AuthEvent {}
