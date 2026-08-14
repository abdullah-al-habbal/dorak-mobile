import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Color? foregroundColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDisabled ? colors.outlineVariant : foregroundColor ?? colors.onSurfaceVariant,
          disabledForegroundColor: colors.outlineVariant,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: DorakDimensions.radiusFull,
          ),
          side: BorderSide(
            color: isDisabled ? colors.outlineVariant : borderColor ?? colors.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: DorakTypography.labelLg,
        ),
      ),
    );
  }
}
