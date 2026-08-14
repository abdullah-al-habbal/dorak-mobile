import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class ProgressDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const ProgressDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == activeIndex
                ? colors.primary
                : colors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
