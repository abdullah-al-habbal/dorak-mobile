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

  SessionBloc bloc() =>
      SessionBloc(repository, storage, AuthBloc(repository, storage));

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
        return bloc();
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
        return bloc();
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
        return bloc();
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
        return bloc();
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
        return bloc();
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

  group('auth mirror', () {
    late AuthBloc auth;

    blocTest<SessionBloc, SessionState>(
      'an auth success is mirrored as an authenticated session',
      build: () {
        auth = AuthBloc(repository, storage);
        return SessionBloc(repository, storage, auth);
      },
      act: (bloc) => auth.add(
        LoginRequested(email: 'sara@example.com', password: 'secret123'),
      ),
      expect: () => [
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.isAuthenticated, isTrue);
        expect(bloc.state.client?.email, 'sara@example.com');
        expect(storage.token, 'login-token');
      },
    );

    blocTest<SessionBloc, SessionState>(
      'a rejected login leaves the session untouched',
      build: () {
        repository.loginError = unauthorized();
        auth = AuthBloc(repository, storage);
        return SessionBloc(repository, storage, auth);
      },
      act: (bloc) => auth.add(
        LoginRequested(email: 'sara@example.com', password: 'wrong'),
      ),
      expect: () => <SessionState>[],
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.unknown);
        expect(storage.token, isNull);
      },
    );
  });

  group('logout', () {
    blocTest<SessionBloc, SessionState>(
      'clears the local session',
      build: () {
        storage.token = 'stored-token';
        return bloc();
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
        return bloc();
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

  group('global signals', () {
    blocTest<SessionBloc, SessionState>(
      'UnauthorizedDetected clears the token and broadcasts sessionExpired',
      build: () {
        storage.token = 'stored-token';
        return bloc();
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
          signal: SessionSignal.sessionExpired,
        ),
        const SessionState(
          status: AuthStatus.guest,
          signal: SessionSignal.sessionExpired,
        ),
      ],
      verify: (_) {
        expect(storage.token, isNull);
        expect(storage.clearCount, 1);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'a burst of 401s collapses into one clear and one signal',
      build: () {
        storage.token = 'stored-token';
        return bloc();
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
          signal: SessionSignal.sessionExpired,
        ),
        const SessionState(
          status: AuthStatus.guest,
          signal: SessionSignal.sessionExpired,
        ),
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
        const SessionState(signal: SessionSignal.authenticationRequired),
      ],
      verify: (bloc) => expect(bloc.state.status, AuthStatus.unknown),
    );

    blocTest<SessionBloc, SessionState>(
      'SignalAcknowledged clears the current signal',
      build: bloc,
      act: (bloc) async {
        bloc.add(RequireAuthentication());
        bloc.add(SignalAcknowledged());
      },
      expect: () => [
        const SessionState(signal: SessionSignal.authenticationRequired),
        const SessionState(),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'restore with a revoked token never raises sessionExpired',
      build: () {
        storage.token = 'revoked-token';
        repository.refreshTokenError = unauthorized();
        return bloc();
      },
      act: (bloc) => bloc.add(RestoreRequested()),
      expect: () => [
        const SessionState(isLoading: true),
        const SessionState(status: AuthStatus.guest),
      ],
      verify: (bloc) {
        expect(bloc.state.signal, SessionSignal.none);
        expect(storage.token, isNull);
      },
    );
  });
}
