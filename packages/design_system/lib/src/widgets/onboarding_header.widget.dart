import 'package:flutter/material.dart';

import '../tokens/tokens.barrel.dart';
import 'skip_button.widget.dart';

class OnboardingHeader extends StatelessWidget {
  final String brandLabel;
  final String skipLabel;
  final VoidCallback onSkip;

  const OnboardingHeader({
    super.key,
    required this.brandLabel,
    required this.skipLabel,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.spa,
                color: colors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                brandLabel,
                style: DorakTypography.headlineSm.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SkipButton(
            label: skipLabel,
            onPressed: onSkip,
          ),
        ],
      ),
    );
  }
}
