import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'onboarding_hero.dart';
import 'widgets/discovery_content.widget.dart';
import 'widgets/skip_bottom_sheet.sheet.dart';

class DiscoveryScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkipForNow;
  final VoidCallback onDontShowAgain;

  const DiscoveryScreen({
    super.key,
    required this.onNext,
    required this.onSkipForNow,
    required this.onDontShowAgain,
  });

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggeredAnimations = [
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    ];

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showSkipBottomSheet() {
    SkipBottomSheet.show(
      context,
      onSkipForNow: widget.onSkipForNow,
      onDontShowAgain: widget.onDontShowAgain,
      onCancel: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          HeroImage(imageUrl: kOnboardingHeroUrl),
          const GradientOverlay(),
          SafeArea(
            child: Column(
              children: [
                FadeTransition(
                  opacity: _staggeredAnimations[0],
                  child: OnboardingHeader(
                    brandLabel: l10n.splashTitle,
                    skipLabel: l10n.skip,
                    onSkip: _showSkipBottomSheet,
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _staggeredAnimations[2],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DiscoveryContent(
                      onNext: widget.onNext,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
