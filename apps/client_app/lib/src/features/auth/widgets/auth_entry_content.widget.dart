import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/widgets/auth_guest_button.widget.dart';

class AuthEntryContent extends StatelessWidget {
  final List<Animation<double>> staggeredAnimations;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onGuest;

  const AuthEntryContent({
    super.key,
    required this.staggeredAnimations,
    required this.onLogin,
    required this.onSignup,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: staggeredAnimations[1],
            child: PrimaryButton(
              label: l10n.authLogIn,
              onPressed: onLogin,
              backgroundColor: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: staggeredAnimations[2],
            child: SecondaryButton(
              label: l10n.authCreateAccount,
              onPressed: onSignup,
              foregroundColor: colors.primary,
              borderColor: colors.outlineVariant,
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: staggeredAnimations[3],
            child: Column(
              children: [
                AuthGuestButton(
                  label: l10n.authContinueAsGuest,
                  onPressed: onGuest,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authGuestHint,
                  style: DorakTypography.bodyMd.copyWith(color: colors.outline),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
