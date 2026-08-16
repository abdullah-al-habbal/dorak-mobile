import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.notifier.dart';

class DorakApp extends StatefulWidget {
  final AppPreferences preferences;
  final TokenStorage? tokenStorage;
  final AuthRepository? authRepository;

  const DorakApp({
    super.key,
    required this.preferences,
    this.tokenStorage,
    this.authRepository,
  });

  @override
  State<DorakApp> createState() => _DorakAppState();
}

class _DorakAppState extends State<DorakApp> {
  final ValueNotifier<Locale> _locale = ValueNotifier<Locale>(
    const Locale('en'),
  );
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final SessionController _session;
  late final OnboardingConfigController _onboardingConfig;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = widget.tokenStorage ?? SecureTokenStorage();
    _apiClient = ApiClient(
      baseUrl: ConfigProvider.config.apiBaseV1Url,
      localeResolver: () => _locale.value.languageCode,

      tokenProvider: _tokenStorage.read,
      enableLogging: kDebugMode,
    );
    _session = SessionController(
      widget.authRepository ?? DioAuthRepository(_apiClient),
      _tokenStorage,
    );

    unawaited(_session.ready);

    _onboardingConfig = OnboardingConfigController(
      DioOnboardingConfigRepository(_apiClient),
      () => _locale.value,
    );
    _onboardingConfig.load();
    _locale.addListener(_onLocaleChanged);

    _router = AppRouter(
      session: _session,
      preferences: widget.preferences,
      onboardingConfig: _onboardingConfig,
      switchLocale: _switchLocale,
      unauthorizedNotifier: _apiClient.unauthorizedNotifier,
    );
  }

  void _onLocaleChanged() {
    _onboardingConfig.load();
  }

  @override
  void dispose() {
    _locale.removeListener(_onLocaleChanged);
    _router.dispose();
    _session.dispose();
    _onboardingConfig.dispose();
    _locale.dispose();
    super.dispose();
  }

  void _switchLocale() {
    _locale.value = _locale.value.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _locale,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'Dorak',
          debugShowCheckedModeBanner: false,
          theme: DorakTheme.forLocale(locale, Brightness.light),
          darkTheme: DorakTheme.forLocale(locale, Brightness.dark),
          themeMode: ThemeMode.system,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.splashTitle ?? 'Dorak',
          routerConfig: _router.router,
        );
      },
    );
  }
}
