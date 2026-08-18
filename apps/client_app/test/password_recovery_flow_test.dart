import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/create_new_password.screen.dart';
import 'package:client_app/src/features/auth/forgot_password.screen.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/auth/password_reset_success.screen.dart';
import 'package:client_app/src/features/auth/recovery_otp.screen.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';
import 'package:client_app/src/features/auth/widgets/otp_input_field.widget.dart';

import 'helpers/fakes.dart';

ValidationException emailNotRegistered() => const ValidationException(
      statusCode: 422,
      code: 'VALIDATION_FAILED',
      message: 'core::messages.validation_failed',
      errors: {
        'email': ['The selected email is invalid.'],
      },
    );

ValidationException codeRejected() => const ValidationException(
      statusCode: 422,
      code: 'VALIDATION_FAILED',
      message: 'core::messages.validation_failed',
      errors: {
        'code': ['The code is invalid or has expired.'],
      },
    );

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;
  late PasswordRecoveryBloc recovery;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage();
  });

  Future<AppRouter> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final pair = sessionPair(repository, storage);
    recovery = PasswordRecoveryBloc(repository);
    addTearDown(recovery.close);

    final router = buildRouter(
      session: pair.session,
      auth: pair.auth,
      recovery: recovery,
      preferences: InMemoryAppPreferences(),
      apiClient: fakeApiClient(),
    );
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    router.router.go(AppRoutes.authLogin);
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> requestCode(WidgetTester tester, String email) async {
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    await tester.enterText(find.byType(AuthTextField).first, email);
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();
  }

  Future<void> enterCode(WidgetTester tester, String code) async {
    for (var i = 0; i < code.length; i++) {
      await tester.enterText(find.byType(OtpInputField).at(i), code[i]);
      await tester.pump();
    }
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Future<void> enterNewPassword(WidgetTester tester, String password) async {
    final fields = find.byType(AuthTextField);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), password);
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
  }

  testWidgets('the forgot-password link is reachable from login', (tester) async {
    await pumpLogin(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.text('Forgot Password?'),
      findsOneWidget,
      reason: 'onForgotPassword was null, which hid the link entirely',
    );
  });

  testWidgets('a known email advances to the code step', (tester) async {
    await pumpLogin(tester);
    await requestCode(tester, 'sara@example.com');

    expect(find.byType(RecoveryOtpScreen), findsOneWidget);
    expect(repository.forgotPasswordEmail, 'sara@example.com');
    expect(find.textContaining('s***@example.com'), findsOneWidget);
  });

  testWidgets('an unregistered email also advances, leaking nothing',
      (tester) async {
    repository.forgotPasswordError = emailNotRegistered();
    await pumpLogin(tester);
    await requestCode(tester, 'nobody@example.com');

    expect(
      find.byType(RecoveryOtpScreen),
      findsOneWidget,
      reason: 'surfacing the 422 would turn exists:clients,email into an '
          'account-enumeration oracle in the UI',
    );
  });

  testWidgets('a correct code and new password reach the success screen',
      (tester) async {
    await pumpLogin(tester);
    await requestCode(tester, 'sara@example.com');
    await enterCode(tester, '123456');

    expect(find.byType(CreateNewPasswordScreen), findsOneWidget);

    await enterNewPassword(tester, 'newsecret123');

    expect(find.byType(PasswordResetSuccessScreen), findsOneWidget);
    expect(repository.resetPasswordPayload, {
      'email': 'sara@example.com',
      'code': '123456',
      'password': 'newsecret123',
      'password_confirmation': 'newsecret123',
    });
  });

  testWidgets('the success screen lands on login and drops the recovery stack',
      (tester) async {
    final router = await pumpLogin(tester);
    await requestCode(tester, 'sara@example.com');
    await enterCode(tester, '123456');
    await enterNewPassword(tester, 'newsecret123');

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.authLogin,
    );
    expect(find.byType(PasswordResetSuccessScreen), findsNothing);
  });

  testWidgets('a rejected code surfaces on the password step with a way back',
      (tester) async {
    repository.resetPasswordError = codeRejected();
    await pumpLogin(tester);
    await requestCode(tester, 'sara@example.com');
    await enterCode(tester, '000000');
    await enterNewPassword(tester, 'newsecret123');

    expect(
      find.byType(CreateNewPasswordScreen),
      findsOneWidget,
      reason: 'the backend has no verify-reset-code endpoint, so a bad code can '
          'only be discovered when reset-password is submitted',
    );
    expect(find.text('That code is invalid or has expired.'), findsOneWidget);

    await tester.tap(find.text('Re-enter code'));
    await tester.pumpAndSettle();

    expect(find.byType(RecoveryOtpScreen), findsOneWidget);
  });
}
