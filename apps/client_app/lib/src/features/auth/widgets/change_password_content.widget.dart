import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/auth_validators.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';

class ChangePasswordContent extends StatefulWidget {
  final void Function({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) onSubmit;
  final AuthError? error;
  final bool isSubmitting;

  const ChangePasswordContent({
    super.key,
    required this.onSubmit,
    required this.error,
    required this.isSubmitting,
  });

  @override
  State<ChangePasswordContent> createState() => _ChangePasswordContentState();
}

class _ChangePasswordContentState extends State<ChangePasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      currentPassword: _currentController.text,
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
          Text(
            l10n.changePasswordTitle,
            style: DorakTypography.headlineLgMobile.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.changePasswordSubtitle,
            style: DorakTypography.bodyLg.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            label: l10n.changePasswordCurrentLabel,
            controller: _currentController,
            isPassword: true,
            enabled: !widget.isSubmitting,
            validator: (value) => AuthValidators.required(value, l10n),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: l10n.changePasswordNewLabel,
            controller: _passwordController,
            isPassword: true,
            enabled: !widget.isSubmitting,
            helperText: l10n.signUpPasswordHint,
            validator: (value) => AuthValidators.password(value, l10n),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: l10n.changePasswordConfirmLabel,
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
          const SizedBox(height: 8),
          if (error != null) ...[
            const SizedBox(height: 8),
            StatusBanner(message: _bannerMessage(error)),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.changePasswordSubmit,
            onPressed: _submit,
            isLoading: widget.isSubmitting,
          ),
        ],
      ),
    );
  }

  String _bannerMessage(AuthError error) {
    final fieldMessages = error.fieldErrors.values
        .expand((messages) => messages)
        .join('\n');
    return fieldMessages.isEmpty ? error.message : fieldMessages;
  }
}
