import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/onboarding/widgets/ai_showcase_visual.widget.dart';

class AiShowcaseContent extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AiShowcaseContent({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AiShowcaseVisual(),
        const SizedBox(height: 16),
        Text(
          l10n.aiTitle,
          style: DorakTypography.headlineLgMobile,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aiSubtitle,
          style: DorakTypography.bodyLg,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.privacy_tip,
              color: colors.outline,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.aiPrivacyNote,
                style: DorakTypography.bodyMd.copyWith(color: colors.outline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const ProgressDots(
          count: 4,
          activeIndex: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.previous,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: l10n.onboardingGetStarted,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
