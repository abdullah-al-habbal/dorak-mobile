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

  SessionBloc bloc() => SessionBloc(repository, storage);

  group('restore', () {
    blocTest<SessionBloc, SessionState>(
      'no stored token resolves to guest without hitting the network',
      build: bloc,
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.guest),
      ],
      verify: (_) => expect(repository.refreshTokenCalls, 0),
    );

    blocTest<SessionBloc, SessionState>(
      'a valid token authenticates and persists the rotated token',
      build: () {
        storage.token = 'stored-token';
        repository.refreshedToken = 'fresh-token';
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.authenticated),
      ],
      verify: (_) {
        expect(storage.token, 'fresh-token');
        expect(repository.refreshTokenCalls, 1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      '401 clears the token and falls back to guest',
      build: () {
        storage.token = 'revoked-token';
        repository.refreshTokenError = unauthorized();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.guest),
      ],
      verify: (_) {
        expect(storage.token, isNull);
        expect(storage.clearCount, 1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'offline start keeps the session instead of logging out',
      // Sanctum tokens have no server-side expiry, so a transport failure is no
      // evidence the session died.
      build: () {
        storage.token = 'stored-token';
        repository.refreshTokenError = offline();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        SessionState(status: AuthStatus.authenticated, error: offline()),
      ],
      verify: (_) {
        expect(storage.token, 'stored-token');
        expect(storage.clearCount, 0);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'a server error keeps the session',
      build: () {
        storage.token = 'stored-token';
        repository.refreshTokenError = const ApiException(
          statusCode: 500,
          code: 'SERVER_ERROR',
          message: 'boom',
        );
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        SessionState(
          status: AuthStatus.authenticated,
          error: const ApiException(
            statusCode: 500,
            code: 'SERVER_ERROR',
            message: 'boom',
          ),
        ),
      ],
      verify: (_) => expect(storage.token, 'stored-token'),
    );

    blocTest<SessionBloc, SessionState>(
      'ready joins the in-flight restore instead of starting another',
      build: () {
        storage.token = 'stored-token';
        return SessionBloc(repository, storage);
      },
      act: (bloc) async {
        await Future.wait([bloc.ready, bloc.ready, bloc.ready]);
      },
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.authenticated),
      ],
      verify: (_) => expect(repository.refreshTokenCalls, 1),
    );
  });

  group('login', () {
    blocTest<SessionBloc, SessionState>(
      'stores the token, exposes the client and signals the router',
      build: bloc,
      act: (bloc) => bloc.add(
        LoginRequested(email: 'sara@example.com', password: 'secret123'),
      ),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
          notice: SessionNotice.loginSucceeded,
        ),
      ],
      verify: (bloc) {
        expect(storage.token, 'login-token');
        expect(bloc.state.client?.email, 'sara@example.com');
      },
    );

    blocTest<SessionBloc, SessionState>(
      'a rejection surfaces in state and leaves the session unauthenticated',
      build: () {
        repository.loginError = unauthorized();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(
        LoginRequested(email: 'sara@example.com', password: 'wrong'),
      ),
      expect: () => [
        const SessionState(isLoading: true),
        SessionState(isLoading: false, error: unauthorized()),
      ],
      verify: (bloc) {
        expect(bloc.state.isAuthenticated, isFalse);
        expect(storage.token, isNull);
      },
    );
  });

  group('register', () {
    blocTest<SessionBloc, SessionState>(
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
        const SessionState(isLoading: true),
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
          notice: SessionNotice.registrationSucceeded,
        ),
      ],
      verify: (bloc) {
        expect(repository.registeredPayload?['password_confirmation'], 'secret123');
        expect(storage.token, 'register-token');
      },
    );
  });

  group('verification', () {
    blocTest<SessionBloc, SessionState>(
      'verifyEmail forwards the code and signals completion',
      build: bloc,
      act: (bloc) => bloc.add(const VerifyEmailRequested(code: '123456')),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(notice: SessionNotice.verificationSucceeded),
      ],
      verify: (_) => expect(repository.verifiedCode, '123456'),
    );

    blocTest<SessionBloc, SessionState>(
      'verifyEmail surfaces a rejected code in state',
      build: () {
        repository.verifyEmailError = const ValidationException(
          statusCode: 422,
          code: 'VALIDATION_FAILED',
          message: 'core::messages.invalid_verification_code',
          errors: {'code': ['invalid']},
        );
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(const VerifyEmailRequested(code: '000000')),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(
          isLoading: false,
          error: ValidationException(
            statusCode: 422,
            code: 'VALIDATION_FAILED',
            message: 'core::messages.invalid_verification_code',
            errors: {'code': ['invalid']},
          ),
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'sendVerificationCode calls the dispatch route',
      build: bloc,
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => <SessionState>[],
      verify: (_) => expect(repository.sendVerificationCalls, 1),
    );

    blocTest<SessionBloc, SessionState>(
      'a failed dispatch is swallowed without touching state',
      build: () {
        repository.sendVerificationError = offline();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(SendVerificationCodeRequested()),
      expect: () => <SessionState>[],
      verify: (bloc) {
        expect(repository.sendVerificationCalls, 1);
        expect(bloc.state.error, isNull);
      },
    );
  });

  group('logout', () {
    blocTest<SessionBloc, SessionState>(
      'clears the local session',
      build: () {
        storage.token = 'stored-token';
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.guest),
      ],
      verify: (_) {
        expect(storage.token, isNull);
        expect(repository.logoutCalls, 1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'clears the local session even when the API call fails',
      build: () {
        storage.token = 'stored-token';
        repository.logoutError = offline();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        SessionState(status: AuthStatus.guest, error: offline()),
      ],
      verify: (_) {
        expect(storage.token, isNull);
      },
    );
  });

  group('global notices', () {
    blocTest<SessionBloc, SessionState>(
      'UnauthorizedDetected clears the token and broadcasts sessionExpired',
      build: () {
        storage.token = 'stored-token';
        return SessionBloc(repository, storage);
      },
      act: (bloc) async {
        await bloc.ready;
        bloc.add(UnauthorizedDetected());
      },
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.authenticated),
        const SessionState(
          status: AuthStatus.authenticated,
          notice: SessionNotice.sessionExpired,
        ),
        const SessionState(status: AuthStatus.guest, notice: SessionNotice.sessionExpired),
      ],
      verify: (_) {
        expect(storage.token, isNull);
        expect(storage.clearCount, 1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'a burst of 401s collapses into one clear and one notice',
      build: () {
        storage.token = 'stored-token';
        return SessionBloc(repository, storage);
      },
      act: (bloc) async {
        await bloc.ready;
        bloc.add(UnauthorizedDetected());
        bloc.add(UnauthorizedDetected());
        bloc.add(UnauthorizedDetected());
      },
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.authenticated),
        const SessionState(
          status: AuthStatus.authenticated,
          notice: SessionNotice.sessionExpired,
        ),
        const SessionState(status: AuthStatus.guest, notice: SessionNotice.sessionExpired),
      ],
      verify: (_) {
        expect(storage.clearCount, 1);
        expect(storage.token, isNull);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'RequireAuthentication broadcasts the sign-in prompt',
      build: bloc,
      act: (bloc) => bloc.add(RequireAuthentication()),
      expect: () => [
        const SessionState(notice: SessionNotice.authenticationRequired),
      ],
      verify: (bloc) => expect(bloc.state.status, AuthStatus.unknown),
    );

    blocTest<SessionBloc, SessionState>(
      'NoticeAcknowledged clears the current notice',
      build: bloc,
      act: (bloc) async {
        bloc.add(RequireAuthentication());
        bloc.add(NoticeAcknowledged());
      },
      expect: () => [
        const SessionState(notice: SessionNotice.authenticationRequired),
        const SessionState(),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'restore with a revoked token never raises sessionExpired',
      build: () {
        storage.token = 'revoked-token';
        repository.refreshTokenError = unauthorized();
        return SessionBloc(repository, storage);
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.guest),
      ],
      verify: (bloc) {
        expect(bloc.state.notice, SessionNotice.none);
        expect(storage.token, isNull);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'login overrides a pending notice with its success signal',
      build: bloc,
      act: (bloc) async {
        bloc.add(RequireAuthentication());
        bloc.add(
          LoginRequested(email: 'sara@example.com', password: 'secret123'),
        );
      },
      expect: () => [
        const SessionState(notice: SessionNotice.authenticationRequired),
        const SessionState(isLoading: true),
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
          notice: SessionNotice.loginSucceeded,
        ),
      ],
      verify: (bloc) => expect(bloc.state.isAuthenticated, isTrue),
    );
  });
}
