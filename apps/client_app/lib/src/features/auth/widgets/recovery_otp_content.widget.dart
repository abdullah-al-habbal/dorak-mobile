import 'dart:async';

import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/widgets/otp_input_field.widget.dart';

class RecoveryOtpContent extends StatefulWidget {
  static const int codeLength = 6;
  static const int resendCooldownSeconds = 60;

  final String destination;
  final void Function(String code) onContinue;
  final VoidCallback onResend;
  final AuthError? error;
  final bool isSubmitting;

  const RecoveryOtpContent({
    super.key,
    required this.destination,
    required this.onContinue,
    required this.onResend,
    required this.error,
    required this.isSubmitting,
  });

  @override
  State<RecoveryOtpContent> createState() => _RecoveryOtpContentState();
}

class _RecoveryOtpContentState extends State<RecoveryOtpContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _cooldownTimer;
  int _cooldown = RecoveryOtpContent.resendCooldownSeconds;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      RecoveryOtpContent.codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      RecoveryOtpContent.codeLength,
      (_) => FocusNode(),
    );
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = RecoveryOtpContent.resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldown -= 1);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  String get _maskedDestination {
    final value = widget.destination.trim();
    final at = value.indexOf('@');
    if (at > 0) {
      return '${value[0]}***${value.substring(at)}';
    }
    if (value.length > 2) {
      return '${value[0]}***${value[value.length - 1]}';
    }
    return value;
  }

  void _onDigitChanged(int index, String value) {
    setState(() => _localError = null);

    if (value.isNotEmpty && index < RecoveryOtpContent.codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty) {
      _focusNodes[index].unfocus();
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onBackspaceWhenEmpty(int index) {
    if (index == 0) return;
    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
  }

  void _continue() {
    final l10n = AppLocalizations.of(context)!;
    final code = _code;
    if (code.length < RecoveryOtpContent.codeLength) {
      setState(() => _localError = l10n.recoveryOtpIncomplete);
      return;
    }
    setState(() => _localError = null);
    widget.onContinue(code);
  }

  void _resend() {
    setState(() => _localError = null);
    widget.onResend();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final message = _localError ?? widget.error?.message;
    final busy = widget.isSubmitting;
    final canResend = _cooldown <= 0 && !busy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_reset, size: 48, color: colors.primary),
        const SizedBox(height: 16),
        Text(
          l10n.recoveryOtpTitle,
          style: DorakTypography.headlineSm.copyWith(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.recoveryOtpSubtitle(_maskedDestination),
          style: DorakTypography.bodyMd.copyWith(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (var i = 0; i < RecoveryOtpContent.codeLength; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: OtpInputField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  autofocus: i == 0,
                  enabled: !busy,
                  hasError: message != null,
                  onChanged: (value) => _onDigitChanged(i, value),
                  onBackspaceWhenEmpty: () => _onBackspaceWhenEmpty(i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (message != null) ...[
          StatusBanner(message: message),
          const SizedBox(height: 16),
        ],
        PrimaryButton(
          label: l10n.recoveryOtpContinueButton,
          onPressed: _continue,
          isLoading: busy,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.recoveryDidNotReceive,
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SkipButton(
              label: canResend
                  ? l10n.recoveryResend
                  : l10n.recoveryResendDisabled(_cooldown),
              onPressed: canResend ? _resend : () {},
              isDisabled: !canResend,
            ),
          ],
        ),
      ],
    );
  }
}
