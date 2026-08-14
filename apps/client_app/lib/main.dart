import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/home/home.screen.dart';
import 'package:client_app/src/features/onboarding/discovery.screen.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.notifier.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';
import 'package:client_app/src/features/splash/splash.screen.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const DorakApp());
}

class DorakApp extends StatefulWidget {
  const DorakApp({super.key});

  @override
  State<DorakApp> createState() => _DorakAppState();
}

class _DorakAppState extends State<DorakApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<Locale> _locale = ValueNotifier<Locale>(const Locale('en'));
  late final ApiClient _apiClient;
  late final OnboardingConfigController _onboardingConfig;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(
      baseUrl: ConfigProvider.config.apiBaseV1Url,
      localeResolver: () => _locale.value.languageCode,
      enableLogging: kDebugMode,
    );
    _onboardingConfig = OnboardingConfigController(
      DioOnboardingConfigRepository(_apiClient),
      () => _locale.value,
    );
    _onboardingConfig.load();
    _locale.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    _onboardingConfig.load();
  }

  @override
  void dispose() {
    _locale.removeListener(_onLocaleChanged);
    _onboardingConfig.dispose();
    _locale.dispose();
    super.dispose();
  }

  void _switchLocale() {
    _locale.value = _locale.value.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }

  void _replaceWith(Widget screen) {
    _navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _push(Widget screen) {
    _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _goHome() => _replaceWith(const HomeScreen());

  void _openWelcome() {
    _replaceWith(
      WelcomeScreen(
        onboardingConfig: _onboardingConfig,
        onNext: () => _push(
          DiscoveryScreen(
            onboardingConfig: _onboardingConfig,
            onNext: _goHome,
            onSkipForNow: _goHome,
            onDontShowAgain: _goHome,
            onLocaleToggle: _switchLocale,
          ),
        ),
        onSkipForNow: _goHome,
        onDontShowAgain: _goHome,
        onLocaleToggle: _switchLocale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Dorak',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          theme: DorakTheme.forLocale(locale, Brightness.light),
          darkTheme: DorakTheme.forLocale(locale, Brightness.dark),
          themeMode: ThemeMode.system,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.splashTitle ?? 'Dorak',
          home: SplashScreen(onFinished: _openWelcome),
        );
      },
    );
  }
}
