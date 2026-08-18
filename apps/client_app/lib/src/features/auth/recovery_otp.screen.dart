import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/auth/password_recovery.event.dart';
import 'package:client_app/src/features/auth/password_recovery.state.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';
import 'package:client_app/src/features/auth/widgets/recovery_otp_content.widget.dart';

class RecoveryOtpScreen extends StatelessWidget {
  final PasswordRecoveryBloc recovery;
  final VoidCallback? onLocaleToggle;

  const RecoveryOtpScreen({
    super.key,
    required this.recovery,
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
            child: BlocBuilder<PasswordRecoveryBloc, PasswordRecoveryState>(
              bloc: recovery,
              builder: (context, state) {
                final error = state.error == null
                    ? null
                    : AuthError.from(state.error!, l10n);
                return RecoveryOtpContent(
                  destination: state.email,
                  onContinue: (code) =>
                      recovery.add(RecoveryCodeEntered(code)),
                  onResend: () =>
                      recovery.add(RecoveryCodeRequested(state.email)),
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
