import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

class WelcomeContent extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeContent({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.onboardingWelcomeTitle,
          style: DorakTypography.headlineLgMobile,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingWelcomeSubtitle,
          style: DorakTypography.bodyLg,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const ProgressDots(
          count: 4,
          activeIndex: 0,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.onboardingGetStarted,
          onPressed: onGetStarted,
        ),
      ],
    );
  }
}
