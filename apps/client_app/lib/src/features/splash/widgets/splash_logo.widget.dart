import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const SplashLogo({
    super.key,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.spa,
                color: colors.onPrimary,
                size: 64,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.splashTitle,
                style: DorakTypography.displayLg.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
