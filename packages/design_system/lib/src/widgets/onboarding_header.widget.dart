import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';
import 'package:design_system/src/widgets/skip_button.widget.dart';

class OnboardingHeader extends StatelessWidget {
  final String brandLabel;
  final String skipLabel;
  final VoidCallback onSkip;
  final String? localeLabel;
  final VoidCallback? onLocaleToggle;

  const OnboardingHeader({
    super.key,
    required this.brandLabel,
    required this.skipLabel,
    required this.onSkip,
    this.localeLabel,
    this.onLocaleToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.spa,
                  color: colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    brandLabel,
                    overflow: TextOverflow.ellipsis,
                    style: DorakTypography.headlineSm.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (localeLabel != null && onLocaleToggle != null)
                TextButton(
                  onPressed: onLocaleToggle,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    textStyle: DorakTypography.labelLg,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(localeLabel!),
                ),
              SkipButton(
                label: skipLabel,
                onPressed: onSkip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
