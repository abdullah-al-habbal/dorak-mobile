import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:client_app/src/features/home/home.screen.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
  });

  Future<void> runGate(
    WidgetTester tester, {
    required SessionController session,
    required AppPreferences preferences,
  }) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await session.ready;
    await tester.pumpWidget(
      routerHarness(buildRouter(session: session, preferences: preferences)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('returning logged-in user goes straight Home', (tester) async {
    final session = SessionController(
      repository,
      InMemoryTokenStorage('stored-token'),
    );

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthEntryScreen), findsNothing);
  });

  testWidgets('new device lands on the auth entry screen', (tester) async {
    final session = SessionController(repository, InMemoryTokenStorage());

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(),
    );

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('returning guest who already saw the tour goes Home', (tester) async {
    final session = SessionController(repository, InMemoryTokenStorage());

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthEntryScreen), findsNothing);
  });

  testWidgets('a revoked token falls through to the onboarding check', (tester) async {
    repository.refreshTokenError = unauthorized();
    final storage = InMemoryTokenStorage('revoked-token');
    final session = SessionController(repository, storage);

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(),
    );

    expect(storage.token, isNull, reason: 'dead token must be discarded');
    expect(find.byType(AuthEntryScreen), findsOneWidget);
  });

  testWidgets('a revoked token on a dismissed-tour device goes Home', (tester) async {
    repository.refreshTokenError = unauthorized();
    final session = SessionController(
      repository,
      InMemoryTokenStorage('revoked-token'),
    );

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('offline start keeps the session and goes Home', (tester) async {
    repository.refreshTokenError = offline();
    final storage = InMemoryTokenStorage('stored-token');
    final session = SessionController(repository, storage);

    await runGate(
      tester,
      session: session,
      preferences: InMemoryAppPreferences(),
    );

    expect(storage.token, 'stored-token');
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
