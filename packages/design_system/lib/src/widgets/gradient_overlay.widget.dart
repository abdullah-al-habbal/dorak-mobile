import 'package:flutter/material.dart';

import '../tokens/tokens.barrel.dart';

class GradientOverlay extends StatelessWidget {
  const GradientOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            colors.background,
            colors.background.withValues(alpha: 0.9),
            colors.background.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}
