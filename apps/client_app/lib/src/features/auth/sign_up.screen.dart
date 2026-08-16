import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/sign_up_content.widget.dart';

class SignUpScreen extends StatefulWidget {
  final AuthBloc auth;
  final VoidCallback onLogInLink;

  const SignUpScreen({
    super.key,
    required this.auth,
    required this.onLogInLink,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
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
                        child: BlocBuilder<AuthBloc, AuthState>(
                          bloc: widget.auth,
                          builder: (context, state) {
                            final error = state.error == null
                                ? null
                                : AuthError.from(state.error!, l10n);
                            return SignUpContent(
                              titleAnimation: _staggeredAnimations[0],
                              formAnimation: _staggeredAnimations[1],
                              actionsAnimation: _staggeredAnimations[2],
                              onSubmit: ({
                                required name,
                                required email,
                                required password,
                                required passwordConfirmation,
                              }) =>
                                  widget.auth.add(RegisterRequested(
                                    name: name,
                                    email: email,
                                    password: password,
                                    passwordConfirmation: passwordConfirmation,
                                  )),
                              error: error,
                              isSubmitting: state.isSubmitting,
                              onLogInLink: widget.onLogInLink,
                            );
                          },
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
