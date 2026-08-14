import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.primaryContainer,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.outlineVariant,
          disabledForegroundColor: colors.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: DorakDimensions.radiusFull,
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : Text(
                label,
                style: DorakTypography.labelLg,
              ),
      ),
    );
  }
}
