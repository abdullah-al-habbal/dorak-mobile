import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/onboarding/widgets/ai_showcase_content.widget.dart';
import 'package:client_app/src/features/onboarding/widgets/skip_bottom_sheet.sheet.dart';

class AiShowcaseScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkipForNow;
  final VoidCallback onDontShowAgain;
  final VoidCallback onLocaleToggle;

  const AiShowcaseScreen({
    super.key,
    required this.onNext,
    required this.onSkipForNow,
    required this.onDontShowAgain,
    required this.onLocaleToggle,
  });

  @override
  State<AiShowcaseScreen> createState() => _AiShowcaseScreenState();
}

class _AiShowcaseScreenState extends State<AiShowcaseScreen>
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: colors.background,
      body: SwipeNavigation(
        onSwipeRight: widget.onNext,
        onSwipeLeft: () => Navigator.pop(context),
        child: SafeArea(
          child: Column(
            children: [
              FadeTransition(
                opacity: _staggeredAnimations[0],
                child: OnboardingHeader(
                  brandLabel: l10n.splashTitle,
                  skipLabel: l10n.skip,
                  onSkip: _showSkipBottomSheet,
                  localeLabel: isArabic ? l10n.localeEnglish : l10n.localeArabic,
                  onLocaleToggle: widget.onLocaleToggle,
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _staggeredAnimations[2],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AiShowcaseContent(
                    onNext: widget.onNext,
                    onPrevious: () => Navigator.pop(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
