import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/auth_validators.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';

class ForgotPasswordContent extends StatefulWidget {
  final Animation<double> titleAnimation;
  final Animation<double> formAnimation;
  final Animation<double> actionsAnimation;
  final void Function(String email) onSubmit;
  final VoidCallback onReturnToLogIn;
  final AuthError? error;
  final bool isSubmitting;

  const ForgotPasswordContent({
    super.key,
    required this.titleAnimation,
    required this.formAnimation,
    required this.actionsAnimation,
    required this.onSubmit,
    required this.onReturnToLogIn,
    required this.error,
    required this.isSubmitting,
  });

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final error = widget.error;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeTransition(
            opacity: widget.titleAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recoveryEmailTitle,
                  style: DorakTypography.headlineLgMobile.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.recoveryEmailSubtitle,
                  style: DorakTypography.bodyLg.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: widget.formAnimation,
            child: AuthTextField(
              label: l10n.recoveryEmailLabel,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !widget.isSubmitting,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) => AuthValidators.email(value, l10n),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: widget.actionsAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) ...[
                  const SizedBox(height: 8),
                  StatusBanner(message: error.message),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.recoverySendCodeButton,
                  onPressed: _submit,
                  isLoading: widget.isSubmitting,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SkipButton(
                    label: l10n.recoveryReturnToLogIn,
                    onPressed: widget.onReturnToLogIn,
                    isDisabled: widget.isSubmitting,
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
