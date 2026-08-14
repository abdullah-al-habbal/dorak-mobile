import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/onboarding/onboarding_config.notifier.dart';

class OnboardingHeroImage extends StatelessWidget {
  final OnboardingConfigController controller;

  const OnboardingHeroImage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final url = controller.heroImageUrl;
        final image = (url == null || url.isEmpty)
            ? const AssetImage('assets/images/onboarding_hero.jpg')
                as ImageProvider
            : NetworkImage(url);
        return HeroImage(
          image: image,
          errorBuilder: (_, _, _) => const Image(
            image: AssetImage('assets/images/onboarding_hero.jpg'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}
