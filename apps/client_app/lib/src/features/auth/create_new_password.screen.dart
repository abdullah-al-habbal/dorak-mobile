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
import 'package:client_app/src/features/auth/widgets/create_new_password_content.widget.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final PasswordRecoveryBloc recovery;
  final VoidCallback onReenterCode;
  final VoidCallback? onLocaleToggle;

  const CreateNewPasswordScreen({
    super.key,
    required this.recovery,
    required this.onReenterCode,
    this.onLocaleToggle,
  });

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _staggeredAnimations = [
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    ];
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
            pinnedHeader: true,
            header: AuthHeader(
              brandLabel: l10n.splashTitle,
              backTooltip: l10n.back,
              onBack: () => context.pop(),
              localeLabel: isArabic ? l10n.localeEnglish : l10n.localeArabic,
              onLocaleToggle: widget.onLocaleToggle,
            ),
            child: BlocBuilder<PasswordRecoveryBloc, PasswordRecoveryState>(
              bloc: widget.recovery,
              builder: (context, state) {
                final error = state.error == null
                    ? null
                    : AuthError.from(state.error!, l10n);
                return CreateNewPasswordContent(
                  titleAnimation: _staggeredAnimations[0],
                  formAnimation: _staggeredAnimations[1],
                  actionsAnimation: _staggeredAnimations[2],
                  onSubmit: ({
                    required String password,
                    required String passwordConfirmation,
                  }) =>
                      widget.recovery.add(RecoveryPasswordSubmitted(
                    password: password,
                    passwordConfirmation: passwordConfirmation,
                  )),
                  error: error,
                  isSubmitting: state.isSubmitting,
                  isCodeRejected: state.isCodeRejected,
                  onReenterCode: widget.onReenterCode,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
