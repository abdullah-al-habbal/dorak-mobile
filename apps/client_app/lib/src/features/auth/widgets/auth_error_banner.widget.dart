import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Row(
      children: [
        Icon(Icons.error_outline, size: 18, color: colors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: DorakTypography.labelMd.copyWith(color: colors.error),
          ),
        ),
      ],
    );
  }
}
