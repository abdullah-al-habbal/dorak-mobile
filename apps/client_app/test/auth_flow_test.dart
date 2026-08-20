import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/sign_up.screen.dart';
import 'package:client_app/src/features/auth/verify_account.screen.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';
import 'package:client_app/src/features/auth/widgets/login_content.widget.dart';
import 'package:client_app/src/features/auth/widgets/sign_up_content.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';
import 'package:client_app/src/features/auth/widgets/otp_input_field.widget.dart';
import 'package:client_app/src/features/home/home.screen.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;
  late SessionBloc session;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage();
  });

  Future<AppRouter> pumpEntry(
    WidgetTester tester, {
    Size logicalSize = const Size(430, 932),
  }) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = logicalSize * 3.0;
    addTearDown(tester.view.reset);

    final pair = sessionPair(repository, storage);
    session = pair.session;
    final router = buildRouter(
      session: session,
      auth: pair.auth,
      preferences: InMemoryAppPreferences(),
      apiClient: fakeApiClient(),
    );
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    router.router.go(AppRoutes.authEntry);
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> openVerify(WidgetTester tester, AppRouter router) async {
    router.router.go(AppRoutes.authVerify, extra: 'sara@example.com');
    await tester.pumpAndSettle();
  }

  Future<void> enterCode(WidgetTester tester, String code) async {
    for (var i = 0; i < code.length; i++) {
      await tester.enterText(find.byType(OtpInputField).at(i), code[i]);
      await tester.pump();
    }
  }

  testWidgets('log in reaches Home and stores the token', (tester) async {
    await pumpEntry(tester);

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

  testWidgets('rejected credentials keep the user on the login screen', (tester) async {
    repository.loginError = unauthorized();
    await pumpEntry(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(AuthTextField).at(0), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(1), 'wrongpass');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(storage.token, isNull);
  });

  testWidgets('client-side validation blocks an empty submit', (tester) async {
    await pumpEntry(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('This field is required'), findsWidgets);
  });

  testWidgets('sign up opens verification without a client-side dispatch', (tester) async {
    await pumpEntry(tester);

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);

    await tester.enterText(find.byType(AuthTextField).at(0), 'Sara');
    await tester.enterText(find.byType(AuthTextField).at(1), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(2), 'secret123');
    await tester.enterText(find.byType(AuthTextField).at(3), 'secret123');
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyAccountScreen), findsOneWidget);
    expect(repository.sendVerificationCalls, 0);
    expect(storage.token, 'register-token');
    expect(find.textContaining('s***@example.com'), findsOneWidget);
  });

  testWidgets('mismatched confirmation is caught before the request', (tester) async {
    await pumpEntry(tester);

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(AuthTextField).at(0), 'Sara');
    await tester.enterText(find.byType(AuthTextField).at(1), 'sara@example.com');
    await tester.enterText(find.byType(AuthTextField).at(2), 'secret123');
    await tester.enterText(find.byType(AuthTextField).at(3), 'different');
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(storage.token, isNull);
  });

  testWidgets('a correct code verifies and lands on Home', (tester) async {
    final router = await pumpEntry(tester);
    await openVerify(tester, router);

    await enterCode(tester, '123456');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    expect(repository.verifiedCode, '123456');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('a rejected code keeps the user on the verify screen', (tester) async {
    repository.verifyEmailError = const ValidationException(
      statusCode: 422,
      code: 'VALIDATION_FAILED',
      message: 'core::messages.invalid_verification_code',
      errors: {'code': ['invalid']},
    );
    final router = await pumpEntry(tester);
    await openVerify(tester, router);

    await enterCode(tester, '000000');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyAccountScreen), findsOneWidget);
    expect(find.text('Invalid code. Please try again.'), findsOneWidget);
  });

  testWidgets('verification is skippable — the account is already authenticated',
      (tester) async {
    final router = await pumpEntry(tester);
    await openVerify(tester, router);

    await tester.tap(find.text('Verify later'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('resend is blocked until the cooldown elapses', (tester) async {
    final router = await pumpEntry(tester);
    await openVerify(tester, router);

    expect(find.text('Resend Code (60s)'), findsOneWidget);

    await tester.tap(find.text('Resend Code (60s)'));
    await tester.pumpAndSettle();
    expect(repository.sendVerificationCalls, 0);

    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('Resend Code'), findsOneWidget);

    await tester.tap(find.text('Resend Code'));
    await tester.pumpAndSettle();
    expect(repository.sendVerificationCalls, 1);
  });

  group('AuthShell responsive layout', () {
    const compactPhone = Size(375, 667);
    const standardPhone = Size(430, 932);
    const wideTablet = Size(900, 1200);

    ScrollableState shellScrollable(WidgetTester tester) {
      return tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(AuthShell),
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }

    Rect viewportRect(WidgetTester tester) => tester.getRect(
          find
              .descendant(
                of: find.byType(AuthShell),
                matching: find.byType(Scrollable),
              )
              .first,
        );

    Future<void> openLogin(WidgetTester tester, AppRouter router) async {
      router.router.go(AppRoutes.authLogin);
      await tester.pumpAndSettle();
    }

    Future<void> openSignUp(WidgetTester tester, AppRouter router) async {
      router.router.go(AppRoutes.authRegister);
      await tester.pumpAndSettle();
    }

    testWidgets('centres the form when the viewport has room to spare',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: wideTablet);
      await openLogin(tester, router);

      final scroll = shellScrollable(tester);
      expect(
        scroll.position.maxScrollExtent,
        0,
        reason: 'the login form fits in a 1200pt viewport, so nothing should scroll',
      );

      final viewport = viewportRect(tester);
      final content = tester.getRect(find.byType(LoginContent));
      final gapAbove = content.top - viewport.top;
      final gapBelow = viewport.bottom - content.bottom;

      expect(gapAbove, greaterThan(AuthShell.verticalMargin));
      expect(
        (gapAbove - gapBelow).abs(),
        lessThan(2),
        reason: 'equal space above and below is what "centred" means; this must '
            'hold from the constraints alone, with no viewport-height breakpoint',
      );
    });

    testWidgets('centres on a standard phone too — no device-height threshold',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: standardPhone);
      await openLogin(tester, router);

      final viewport = viewportRect(tester);
      final content = tester.getRect(find.byType(LoginContent));
      expect(
        (content.top - viewport.top - (viewport.bottom - content.bottom)).abs(),
        lessThan(2),
      );
      expect(shellScrollable(tester).position.maxScrollExtent, 0);
    });

    testWidgets('a short viewport still centres content that fits in it',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: compactPhone);
      await openLogin(tester, router);

      final scroll = shellScrollable(tester);
      expect(
        scroll.position.maxScrollExtent,
        0,
        reason: 'the login form fits inside 667pt, so it must not scroll',
      );

      final viewport = viewportRect(tester);
      final content = tester.getRect(find.byType(LoginContent));
      final gapAbove = content.top - viewport.top;
      final gapBelow = viewport.bottom - content.bottom;

      expect(
        gapAbove,
        greaterThan(AuthShell.verticalMargin),
        reason: 'a 667pt device used to top-align purely because it fell under a '
            '840pt breakpoint — centring must follow the content, not the device',
      );
      expect((gapAbove - gapBelow).abs(), lessThan(2));
    });

    testWidgets('keeps compact content reachable from the top and scrollable',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: compactPhone);
      await openSignUp(tester, router);

      final scroll = shellScrollable(tester);
      final viewport = viewportRect(tester);
      final content = tester.getRect(find.byType(SignUpContent));

      if (scroll.position.maxScrollExtent > 0) {
        expect(
          content.top - viewport.top,
          closeTo(AuthShell.verticalMargin, 1),
          reason: 'content taller than the viewport must start at the top so the '
              'first field is reachable, not centred off-screen',
        );
      } else {
        expect(
          content.top - viewport.top,
          greaterThanOrEqualTo(AuthShell.verticalMargin),
        );
      }

      expect(tester.takeException(), isNull, reason: 'no overflow');
    });

    testWidgets('a shrunken viewport scrolls instead of clipping, CTA reachable',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: compactPhone);
      await openSignUp(tester, router);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320 * 3.0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'no clipping or overflow');

      final scroll = shellScrollable(tester);
      expect(
        scroll.position.maxScrollExtent,
        greaterThan(0),
        reason: 'the form cannot fit beside a keyboard, so it must scroll',
      );

      await tester.ensureVisible(find.text('Create Account').last);
      await tester.pumpAndSettle();

      final cta = tester.getRect(find.text('Create Account').last);
      final viewport = viewportRect(tester);
      expect(cta.bottom, lessThanOrEqualTo(viewport.bottom + 1));
      expect(cta.top, greaterThanOrEqualTo(viewport.top - 1));
    });

    testWidgets('the transactional header survives a shrunken viewport',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: compactPhone);
      await openLogin(tester, router);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320 * 3.0);
      await tester.pumpAndSettle();

      expect(find.byType(AuthHeader), findsOneWidget);

      final header = tester.getRect(find.byType(AuthHeader));
      final shell = tester.getRect(find.byType(AuthShell));
      expect(
        header.bottom,
        lessThanOrEqualTo(shell.bottom),
        reason: 'pinnedHeader keeps AuthHeader out of the scrollable, so the '
            'keyboard must not be able to push it out of view',
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('narrow viewports stay fluid; wide ones honour the max width',
        (tester) async {
      final narrowRouter = await pumpEntry(tester, logicalSize: compactPhone);
      await openLogin(tester, narrowRouter);

      expect(
        tester.getSize(find.byType(LoginContent)).width,
        closeTo(compactPhone.width - AuthShell.horizontalMargin * 2, 1),
        reason: 'below the cap the form fills the width minus its margins',
      );
    });

    testWidgets('a wide viewport caps the form at maxContentWidth',
        (tester) async {
      final router = await pumpEntry(tester, logicalSize: wideTablet);
      await openLogin(tester, router);

      expect(
        tester.getSize(find.byType(LoginContent)).width,
        closeTo(AuthShell.maxContentWidth, 1),
        reason: '900pt wide must not stretch the form across the whole screen',
      );
    });
  });
}
