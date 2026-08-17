import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/locale/locale.bloc.dart';
import 'package:client_app/src/core/locale/locale.event.dart';
import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/sign_up.screen.dart';
import 'package:client_app/src/features/auth/verify_account.screen.dart';

import 'helpers/fakes.dart';

Widget localeHarness(AppRouter appRouter, LocaleBloc locale) {
  return BlocProvider<LocaleBloc>.value(
    value: locale,
    child: BlocBuilder<LocaleBloc, Locale>(
      builder: (context, l) => MaterialApp.router(
        routerConfig: appRouter.router,
        debugShowCheckedModeBanner: false,
        theme: DorakTheme.forLocale(l, Brightness.light),
        locale: l,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
}

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage();
  });

  ({AppRouter router, LocaleBloc locale}) buildFloor(WidgetTester tester) {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final locale = LocaleBloc();
    final pair = sessionPair(repository, storage);
    final router = buildRouter(
      session: pair.session,
      auth: pair.auth,
      preferences: InMemoryAppPreferences(),
      apiClient: fakeApiClient(),
      switchLocale: () => locale.add(LocaleToggled()),
    );
    return (router: router, locale: locale);
  }

  Future<({AppRouter router, LocaleBloc locale})> pumpAuthEntry(
      WidgetTester tester) async {
    final floor = buildFloor(tester);
    await tester.pumpWidget(localeHarness(floor.router, floor.locale));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    floor.router.router.go(AppRoutes.authEntry);
    await tester.pumpAndSettle();
    return floor;
  }

  Future<void> expectToggle(
    WidgetTester tester, {
    required String firstLabel,
    required String secondLabel,
  }) async {
    expect(find.byType(LocaleSwitcher), findsOneWidget);
    expect(find.text(firstLabel), findsOneWidget);

    await tester.tap(find.text(firstLabel));
    await tester.pumpAndSettle();
    expect(find.text(secondLabel), findsOneWidget);

    await tester.tap(find.text(secondLabel));
    await tester.pumpAndSettle();
    expect(find.text(firstLabel), findsOneWidget);
  }

  testWidgets('auth entry shows a working locale switcher', (tester) async {
    await pumpAuthEntry(tester);
    expect(find.byType(LocaleSwitcher), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(LocaleSwitcher))),
      TextDirection.rtl,
    );
  });

  testWidgets('login toggles Arabic to English and back', (tester) async {
    await pumpAuthEntry(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await expectToggle(
      tester,
      firstLabel: 'العربية',
      secondLabel: 'English',
    );
  });

  testWidgets('sign up toggles Arabic to English and back', (tester) async {
    await pumpAuthEntry(tester);

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);

    await expectToggle(
      tester,
      firstLabel: 'العربية',
      secondLabel: 'English',
    );
  });

  testWidgets('verify toggles Arabic to English and back', (tester) async {
    final floor = await pumpAuthEntry(tester);

    floor.router.router.go(AppRoutes.authVerify, extra: 'sara@example.com');
    await tester.pumpAndSettle();
    expect(find.byType(VerifyAccountScreen), findsOneWidget);

    await expectToggle(
      tester,
      firstLabel: 'العربية',
      secondLabel: 'English',
    );
  });
}