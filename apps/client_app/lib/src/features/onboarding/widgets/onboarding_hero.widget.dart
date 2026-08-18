import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.event.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.state.dart';

class OnboardingHeroImage extends StatelessWidget {
  final OnboardingConfigBloc bloc;

  const OnboardingHeroImage({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<OnboardingConfigBloc, OnboardingConfigState>(
      bloc: bloc,
      builder: (context, state) {
        final url = state.heroImageUrl;
        final image = (url == null || url.isEmpty)
            ? const AssetImage('assets/images/onboarding_hero.jpg')
                as ImageProvider
            : NetworkImage(url);

        final hero = HeroImage(
          image: image,
          errorBuilder: (_, _, _) => const Image(
            image: AssetImage('assets/images/onboarding_hero.jpg'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );

        if (state.error == null || state.config != null) return hero;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            hero,
            const SizedBox(height: 8),
            StatusBanner(
              message: l10n.onboardingConfigUnavailable,
              actionLabel: l10n.actionRetry,
              onAction: () => bloc.add(
                OnboardingConfigLoadRequested(
                  localeCode: state.localeCode ??
                      Localizations.localeOf(context).languageCode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
