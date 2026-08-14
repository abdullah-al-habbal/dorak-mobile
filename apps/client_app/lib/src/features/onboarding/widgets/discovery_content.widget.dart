import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import '../discovery_card_data.dart';
import 'discovery_card_deck.widget.dart';

class DiscoveryContent extends StatelessWidget {
  final VoidCallback onNext;

  const DiscoveryContent({
    super.key,
    required this.onNext,
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
          count: 4,
          activeIndex: 1,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.next,
          onPressed: onNext,
        ),
      ],
    );
  }
}
