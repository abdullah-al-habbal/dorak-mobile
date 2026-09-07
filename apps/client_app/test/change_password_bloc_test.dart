import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/auth/change_password.bloc.dart';
import 'package:client_app/src/features/auth/change_password.event.dart';
import 'package:client_app/src/features/auth/change_password.state.dart';

import 'helpers/fakes.dart';

ValidationException wrongCurrentPassword() => const ValidationException(
      statusCode: 422,
      code: 'VALIDATION_FAILED',
      message: 'core::messages.validation_failed',
      errors: {
        'current_password': ['The current password is incorrect.'],
      },
    );

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  ChangePasswordBloc bloc() => ChangePasswordBloc(repository);

  group('ChangePasswordSubmitted', () {
    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'successful change marks succeeded and sends the confirmed payload',
      build: bloc,
      act: (bloc) => bloc.add(
        const ChangePasswordSubmitted(
          currentPassword: 'old-secret',
          password: 'new-secret123',
          passwordConfirmation: 'new-secret123',
        ),
      ),
      expect: () => const [
        ChangePasswordState(isSubmitting: true),
        ChangePasswordState(succeeded: true),
      ],
      verify: (_) {
        expect(repository.changePasswordCalls, 1);
        expect(repository.changePasswordPayload, {
          'current_password': 'old-secret',
          'password': 'new-secret123',
          'password_confirmation': 'new-secret123',
        });
      },
    );

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'wrong current password surfaces the error without succeeding',
      build: bloc,
      setUp: () => repository.changePasswordError = wrongCurrentPassword(),
      act: (bloc) => bloc.add(
        const ChangePasswordSubmitted(
          currentPassword: 'wrong',
          password: 'new-secret123',
          passwordConfirmation: 'new-secret123',
        ),
      ),
      expect: () => [
        const ChangePasswordState(isSubmitting: true),
        predicate<ChangePasswordState>(
          (state) =>
              !state.isSubmitting &&
              !state.succeeded &&
              state.error is ValidationException,
        ),
      ],
    );

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'transport failure surfaces the error without succeeding',
      build: bloc,
      setUp: () => repository.changePasswordError = offline(),
      act: (bloc) => bloc.add(
        const ChangePasswordSubmitted(
          currentPassword: 'old-secret',
          password: 'new-secret123',
          passwordConfirmation: 'new-secret123',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.succeeded, isFalse);
        expect(bloc.state.error, isA<NetworkException>());
      },
    );
  });
}
