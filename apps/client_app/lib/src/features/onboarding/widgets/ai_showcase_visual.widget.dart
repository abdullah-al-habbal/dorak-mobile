import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

class AiShowcaseVisual extends StatefulWidget {
  const AiShowcaseVisual({super.key});

  @override
  State<AiShowcaseVisual> createState() => _AiShowcaseVisualState();
}

class _AiShowcaseVisualState extends State<AiShowcaseVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggeredAnimations = [
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    ];

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return SizedBox(
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.tertiaryFixed.withValues(alpha: 0.4),
              ),
            ),
          ),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primaryFixedDim.withValues(alpha: 0.3),
              ),
            ),
          ),
          FadeTransition(
            opacity: _staggeredAnimations[0],
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainer,
                border: Border.all(
                  color: colors.tertiaryFixed,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.surfaceTint.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.face,
                    color: colors.tertiaryContainer,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryFixed.withValues(alpha: 0.3),
                      borderRadius: DorakDimensions.radiusFull,
                    ),
                    child: Text(
                      l10n.aiFaceShapeLabel,
                      style: DorakTypography.labelMd.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: FadeTransition(
              opacity: _staggeredAnimations[1],
              child: _RecommendationCard(
                icon: Icons.verified,
                iconColor: colors.primary,
                label: l10n.aiMatchLabel,
                labelColor: colors.primary,
                style: l10n.aiStyleFade,
                trackColor: colors.surfaceVariant,
                fillColor: colors.primary,
                fillFactor: 0.98,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 12,
            child: FadeTransition(
              opacity: _staggeredAnimations[2],
              child: _RecommendationCard(
                icon: Icons.recommend,
                iconColor: colors.secondary,
                label: l10n.aiRecommendedLabel,
                labelColor: colors.secondary,
                style: l10n.aiStyleCrop,
                trackColor: colors.surfaceVariant,
                fillColor: colors.secondary,
                fillFactor: 0.85,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final String style;
  final Color trackColor;
  final Color fillColor;
  final double fillFactor;

  const _RecommendationCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.style,
    required this.trackColor,
    required this.fillColor,
    required this.fillFactor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Container(
      width: 192,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.8),
        borderRadius: DorakDimensions.radiusLg,
        border: Border.all(
          color: colors.tertiaryFixed,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceTint.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: DorakTypography.labelMd.copyWith(color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            style,
            style: DorakTypography.titleLg.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: DorakDimensions.radiusFull,
            child: SizedBox(
              height: 4,
              width: 96,
              child: ColoredBox(
                color: trackColor,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fillFactor,
                  child: ColoredBox(color: fillColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
