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

    test(
      'unreadable token storage resolves to guest and never hangs ready',
      () async {
        storage.readError = StateError('keystore unavailable');
        final session = bloc();
        addTearDown(session.close);

        await session.ready.timeout(
          const Duration(seconds: 2),
          onTimeout: () => fail(
            'ready never completed: a throwing read() used to leave the '
            'session in AuthStatus.unknown, hanging the splash forever',
          ),
        );

        expect(session.state.status, AuthStatus.guest);
        expect(session.state.error, isA<StateError>());
        expect(repository.refreshTokenCalls, 0);
      },
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

  group('SessionAuthenticated', () {
    blocTest<SessionBloc, SessionState>(
      'marks the session authenticated with the given client',
      build: bloc,
      act: (bloc) => bloc.add(SessionAuthenticated(FakeAuthRepository.defaultClient)),
      expect: () => [
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.isAuthenticated, isTrue);
        expect(bloc.state.client?.email, 'sara@example.com');
      },
    );

    blocTest<SessionBloc, SessionState>(
      'duplicate SessionAuthenticated for the same client is a no-op',
      build: bloc,
      act: (bloc) async {
        bloc.add(SessionAuthenticated(FakeAuthRepository.defaultClient));
        bloc.add(SessionAuthenticated(FakeAuthRepository.defaultClient));
      },
      expect: () => [
        const SessionState(
          status: AuthStatus.authenticated,
          client: FakeAuthRepository.defaultClient,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.client, FakeAuthRepository.defaultClient);
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
      'expiring an authenticated session discards the cached client',
      build: () {
        storage.token = 'stored-token';
        return bloc();
      },
      act: (bloc) async {
        await bloc.ready;
        bloc.add(const SessionAuthenticated(FakeAuthRepository.defaultClient));
        await pumpEventQueue();
        bloc.add(UnauthorizedDetected());
      },
      verify: (bloc) {
        expect(
          bloc.state.client,
          isNull,
          reason: 'copyWith(client: null) used to be a silent no-op, leaving '
              'the expired user cached in state',
        );
        expect(bloc.state.status, AuthStatus.guest);
        expect(bloc.state.signal, SessionSignal.sessionExpired);
      },
    );

    blocTest<SessionBloc, SessionState>(
      'SessionAuthenticated cannot resurrect a session that just expired',
      build: () {
        storage.token = 'stored-token';
        return bloc();
      },
      act: (bloc) async {
        await bloc.ready;
        bloc.add(UnauthorizedDetected());
        await pumpEventQueue();
        bloc.add(const SessionAuthenticated(FakeAuthRepository.defaultClient));
        await pumpEventQueue();
      },
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.guest);
        expect(bloc.state.client, isNull);
      },
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
