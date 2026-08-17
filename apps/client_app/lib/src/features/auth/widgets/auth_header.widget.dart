import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthHeader extends StatelessWidget {
  final String brandLabel;
  final String backTooltip;
  final VoidCallback onBack;
  final String? localeLabel;
  final VoidCallback? onLocaleToggle;

  const AuthHeader({
    super.key,
    required this.brandLabel,
    required this.backTooltip,
    required this.onBack,
    this.localeLabel,
    this.onLocaleToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: onBack,
              tooltip: backTooltip,
              icon: Icon(
                isRtl ? Icons.arrow_forward : Icons.arrow_back,
                color: colors.onSurface,
              ),
            ),
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
        SizedBox(
          width: 64,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: (localeLabel != null && onLocaleToggle != null)
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LocaleSwitcher(
                      label: localeLabel!,
                      onPressed: onLocaleToggle!,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}