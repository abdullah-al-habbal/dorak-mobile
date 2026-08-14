import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';
import 'package:client_app/src/features/onboarding/discovery_card.entity.dart';
import 'package:client_app/src/features/onboarding/widgets/discovery_card_deck.widget.dart';
class DiscoveryContent extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  const DiscoveryContent({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      DiscoveryCardData(icon: Icons.storefront, label: l10n.discoveryCardShops),
      DiscoveryCardData(
        icon: Icons.content_cut,
        label: l10n.discoveryCardBarbers,
      ),
      DiscoveryCardData(icon: Icons.spa, label: l10n.discoveryCardServices),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.discoveryTitle,
          style: DorakTypography.headlineLgMobile,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.discoverySubtitle,
          style: DorakTypography.bodyLg,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        DiscoveryCardDeck(cards: cards),
        const SizedBox(height: 24),
        const ProgressDots(
          count: 2,
          activeIndex: 1,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SkipButton(
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