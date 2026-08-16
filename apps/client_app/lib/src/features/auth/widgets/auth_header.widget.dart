import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthHeader extends StatelessWidget {
  final String brandLabel;
  final String backTooltip;
  final VoidCallback onBack;

  const AuthHeader({
    super.key,
    required this.brandLabel,
    required this.backTooltip,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: backTooltip,
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: colors.onSurface,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.spa, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                brandLabel,
                style: DorakTypography.titleLg.copyWith(color: colors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
