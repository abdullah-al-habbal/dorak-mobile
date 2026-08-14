import 'package:flutter/material.dart';

import '../tokens/tokens.barrel.dart';

class SkipButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDisabled;

  const SkipButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            isDisabled ? colors.outlineVariant : colors.onSurfaceVariant,
        textStyle: DorakTypography.labelLg.copyWith(
          color: isDisabled ? colors.outlineVariant : colors.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}
