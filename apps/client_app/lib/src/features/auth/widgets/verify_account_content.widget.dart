import 'dart:async';

import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/auth_error.entity.dart';
import 'package:client_app/src/features/auth/widgets/otp_input_field.widget.dart';

class VerifyAccountContent extends StatefulWidget {
  static const int codeLength = 6;
  static const int resendCooldownSeconds = 60;

  final String destination;
  final void Function(String code) onVerify;
  final void Function() onResend;
  final AuthError? error;
  final bool isVerifying;
  final VoidCallback onSkip;

  const VerifyAccountContent({
    super.key,
    required this.destination,
    required this.onVerify,
    required this.onResend,
    required this.error,
    required this.isVerifying,
    required this.onSkip,
  });

  @override
  State<VerifyAccountContent> createState() => _VerifyAccountContentState();
}

class _VerifyAccountContentState extends State<VerifyAccountContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _cooldownTimer;
  int _cooldown = VerifyAccountContent.resendCooldownSeconds;
  AuthError? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      VerifyAccountContent.codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      VerifyAccountContent.codeLength,
      (_) => FocusNode(),
    );
    _error = widget.error;
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

  @override
  void didUpdateWidget(covariant VerifyAccountContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.error, widget.error)) {
      _error = widget.error;
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = VerifyAccountContent.resendCooldownSeconds);
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
    setState(() => _error = null);

    if (value.isNotEmpty && index < VerifyAccountContent.codeLength - 1) {
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

  void _verify() {
    final l10n = AppLocalizations.of(context)!;
    final code = _code;
    if (code.length < VerifyAccountContent.codeLength) {
      setState(() => _error = AuthError(message: l10n.verifyErrorInvalid));
      return;
    }

    setState(() => _error = null);
    widget.onVerify(code);
  }

  void _resend() {
    setState(() => _error = null);
    widget.onResend();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final error = _error;
    final busy = widget.isVerifying;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read, size: 48, color: colors.primary),
        const SizedBox(height: 16),
        Text(
          l10n.verifyTitle,
          style: DorakTypography.headlineSm.copyWith(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.verifySubtitle(_maskedDestination),
          style: DorakTypography.bodyMd.copyWith(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (var i = 0; i < VerifyAccountContent.codeLength; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: OtpInputField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  autofocus: i == 0,
                  enabled: !busy,
                  hasError: error != null,
                  onChanged: (value) => _onDigitChanged(i, value),
                  onBackspaceWhenEmpty: () => _onBackspaceWhenEmpty(i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 24,
          child: error == null ? null : StatusBanner(message: error.message),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: l10n.verifyButton,
          onPressed: _verify,
          isLoading: widget.isVerifying,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.verifyDidNotReceive,
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: (_cooldown > 0 || busy) ? null : _resend,
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: DorakTypography.labelLg,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _cooldown > 0
                    ? l10n.verifyResendDisabled(_cooldown)
                    : l10n.verifyResend,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SkipButton(
          label: l10n.verifySkip,
          onPressed: widget.onSkip,
          isDisabled: busy,
        ),
      ],
    );
  }
}
