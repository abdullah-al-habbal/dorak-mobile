import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:client_app/src/core/navigation/app_gate.entity.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/sign_up.screen.dart';
import 'package:client_app/src/features/auth/verify_account.screen.dart';
import 'package:client_app/src/features/home/home.screen.dart';
import 'package:client_app/src/features/onboarding/ai_showcase.screen.dart';
import 'package:client_app/src/features/onboarding/booking.screen.dart';
import 'package:client_app/src/features/onboarding/discovery.screen.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.notifier.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';
import 'package:client_app/src/features/splash/splash.screen.dart';

class AppRouter {
  final SessionController session;
  final AppPreferences preferences;
  final OnboardingConfigController onboardingConfig;
  final VoidCallback switchLocale;
  final UnauthorizedNotifier unauthorizedNotifier;

  late final GoRouter router;

  AppRouter({
    required this.session,
    required this.preferences,
    required this.onboardingConfig,
    required this.switchLocale,
    required this.unauthorizedNotifier,
  }) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: _redirect,
      routes: _routes(),
    );
    unauthorizedNotifier.addListener(_onUnauthorized);
    session.addListener(_onSessionChanged);
  }

  void dispose() {
    session.removeListener(_onSessionChanged);
    unauthorizedNotifier.removeListener(_onUnauthorized);
    router.dispose();
  }

  void _onUnauthorized() {
    unawaited(session.handleUnauthorized());
  }

  String? _redirect(Object context, GoRouterState state) {
    if (session.status != AuthStatus.unknown) return null;
    return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
  }

  void _onSessionChanged() {
    switch (session.notice) {
      case SessionNotice.sessionExpired:
        router.go(AppRoutes.authEntry);
        session.acknowledgeNotice();
        unauthorizedNotifier.reset();
      case SessionNotice.authenticationRequired:
        router.push<void>(AppRoutes.authEntry);
        session.acknowledgeNotice();
        unauthorizedNotifier.reset();
      case SessionNotice.none:
        break;
    }
  }

  Future<void> _leaveSplash() async {
    await session.ready;
    router.go(
      AppGate.resolve(
        isAuthenticated: session.isAuthenticated,
        dontShowOnboarding: preferences.dontShowOnboarding,
      ),
    );
  }

  void _skipForNow() => router.go(AppRoutes.home);

  Future<void> _dismissForever() async {
    try {
      await preferences.setDontShowOnboarding(true);
    } finally {
      router.go(AppRoutes.home);
    }
  }

  Future<void> _register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await session.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    try {
      await session.sendVerificationCode();
    } catch (_) {}
    router.push<void>(AppRoutes.authVerify, extra: email);
  }

  List<RouteBase> _routes() {
    return [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            SplashScreen(onFinished: () => unawaited(_leaveSplash())),
      ),
      GoRoute(
        path: AppRoutes.onboardingWelcome,
        builder: (context, state) => WelcomeScreen(
          onboardingConfig: onboardingConfig,
          onNext: () => router.push<void>(AppRoutes.onboardingDiscovery),
          onSkipForNow: _skipForNow,
          onDontShowAgain: () => unawaited(_dismissForever()),
          onLocaleToggle: switchLocale,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingDiscovery,
        builder: (context, state) => DiscoveryScreen(
          onboardingConfig: onboardingConfig,
          onNext: () => router.push<void>(AppRoutes.onboardingBooking),
          onSkipForNow: _skipForNow,
          onDontShowAgain: () => unawaited(_dismissForever()),
          onLocaleToggle: switchLocale,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingBooking,
        builder: (context, state) => BookingScreen(
          onNext: () => router.push<void>(AppRoutes.onboardingAiStyle),
          onSkipForNow: _skipForNow,
          onDontShowAgain: () => unawaited(_dismissForever()),
          onLocaleToggle: switchLocale,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingAiStyle,
        builder: (context, state) => AiShowcaseScreen(
          onNext: () => unawaited(_dismissForever()),
          onSkipForNow: _skipForNow,
          onDontShowAgain: () => unawaited(_dismissForever()),
          onLocaleToggle: switchLocale,
        ),
      ),
      GoRoute(
        path: AppRoutes.authEntry,
        builder: (context, state) => AuthEntryScreen(
          onLogin: () => router.push<void>(AppRoutes.authLogin),
          onSignup: () => router.push<void>(AppRoutes.authRegister),
          onGuest: () => router.go(AppRoutes.onboardingWelcome),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.loginSegment,
            builder: (context, state) => LoginScreen(
              onSubmit: (email, password) async {
                await session.login(email: email, password: password);
                router.go(AppRoutes.home);
              },
              onCreateAccount: () => router.push<void>(AppRoutes.authRegister),
              onForgotPassword: null,
            ),
          ),
          GoRoute(
            path: AppRoutes.registerSegment,
            builder: (context, state) => SignUpScreen(
              onSubmit: _register,
              onLogInLink: () => router.push<void>(AppRoutes.authLogin),
            ),
          ),
          GoRoute(
            path: AppRoutes.verifySegment,
            builder: (context, state) => VerifyAccountScreen(
              destination: state.extra as String? ?? '',
              onVerify: (code) async {
                await session.verifyEmail(code);
                router.go(AppRoutes.home);
              },
              onResend: session.sendVerificationCode,
              onSkip: () => router.go(AppRoutes.home),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ];
  }
}
