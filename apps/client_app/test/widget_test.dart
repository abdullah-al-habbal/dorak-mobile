import 'dart:async';

import 'package:client_app/app.dart';
import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:client_app/src/features/home/home.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://test/api\nAPI_BASE_URL_V1=http://test/api/v1',
    );
  });

  testWidgets('bootstrap runs splash, then the launch gate', (tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DorakApp(
        preferences: InMemoryAppPreferences(),
        tokenStorage: InMemoryTokenStorage(),
        authRepository: FakeAuthRepository(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Dorak'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
  });

  group('application lifecycle', () {
    // Track 10 — the app re-probes the stored token on resume, because a
    // session can be revoked while the app sits in the background.
    // `docs/runtime/app_lifecycle.md`.

    /// Drives a full background round-trip. The framework only accepts legal
    /// transitions, and `AppLifecycleListener.onResume` fires on the
    /// inactive -> resumed edge, so the whole chain has to be walked.
    Future<void> backgroundThenResume(WidgetTester tester) async {
      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<FakeAuthRepository> pumpAuthenticatedApp(
      WidgetTester tester, {
      FakeAuthRepository? repository,
    }) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final repo = repository ?? FakeAuthRepository();
      await tester.pumpWidget(
        DorakApp(
          preferences: InMemoryAppPreferences(dontShowOnboarding: true),
          tokenStorage: InMemoryTokenStorage('stored-token'),
          authRepository: repo,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('resuming from the background re-probes the session',
        (tester) async {
      final repository = await pumpAuthenticatedApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        repository.refreshTokenCalls,
        1,
        reason: 'the startup restore probes once',
      );

      await backgroundThenResume(tester);

      expect(
        repository.refreshTokenCalls,
        2,
        reason: 'resume must dispatch RestoreRequested',
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('each resume re-probes exactly once', (tester) async {
      final repository = await pumpAuthenticatedApp(tester);
      expect(repository.refreshTokenCalls, 1);

      await backgroundThenResume(tester);
      expect(repository.refreshTokenCalls, 2);

      await backgroundThenResume(tester);
      expect(repository.refreshTokenCalls, 3);

      await backgroundThenResume(tester);
      expect(
        repository.refreshTokenCalls,
        4,
        reason: 'one probe per resume — a duplicate observer would double this',
      );
    });

    testWidgets('ordinary rebuilds do not re-probe', (tester) async {
      final repository = await pumpAuthenticatedApp(tester);
      expect(repository.refreshTokenCalls, 1);

      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();

      expect(
        repository.refreshTokenCalls,
        1,
        reason: 'the listener is built in initState, never in build',
      );
    });

    testWidgets('a resume while the startup restore is unresolved is ignored',
        (tester) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final gate = Completer<void>();
      final repository = FakeAuthRepository()..refreshTokenGate = gate;

      await tester.pumpWidget(
        DorakApp(
          preferences: InMemoryAppPreferences(dontShowOnboarding: true),
          tokenStorage: InMemoryTokenStorage('stored-token'),
          authRepository: repository,
        ),
      );
      await tester.pump();

      // The startup restore is in flight, so the session is still `unknown`.
      expect(repository.refreshTokenCalls, 1);

      await backgroundThenResume(tester);

      expect(
        repository.refreshTokenCalls,
        1,
        reason: 'the startup restore owns the unknown status; a resume probe '
            'here would resolve the session twice behind session.ready',
      );

      gate.complete();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(repository.refreshTokenCalls, 1);
    });

    testWidgets('a resume after the token was revoked resolves to guest',
        (tester) async {
      final repository = await pumpAuthenticatedApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      // The token dies while the app is backgrounded.
      repository.refreshTokenError = unauthorized();
      await backgroundThenResume(tester);

      expect(repository.refreshTokenCalls, 2);
      // Matches the cold-start contract asserted by session_expired_test.dart:
      // a revoked token at restore resolves to guest without raising
      // sessionExpired, so the route is not replaced here either.
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
