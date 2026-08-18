import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  final VoidCallback onLogIn;

  const PasswordResetSuccessScreen({super.key, required this.onLogIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthEntryBackground()),
          AuthShell(
            child: StatusView(
              icon: Icons.check_circle_outline,
              iconColor: colors.primary,
              title: l10n.passwordResetSuccessTitle,
              message: l10n.passwordResetSuccessMessage,
              actionLabel: l10n.authLogIn,
              onAction: onLogIn,
            ),
          ),
        ],
      ),
    );
  }
}
