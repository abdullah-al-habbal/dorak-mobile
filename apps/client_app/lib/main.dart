import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'src/features/home/home.screen.dart';
import 'src/features/onboarding/discovery.screen.dart';
import 'src/features/onboarding/welcome.screen.dart';
import 'src/features/splash/splash.screen.dart';

void main() {
  runApp(const DorakApp());
}

class DorakApp extends StatefulWidget {
  const DorakApp({super.key});

  @override
  State<DorakApp> createState() => _DorakAppState();
}

class _DorakAppState extends State<DorakApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
        onGetStarted: () => _push(
          DiscoveryScreen(
            onNext: _goHome,
            onSkipForNow: _goHome,
            onDontShowAgain: _goHome,
          ),
        ),
        onSkipForNow: _goHome,
        onDontShowAgain: _goHome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorak',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: DorakTheme.light,
      darkTheme: DorakTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashScreen(onFinished: _openWelcome),
    );
  }
}
