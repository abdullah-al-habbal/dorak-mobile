import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/login_content.widget.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String email, String password) onSubmit;
  final VoidCallback onCreateAccount;

  final VoidCallback? onForgotPassword;

  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onCreateAccount,
    this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthEntryBackground()),
          SafeArea(
            child: Column(
              children: [
                AuthHeader(
                  brandLabel: l10n.splashTitle,
                  backTooltip: l10n.back,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: LoginContent(
                          titleAnimation: _staggeredAnimations[0],
                          formAnimation: _staggeredAnimations[1],
                          actionsAnimation: _staggeredAnimations[2],
                          onSubmit: widget.onSubmit,
                          onForgotPassword: widget.onForgotPassword,
                          onCreateAccount: widget.onCreateAccount,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
