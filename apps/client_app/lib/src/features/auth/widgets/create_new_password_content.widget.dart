import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/auth_validators.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';

class CreateNewPasswordContent extends StatefulWidget {
  final Animation<double> titleAnimation;
  final Animation<double> formAnimation;
  final Animation<double> actionsAnimation;
  final void Function({
    required String password,
    required String passwordConfirmation,
  }) onSubmit;
  final AuthError? error;
  final bool isSubmitting;

  final bool isCodeRejected;
  final VoidCallback onReenterCode;

  const CreateNewPasswordContent({
    super.key,
    required this.titleAnimation,
    required this.formAnimation,
    required this.actionsAnimation,
    required this.onSubmit,
    required this.error,
    required this.isSubmitting,
    required this.isCodeRejected,
    required this.onReenterCode,
  });

  @override
  State<CreateNewPasswordContent> createState() =>
      _CreateNewPasswordContentState();
}

class _CreateNewPasswordContentState extends State<CreateNewPasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
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
                  l10n.recoveryNewPasswordTitle,
                  style: DorakTypography.headlineLgMobile.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.recoveryNewPasswordSubtitle,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  label: l10n.recoveryNewPasswordLabel,
                  controller: _passwordController,
                  isPassword: true,
                  enabled: !widget.isSubmitting,
                  helperText: l10n.signUpPasswordHint,
                  validator: (value) => AuthValidators.password(value, l10n),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: l10n.recoveryConfirmPasswordLabel,
                  controller: _confirmController,
                  isPassword: true,
                  enabled: !widget.isSubmitting,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) => AuthValidators.passwordConfirmation(
                    value,
                    _passwordController.text,
                    l10n,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: widget.actionsAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isCodeRejected) ...[
                  const SizedBox(height: 8),
                  StatusBanner(
                    message: l10n.recoveryCodeRejected,
                    actionLabel: l10n.recoveryReenterCode,
                    onAction: widget.onReenterCode,
                  ),
                ] else if (error != null) ...[
                  const SizedBox(height: 8),
                  StatusBanner(message: error.message),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.recoveryResetButton,
                  onPressed: _submit,
                  isLoading: widget.isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
