import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/sign_up.screen.dart';
import 'package:client_app/src/features/auth/verify_account.screen.dart';
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

  Future<AppRouter> pumpEntry(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
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

  testWidgets('sign up dispatches a code and opens verification', (tester) async {
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
    expect(repository.sendVerificationCalls, 1);
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
}
