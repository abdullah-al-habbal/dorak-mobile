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
  late SessionBloc session;
  late ApiClient apiClient;
  late AppRouter router;

  setUp(() {
    repository = FakeAuthRepository();
  });

  void createSession({String? token, bool dontShowOnboarding = false}) {
    storage = InMemoryTokenStorage(token);
    final pair = sessionPair(repository, storage);
    session = pair.session;
    apiClient = fakeApiClient();
    router = buildRouter(
      session: session,
      auth: pair.auth,
      preferences: InMemoryAppPreferences(dontShowOnboarding: dontShowOnboarding),
      apiClient: apiClient,
    );
  }

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'a mid-session 401 clears the session and replaces the stack with auth entry',
      (tester) async {
    createSession(token: 'valid-token');
    await pumpHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    session.add(UnauthorizedDetected());
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(storage.token, isNull);
    expect(session.state.status, AuthStatus.guest);
    expect(session.state.signal, SessionSignal.none);
  });

  testWidgets('a burst of 401s opens auth entry exactly once', (tester) async {
    createSession(token: 'valid-token');
    await pumpHome(tester);

    session.add(UnauthorizedDetected());
    session.add(UnauthorizedDetected());
    session.add(UnauthorizedDetected());
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(storage.token, isNull);
  });

  testWidgets('a guest action raises authenticationRequired and pushes auth entry',
      (tester) async {
    createSession(token: 'valid-token');
    await pumpHome(tester);

    session.add(RequireAuthentication());
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);

    router.router.pop();
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('after expiry the user can sign back in', (tester) async {
    createSession(token: 'valid-token');
    await pumpHome(tester);
    session.add(UnauthorizedDetected());
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
    expect(session.state.isAuthenticated, isTrue);
  });

  testWidgets(
      'a failed sign-in after expiry leaves the session guest, not authenticated',
      (tester) async {
    createSession();
    await pumpHome(tester);
    expect(find.byType(AuthEntryScreen), findsOneWidget);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(AuthTextField).at(0), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(1), 'secret123');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    session.add(UnauthorizedDetected());
    await tester.pumpAndSettle();
    expect(find.byType(AuthEntryScreen), findsOneWidget);

    repository.loginError = unauthorized();

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(AuthTextField).at(0), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(1), 'wrongpass');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(
      session.state.status,
      AuthStatus.guest,
      reason: 'the coordinator used to fire on any state carrying a stale '
          'client, re-authenticating the session before the request resolved',
    );
    expect(session.state.client, isNull);
    expect(storage.token, isNull);
  });

  testWidgets('a revoked token at restore does not raise sessionExpired',
      (tester) async {
    repository.refreshTokenError = unauthorized();
    createSession(token: 'valid-token', dontShowOnboarding: true);

    await pumpHome(tester);

    expect(session.state.status, AuthStatus.guest);
    expect(session.state.signal, SessionSignal.none);
    expect(storage.token, isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AuthEntryScreen), findsNothing);
  });
}
