import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage();
  });

  AuthBloc bloc() => AuthBloc(repository, storage);

  group('login', () {
    blocTest<AuthBloc, AuthState>(
      'stores the token, exposes the client and signals the router',
      build: bloc,
      act: (bloc) => bloc.add(
        LoginRequested(email: 'sara@example.com', password: 'secret123'),
      ),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          client: FakeAuthRepository.defaultClient,
          signal: SessionSignal.loginSucceeded,
        ),
      ],
      verify: (bloc) {
        expect(storage.token, 'login-token');
        expect(bloc.state.client?.email, 'sara@example.com');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a rejection surfaces in state and stores no token',
      build: () {
        repository.loginError = unauthorized();
        return AuthBloc(repository, storage);
      },
      act: (bloc) => bloc.add(
        LoginRequested(email: 'sara@example.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState(isSubmitting: true),
        AuthState(isSubmitting: false, error: unauthorized()),
      ],
      verify: (bloc) {
        expect(bloc.state.client, isNull);
        expect(storage.token, isNull);
      },
    );
  });

  group('register', () {
    blocTest<AuthBloc, AuthState>(
      'forwards the confirmation and stores the returned token',
      build: bloc,
      act: (bloc) => bloc.add(
        const RegisterRequested(
          name: 'Sara',
          email: 'sara@example.com',
          password: 'secret123',
          passwordConfirmation: 'secret123',
        ),
      ),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          client: FakeAuthRepository.defaultClient,
          signal: SessionSignal.registrationSucceeded,
        ),
      ],
      verify: (bloc) {
        expect(
          repository.registeredPayload?['password_confirmation'],
          'secret123',
        );
        expect(storage.token, 'register-token');
      },
    );
  });

  group('verification', () {
    blocTest<AuthBloc, AuthState>(
      'verifyEmail forwards the code and signals completion',
      build: bloc,
      act: (bloc) => bloc.add(const VerifyEmailRequested(code: '123456')),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(signal: SessionSignal.verificationSucceeded),
      ],
      verify: (_) => expect(repository.verifiedCode, '123456'),
    );

    blocTest<AuthBloc, AuthState>(
      'verifyEmail surfaces a rejected code in state',
      build: () {
        repository.verifyEmailError = const ValidationException(
          statusCode: 422,
          code: 'VALIDATION_FAILED',
          message: 'core::messages.invalid_verification_code',
          errors: {'code': ['invalid']},
        );
        return AuthBloc(repository, storage);
      },
      act: (bloc) => bloc.add(const VerifyEmailRequested(code: '000000')),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          isSubmitting: false,
          error: ValidationException(
            statusCode: 422,
            code: 'VALIDATION_FAILED',
            message: 'core::messages.invalid_verification_code',
            errors: {'code': ['invalid']},
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sendVerificationCode calls the dispatch route',
      build: bloc,
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => <AuthState>[],
      verify: (_) => expect(repository.sendVerificationCalls, 1),
    );

    blocTest<AuthBloc, AuthState>(
      'a failed dispatch is swallowed without touching state',
      build: () {
        repository.sendVerificationError = offline();
        return AuthBloc(repository, storage);
      },
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => <AuthState>[],
      verify: (bloc) {
        expect(repository.sendVerificationCalls, 1);
        expect(bloc.state.error, isNull);
      },
    );
  });

  group('signals', () {
    blocTest<AuthBloc, AuthState>(
      'AuthSignalAcknowledged clears the current signal but keeps the client',
      build: bloc,
      act: (bloc) async {
        bloc.add(const RegisterRequested(
          name: 'Sara',
          email: 'sara@example.com',
          password: 'secret123',
          passwordConfirmation: 'secret123',
        ));
        bloc.add(AuthSignalAcknowledged());
      },
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          client: FakeAuthRepository.defaultClient,
          signal: SessionSignal.registrationSucceeded,
        ),
        const AuthState(client: FakeAuthRepository.defaultClient),
      ],
      verify: (bloc) => expect(bloc.state.signal, SessionSignal.none),
    );
  });
}
