import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/change_password.bloc.dart';
import 'package:client_app/src/features/auth/change_password.event.dart';
import 'package:client_app/src/features/auth/change_password.state.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';
import 'package:client_app/src/features/auth/widgets/change_password_content.widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordBloc passwordChange;
  final VoidCallback? onLocaleToggle;

  const ChangePasswordScreen({
    super.key,
    required this.passwordChange,
    this.onLocaleToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthEntryBackground()),
          AuthShell(
            pinnedHeader: true,
            header: AuthHeader(
              brandLabel: l10n.splashTitle,
              backTooltip: l10n.back,
              onBack: () => context.pop(),
              localeLabel: isArabic ? l10n.localeEnglish : l10n.localeArabic,
              onLocaleToggle: onLocaleToggle,
            ),
            child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
              bloc: passwordChange,
              builder: (context, state) {
                if (state.succeeded) {
                  return StatusView(
                    icon: Icons.check_circle_outline,
                    title: l10n.changePasswordSuccessTitle,
                    message: l10n.changePasswordSuccessMessage,
                    actionLabel: l10n.changePasswordDone,
                    onAction: () => context.pop(),
                    iconColor: colors.primary,
                  );
                }
                final error = state.error == null
                    ? null
                    : AuthError.from(state.error!, l10n);
                return ChangePasswordContent(
                  onSubmit: ({
                    required String currentPassword,
                    required String password,
                    required String passwordConfirmation,
                  }) =>
                      passwordChange.add(ChangePasswordSubmitted(
                    currentPassword: currentPassword,
                    password: password,
                    passwordConfirmation: passwordConfirmation,
                  )),
                  error: error,
                  isSubmitting: state.isSubmitting,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
