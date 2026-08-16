import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/auth_validators.entity.dart';
import 'package:client_app/src/features/auth/widgets/auth_error_banner.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_text_field.widget.dart';

class SignUpContent extends StatefulWidget {
  final Animation<double> titleAnimation;
  final Animation<double> formAnimation;
  final Animation<double> actionsAnimation;
  final Future<void> Function({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) onSubmit;
  final VoidCallback onLogInLink;

  const SignUpContent({
    super.key,
    required this.titleAnimation,
    required this.formAnimation,
    required this.actionsAnimation,
    required this.onSubmit,
    required this.onLogInLink,
  });

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isSubmitting = false;
  AuthError? _error;
  Map<String, List<String>> _serverFieldErrors = const {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final messages = _serverFieldErrors[field];
    if (messages == null || messages.isEmpty) return null;
    return messages.first;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _error = null;
      _serverFieldErrors = const {};
    });

    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );
    } catch (e) {
      if (!mounted) return;
      final error = AuthError.from(e, l10n);
      setState(() {
        _error = error;
        _serverFieldErrors = error.fieldErrors;
      });
      _formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

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
                  l10n.signUpTitle,
                  style: DorakTypography.headlineLgMobile.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signUpSubtitle,
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
                  label: l10n.signUpFullNameLabel,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  enabled: !_isSubmitting,
                  validator: (value) =>
                      AuthValidators.required(value, l10n) ??
                      _serverError('name'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: l10n.signUpEmailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isSubmitting,
                  validator: (value) =>
                      AuthValidators.email(value, l10n) ??
                      _serverError('email'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: l10n.signUpPasswordLabel,
                  controller: _passwordController,
                  isPassword: true,
                  enabled: !_isSubmitting,
                  helperText: l10n.signUpPasswordHint,
                  validator: (value) =>
                      AuthValidators.password(value, l10n) ??
                      _serverError('password'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: l10n.signUpConfirmPasswordLabel,
                  controller: _confirmController,
                  isPassword: true,
                  enabled: !_isSubmitting,
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
          const SizedBox(height: 24),
          FadeTransition(
            opacity: widget.actionsAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  AuthErrorBanner(message: _error!.message),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: l10n.signUpButton,
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.signUpAlreadyHaveAccount,
                      style: DorakTypography.bodyMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: _isSubmitting ? null : widget.onLogInLink,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.primary,
                        textStyle: DorakTypography.labelLg,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.signUpLogInLink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
