import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';
import 'package:client_app/src/features/auth/widgets/verify_account_content.widget.dart';

class VerifyAccountScreen extends StatefulWidget {
  final AuthBloc auth;
  final String destination;
  final VoidCallback onSkip;
  final VoidCallback? onLocaleToggle;

  const VerifyAccountScreen({
    super.key,
    required this.auth,
    required this.destination,
    required this.onSkip,
    this.onLocaleToggle,
  });

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
            header: AuthHeader(
              brandLabel: l10n.splashTitle,
              backTooltip: l10n.back,
              onBack: () => context.pop(),
              localeLabel:
                  isArabic ? l10n.localeEnglish : l10n.localeArabic,
              onLocaleToggle: widget.onLocaleToggle,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.8),
                  borderRadius: DorakDimensions.radiusLg,
                  border: Border.all(
                    color: colors.primaryFixed.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.surfaceTint.withValues(alpha: 0.08),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  bloc: widget.auth,
                  builder: (context, state) {
                    final error = state.error == null
                        ? null
                        : AuthError.from(
                            state.error!,
                            l10n,
                            unprocessableMessage: l10n.verifyErrorInvalid,
                          );
                    return VerifyAccountContent(
                      destination: widget.destination,
                      onVerify: (code) =>
                          widget.auth.add(VerifyEmailRequested(code: code)),
                      onResend: () =>
                          widget.auth.add(SendVerificationCodeRequested()),
                      error: error,
                      isVerifying: state.isSubmitting,
                      onSkip: widget.onSkip,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
