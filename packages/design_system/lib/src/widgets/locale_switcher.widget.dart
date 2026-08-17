import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class LocaleSwitcher extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const LocaleSwitcher({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: DorakTypography.labelLg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}