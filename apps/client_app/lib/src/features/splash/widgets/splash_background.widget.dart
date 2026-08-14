import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                colors.primaryContainer,
                colors.primary,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: Image.asset(
              'assets/images/noise_overlay.png',
              fit: BoxFit.cover,
              cacheWidth: 400,
              cacheHeight: 800,
            ),
          ),
        ),
      ],
    );
  }
}
