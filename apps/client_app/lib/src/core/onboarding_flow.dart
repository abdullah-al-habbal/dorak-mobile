import 'package:flutter/material.dart';
import 'package:client_app/src/features/onboarding/ai_showcase.screen.dart';
import 'package:client_app/src/features/onboarding/booking.screen.dart';
import 'package:client_app/src/features/onboarding/discovery.screen.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.notifier.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';
import 'package:client_app/src/navigation/app_navigator.dart';

class OnboardingFlow {
  static void start(
    OnboardingConfigController config,
    VoidCallback switchLocale,
  ) {
    AppNavigator.replaceWith(
      WelcomeScreen(
        onboardingConfig: config,
        onNext: () => _discovery(config, switchLocale),
        onSkipForNow: AppNavigator.goHome,
        onDontShowAgain: AppNavigator.goHome,
        onLocaleToggle: switchLocale,
      ),
    );
  }

  static void _discovery(
    OnboardingConfigController config,
    VoidCallback switchLocale,
  ) {
    AppNavigator.push(
      DiscoveryScreen(
        onboardingConfig: config,
        onNext: () => _booking(config, switchLocale),
        onSkipForNow: AppNavigator.goHome,
        onDontShowAgain: AppNavigator.goHome,
        onLocaleToggle: switchLocale,
      ),
    );
  }

  static void _booking(
    OnboardingConfigController config,
    VoidCallback switchLocale,
  ) {
    AppNavigator.push(
      BookingScreen(
        onNext: () => _aiShowcase(switchLocale),
        onSkipForNow: AppNavigator.goHome,
        onDontShowAgain: AppNavigator.goHome,
        onLocaleToggle: switchLocale,
      ),
    );
  }

  static void _aiShowcase(VoidCallback switchLocale) {
    AppNavigator.push(
      AiShowcaseScreen(
        onNext: AppNavigator.goHome,
        onSkipForNow: AppNavigator.goHome,
        onDontShowAgain: AppNavigator.goHome,
        onLocaleToggle: switchLocale,
      ),
    );
  }
}