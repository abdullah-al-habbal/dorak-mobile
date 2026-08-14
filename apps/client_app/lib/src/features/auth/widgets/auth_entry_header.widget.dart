import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthEntryHeader extends StatelessWidget {
  final String brandLabel;
  final String title;
  final String subtitle;

  const AuthEntryHeader({
    super.key,
    required this.brandLabel,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: DorakDimensions.radiusLg,
            border: Border.all(color: colors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: colors.surfaceTint.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(Icons.spa, size: 32, color: colors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          brandLabel,
          style: DorakTypography.displayLg.copyWith(color: colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: DorakTypography.headlineSm.copyWith(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            subtitle,
            style: DorakTypography.bodyLg.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
