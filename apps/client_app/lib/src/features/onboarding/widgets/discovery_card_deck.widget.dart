import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

import '../discovery_card_data.dart';

class DiscoveryCardDeck extends StatefulWidget {
  final List<DiscoveryCardData> cards;

  const DiscoveryCardDeck({
    super.key,
    required this.cards,
  });

  @override
  State<DiscoveryCardDeck> createState() => _DiscoveryCardDeckState();
}

class _DiscoveryCardDeckState extends State<DiscoveryCardDeck>
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

    _staggeredAnimations = List.generate(
      widget.cards.length,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0 + (index * 0.1),
          0.5 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Column(
      children: List.generate(
        widget.cards.length,
        (index) {
          final card = widget.cards[index];
          return FadeTransition(
            opacity: _staggeredAnimations[index],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(_staggeredAnimations[index]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: DorakDimensions.radiusLg,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        card.icon,
                        color: colors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        card.label,
                        style: DorakTypography.titleLg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
