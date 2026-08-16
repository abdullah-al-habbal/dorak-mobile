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

  SessionController controller() => SessionController(repository, storage);

  group('restore', () {
    test('no stored token resolves to guest without hitting the network', () async {
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.guest);
      expect(session.isAuthenticated, isFalse);
      expect(repository.refreshTokenCalls, 0);
    });

    test('a valid token authenticates and persists the rotated token', () async {
      storage.token = 'stored-token';
      repository.refreshedToken = 'fresh-token';
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.authenticated);
      expect(storage.token, 'fresh-token');
      expect(repository.refreshTokenCalls, 1);
    });

    test('401 clears the token and falls back to guest', () async {
      storage.token = 'revoked-token';
      repository.refreshTokenError = unauthorized();
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.guest);
      expect(storage.token, isNull);
      expect(storage.clearCount, 1);
    });

    test('offline start keeps the session instead of logging out', () async {
      // Sanctum tokens have no server-side expiry, so a transport failure is no
      // evidence the session died.
      storage.token = 'stored-token';
      repository.refreshTokenError = offline();
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.authenticated);
      expect(storage.token, 'stored-token');
      expect(storage.clearCount, 0);
      expect(session.error, isA<NetworkException>());
    });

    test('a server error keeps the session', () async {
      storage.token = 'stored-token';
      repository.refreshTokenError = const ApiException(
        statusCode: 500,
        code: 'SERVER_ERROR',
        message: 'boom',
      );
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.authenticated);
      expect(storage.token, 'stored-token');
    });

    test('ready joins the in-flight restore instead of starting another', () async {
      storage.token = 'stored-token';
      final session = controller();

      await Future.wait([session.ready, session.ready, session.ready]);

      expect(repository.refreshTokenCalls, 1);
    });
  });

  group('login', () {
    test('stores the token and exposes the client', () async {
      final session = controller();

      await session.login(email: 'sara@example.com', password: 'secret123');

      expect(session.status, AuthStatus.authenticated);
      expect(storage.token, 'login-token');
      expect(session.client?.email, 'sara@example.com');
      expect(session.isLoading, isFalse);
    });

    test('rethrows and leaves the session unauthenticated', () async {
      repository.loginError = unauthorized();
      final session = controller();

      await expectLater(
        session.login(email: 'sara@example.com', password: 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(session.isAuthenticated, isFalse);
      expect(session.error, isA<ApiException>());
      expect(storage.token, isNull);
      expect(session.isLoading, isFalse);
    });
  });

  group('register', () {
    test('forwards the confirmation and stores the returned token', () async {
      final session = controller();

      await session.register(
        name: 'Sara',
        email: 'sara@example.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
      );

      expect(repository.registeredPayload?['password_confirmation'], 'secret123');
      expect(session.status, AuthStatus.authenticated);
      expect(storage.token, 'register-token');
    });
  });

  group('verification', () {
    test('verifyEmail forwards the code', () async {
      final session = controller();

      await session.verifyEmail('123456');

      expect(repository.verifiedCode, '123456');
    });

    test('verifyEmail rethrows a rejected code', () async {
      repository.verifyEmailError = const ValidationException(
        statusCode: 422,
        code: 'VALIDATION_FAILED',
        message: 'core::messages.invalid_verification_code',
        errors: {'code': ['invalid']},
      );
      final session = controller();

      await expectLater(
        session.verifyEmail('000000'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('sendVerificationCode calls the dispatch route', () async {
      final session = controller();

      await session.sendVerificationCode();

      expect(repository.sendVerificationCalls, 1);
    });
  });

  group('logout', () {
    test('clears the local session', () async {
      storage.token = 'stored-token';
      final session = controller();

      await session.logout();

      expect(session.status, AuthStatus.guest);
      expect(storage.token, isNull);
      expect(repository.logoutCalls, 1);
    });

    test('clears the local session even when the API call fails', () async {
      storage.token = 'stored-token';
      repository.logoutError = offline();
      final session = controller();

      await session.logout();

      expect(session.status, AuthStatus.guest);
      expect(storage.token, isNull);
      expect(session.error, isA<NetworkException>());
    });
  });

  group('global notices', () {
    test('handleUnauthorized clears the token and broadcasts sessionExpired',
        () async {
      storage.token = 'stored-token';
      final session = controller();
      await session.restore();

      await session.handleUnauthorized();

      expect(session.status, AuthStatus.guest);
      expect(storage.token, isNull);
      expect(storage.clearCount, 1);
      expect(session.notice, SessionNotice.sessionExpired);
    });

    test('a burst of concurrent 401s collapses into one clear and one notice',
        () async {
      storage.token = 'stored-token';
      final session = controller();
      await session.restore();
      var notifications = 0;
      session.addListener(() => notifications++);

      await Future.wait([
        session.handleUnauthorized(),
        session.handleUnauthorized(),
        session.handleUnauthorized(),
      ]);

      expect(storage.clearCount, 1);
      expect(session.status, AuthStatus.guest);
      expect(session.notice, SessionNotice.sessionExpired);
      expect(notifications, 1);
    });

    test('requireAuthentication broadcasts the sign-in prompt', () async {
      final session = controller();

      session.requireAuthentication();

      expect(session.notice, SessionNotice.authenticationRequired);
      expect(session.status, AuthStatus.unknown);
    });

    test('acknowledgeNotice clears the current notice', () async {
      final session = controller();
      session.requireAuthentication();

      session.acknowledgeNotice();

      expect(session.notice, SessionNotice.none);
    });

    test('restore with a revoked token never raises sessionExpired', () async {
      storage.token = 'revoked-token';
      repository.refreshTokenError = unauthorized();
      final session = controller();

      await session.restore();

      expect(session.status, AuthStatus.guest);
      expect(session.notice, SessionNotice.none);
    });

    test('login resets a pending notice', () async {
      final session = controller();
      session.requireAuthentication();

      await session.login(email: 'sara@example.com', password: 'secret123');

      expect(session.notice, SessionNotice.none);
      expect(session.isAuthenticated, isTrue);
    });
  });
}
