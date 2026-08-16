import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';
import 'package:client_app/src/features/home/home.screen.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;
  late SessionController session;
  late UnauthorizedNotifier unauthorizedNotifier;
  late AppRouter router;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage('valid-token');
    session = SessionController(repository, storage);
    unauthorizedNotifier = UnauthorizedNotifier();
    router = buildRouter(
      session: session,
      preferences: InMemoryAppPreferences(),
      unauthorizedNotifier: unauthorizedNotifier,
    );
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await session.ready;
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'a mid-session 401 clears the session and replaces the stack with auth entry',
      (tester) async {
    await pumpHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    unauthorizedNotifier.fire();
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(storage.token, isNull);
    expect(session.status, AuthStatus.guest);
    expect(session.notice, SessionNotice.none);
  });

  testWidgets('a burst of 401s opens auth entry exactly once', (tester) async {
    await pumpHome(tester);

    unauthorizedNotifier.fire();
    unauthorizedNotifier.fire();
    unauthorizedNotifier.fire();
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(storage.token, isNull);
  });

  testWidgets('a guest action raises authenticationRequired and pushes auth entry',
      (tester) async {
    await pumpHome(tester);

    session.requireAuthentication();
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);

    router.router.pop();
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('after expiry the user can sign back in', (tester) async {
    await pumpHome(tester);
    unauthorizedNotifier.fire();
    await tester.pumpAndSettle();
    expect(find.byType(AuthEntryScreen), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(AuthTextField).at(0), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(1), 'secret123');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(storage.token, 'login-token');
    expect(session.isAuthenticated, isTrue);
  });

  testWidgets('a revoked token at restore does not raise sessionExpired',
      (tester) async {
    repository.refreshTokenError = unauthorized();
    router = buildRouter(
      session: session,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
      unauthorizedNotifier: unauthorizedNotifier,
    );

    await pumpHome(tester);

    expect(session.status, AuthStatus.guest);
    expect(session.notice, SessionNotice.none);
    expect(storage.token, isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthEntryScreen), findsNothing);
  });
}
