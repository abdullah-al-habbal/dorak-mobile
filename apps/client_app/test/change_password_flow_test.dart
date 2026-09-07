import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/change_password.bloc.dart';
import 'package:client_app/src/features/auth/change_password.screen.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStorage storage;
  late ChangePasswordBloc passwordChange;

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemoryTokenStorage('stored-token');
  });

  Future<AppRouter> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final pair = sessionPair(repository, storage);
    passwordChange = ChangePasswordBloc(repository);
    addTearDown(passwordChange.close);

    final router = buildRouter(
      session: pair.session,
      auth: pair.auth,
      passwordChange: passwordChange,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
      apiClient: fakeApiClient(),
    );
    addTearDown(pair.coordinator.cancel);
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> openForm(WidgetTester tester, AppRouter router) async {
    router.router.go(AppRoutes.profile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  }

  Future<void> fillForm(
    WidgetTester tester, {
    required String current,
    required String next,
    required String confirm,
  }) async {
    final fields = find.byType(AuthTextField);
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), current);
    await tester.enterText(fields.at(1), next);
    await tester.enterText(fields.at(2), confirm);
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
  }

  testWidgets('profile entry opens the form and a valid change succeeds',
      (tester) async {
    final router = await pumpProfile(tester);
    await openForm(tester, router);

    await fillForm(
      tester,
      current: 'old-secret',
      next: 'new-secret123',
      confirm: 'new-secret123',
    );

    expect(repository.changePasswordCalls, 1);
    expect(find.text('Password Updated'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('mismatched confirmation blocks the submit', (tester) async {
    final router = await pumpProfile(tester);
    await openForm(tester, router);

    await fillForm(
      tester,
      current: 'old-secret',
      next: 'new-secret123',
      confirm: 'different',
    );

    expect(repository.changePasswordCalls, 0);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('wrong current password shows the server field error',
      (tester) async {
    repository.changePasswordError = const ValidationException(
      statusCode: 422,
      code: 'VALIDATION_FAILED',
      message: 'core::messages.validation_failed',
      errors: {
        'current_password': ['The current password is incorrect.'],
      },
    );
    final router = await pumpProfile(tester);
    await openForm(tester, router);

    await fillForm(
      tester,
      current: 'wrong',
      next: 'new-secret123',
      confirm: 'new-secret123',
    );

    expect(find.text('The current password is incorrect.'), findsOneWidget);
    expect(find.text('Password Updated'), findsNothing);
  });
}
