import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/locale/locale.bloc.dart';
import 'package:client_app/src/core/locale/locale.event.dart';
import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/session/auth_coordination.entity.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.event.dart';

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
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthBloc _authBloc;
  late final SessionBloc _sessionBloc;
  late final PasswordRecoveryBloc _recoveryBloc;
  late final OnboardingConfigBloc _onboardingConfigBloc;
  late final LocaleBloc _localeBloc;
  late final AppRouter _router;
  late final StreamSubscription<void> _unauthorizedSubscription;
  late final StreamSubscription<Locale> _localeSubscription;
  late final StreamSubscription<AuthState> _authCoordinatorSubscription;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _tokenStorage = widget.tokenStorage ?? SecureTokenStorage();
    _localeBloc = LocaleBloc();
    _apiClient = ApiClient(
      baseUrl: ConfigProvider.config.apiBaseV1Url,
      localeResolver: () => _localeBloc.state.languageCode,

      tokenProvider: _tokenStorage.read,
      enableLogging: kDebugMode,
    );
    final repository = widget.authRepository ?? DioAuthRepository(_apiClient);
    _authBloc = AuthBloc(repository, _tokenStorage);
    _sessionBloc = SessionBloc(repository, _tokenStorage);
    _recoveryBloc = PasswordRecoveryBloc(repository);

    unawaited(_sessionBloc.ready);

    _onboardingConfigBloc = OnboardingConfigBloc(
      DioOnboardingConfigRepository(_apiClient),
    );
    _onboardingConfigBloc.add(
      OnboardingConfigLoadRequested(localeCode: _localeBloc.state.languageCode),
    );

    _authCoordinatorSubscription = _authBloc.stream.listen(
      (authState) => coordinateAuthSuccess(authState, _sessionBloc),
    );

    _unauthorizedSubscription = _apiClient.unauthorizedStream.listen((_) {
      _sessionBloc.add(UnauthorizedDetected());
    });

    _lifecycleListener = AppLifecycleListener(onResume: _probeSessionOnResume);

    _localeSubscription = _localeBloc.stream.listen((locale) {
      _onboardingConfigBloc.add(
        OnboardingConfigLoadRequested(localeCode: locale.languageCode),
      );
    });

    _router = AppRouter(
      session: _sessionBloc,
      auth: _authBloc,
      recovery: _recoveryBloc,
      preferences: widget.preferences,
      onboardingConfig: _onboardingConfigBloc,
      switchLocale: _switchLocale,
      apiClient: _apiClient,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _authCoordinatorSubscription.cancel();
    _unauthorizedSubscription.cancel();
    _localeSubscription.cancel();
    _router.dispose();
    _authBloc.close();
    _sessionBloc.close();
    _recoveryBloc.close();
    _onboardingConfigBloc.close();
    _localeBloc.close();
    _apiClient.dispose();
    super.dispose();
  }

  void _switchLocale() {
    _localeBloc.add(LocaleToggled());
  }

  /// Re-probes the stored token whenever the app returns to the foreground.
  ///
  /// A session can die while the app is backgrounded — the token expires or is
  /// revoked server-side and nothing tells the client. Without this probe the
  /// app keeps rendering authenticated UI until some later request happens to
  /// return 401.
  ///
  /// See `docs/runtime/app_lifecycle.md`.
  void _probeSessionOnResume() {
    final session = _sessionBloc.state;

    // The startup restore owns the `unknown` status. Racing it would resolve
    // the session twice behind the splash's `session.ready` completer.
    if (session.status == AuthStatus.unknown) return;

    // A restore or logout is already running. `RestoreRequested` uses Bloc's
    // default concurrent transformer, so a second one would overlap the first.
    if (session.isLoading) return;

    _sessionBloc.add(RestoreRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, Locale>(
      bloc: _localeBloc,
      builder: (context, locale) {
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
