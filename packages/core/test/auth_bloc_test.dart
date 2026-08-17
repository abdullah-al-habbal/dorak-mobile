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
          signal: AuthSignal.loginSucceeded,
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
          signal: AuthSignal.registrationSucceeded,
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
        const AuthState(signal: AuthSignal.verificationSucceeded),
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
      'a user-initiated resend reports progress and success',
      build: bloc,
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(),
      ],
      verify: (_) => expect(repository.sendVerificationCalls, 1),
    );

    blocTest<AuthBloc, AuthState>(
      'a failed resend surfaces the error instead of failing silently',
      build: () {
        repository.sendVerificationError = offline();
        return AuthBloc(repository, storage);
      },
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => [
        const AuthState(isSubmitting: true),
        AuthState(error: offline()),
      ],
      verify: (bloc) {
        expect(repository.sendVerificationCalls, 1);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'registration dispatches the code itself and stays non-blocking when it fails',
      build: () {
        repository.sendVerificationError = offline();
        return AuthBloc(repository, storage);
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        name: 'Sara',
        email: 'sara@example.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
      )),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          client: FakeAuthRepository.defaultClient,
          signal: AuthSignal.registrationSucceeded,
        ),
      ],
      verify: (bloc) {
        expect(repository.sendVerificationCalls, 1);
        expect(bloc.state.error, isNull);
        expect(storage.token, 'register-token');
      },
    );
  });

  group('signals', () {
    blocTest<AuthBloc, AuthState>(
      'AuthSignalAcknowledged clears both the signal and the client',
      build: bloc,
      act: (bloc) async {
        bloc.add(const RegisterRequested(
          name: 'Sara',
          email: 'sara@example.com',
          password: 'secret123',
          passwordConfirmation: 'secret123',
        ));
        await pumpEventQueue();
        bloc.add(AuthSignalAcknowledged());
      },
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          client: FakeAuthRepository.defaultClient,
          signal: AuthSignal.registrationSucceeded,
        ),
        const AuthState(),
      ],
      verify: (bloc) {
        expect(bloc.state.signal, AuthSignal.none);
        expect(
          bloc.state.client,
          isNull,
          reason: 'a stale client must not survive to re-authenticate a '
              'session that has since expired or been logged out',
        );
      },
    );
  });
}
