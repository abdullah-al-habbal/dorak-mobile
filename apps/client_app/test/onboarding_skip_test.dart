import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/home/home.screen.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';

import 'helpers/fakes.dart';

void main() {
  late InMemoryAppPreferences preferences;
  late AppRouter router;

  setUp(() {
    preferences = InMemoryAppPreferences();
    final session = SessionController(
      FakeAuthRepository(),
      InMemoryTokenStorage(),
    );
    router = buildRouter(session: session, preferences: preferences);
  });

  Future<void> startTour(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await router.session.ready;
    router.router.go(AppRoutes.onboardingWelcome);
    await tester.pumpWidget(routerHarness(router));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  }

  Future<void> openSkipSheet(WidgetTester tester) async {
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Skip Onboarding?'), findsOneWidget);
  }

  testWidgets('"Skip for now" leaves the flag untouched', (tester) async {
    await startTour(tester);

    await openSkipSheet(tester);
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      preferences.dontShowOnboarding,
      isFalse,
      reason: 'the tour must reappear on the next cold start',
    );
  });

  testWidgets('"Don\'t show again" persists the flag', (tester) async {
    await startTour(tester);

    await openSkipSheet(tester);
    await tester.tap(find.text("Don't show again"));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(preferences.dontShowOnboarding, isTrue);
  });

  testWidgets('"Cancel" stays on the tour and changes nothing', (tester) async {
    await startTour(tester);

    await openSkipSheet(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(preferences.dontShowOnboarding, isFalse);
  });

  testWidgets('completing all four steps persists the flag', (tester) async {
    await startTour(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(preferences.dontShowOnboarding, isTrue);
  });

  testWidgets('Home is the only route left after the tour', (tester) async {
    await startTour(tester);

    await openSkipSheet(tester);
    await tester.tap(find.text("Don't show again"));
    await tester.pumpAndSettle();

    expect(preferences.dontShowOnboarding, isTrue);
    expect(router.router.canPop(), isFalse);
  });
}
