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
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';
import 'package:client_app/src/features/splash/splash.screen.dart';

class AppRouter {
  final SessionBloc session;
  final AppPreferences preferences;
  final OnboardingConfigBloc onboardingConfig;
  final VoidCallback switchLocale;
  final ApiClient apiClient;

  late final GoRouter router;
  late final StreamSubscription<SessionState> _sessionSubscription;

  AppRouter({
    required this.session,
    required this.preferences,
    required this.onboardingConfig,
    required this.switchLocale,
    required this.apiClient,
  }) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: _redirect,
      routes: _routes(),
    );
    _sessionSubscription = session.stream.listen(_onSessionChanged);
  }

  void dispose() {
    _sessionSubscription.cancel();
    router.dispose();
  }

  void _onSessionChanged(SessionState state) {
    router.refresh();
    switch (state.notice) {
      case SessionNotice.sessionExpired:
        router.go(AppRoutes.authEntry);
        session.add(NoticeAcknowledged());
        apiClient.resetUnauthorizedSignal();
      case SessionNotice.authenticationRequired:
        router.push<void>(AppRoutes.authEntry);
        session.add(NoticeAcknowledged());
        apiClient.resetUnauthorizedSignal();
      case SessionNotice.loginSucceeded:
        router.go(AppRoutes.home);
        session.add(NoticeAcknowledged());
      case SessionNotice.registrationSucceeded:
        session.add(SendVerificationCodeRequested());
        router.push<void>(AppRoutes.authVerify, extra: state.client?.email ?? '');
        session.add(NoticeAcknowledged());
      case SessionNotice.verificationSucceeded:
        router.go(AppRoutes.home);
        session.add(NoticeAcknowledged());
      case SessionNotice.none:
        break;
    }
  }

  String? _redirect(Object context, GoRouterState state) {
    if (session.state.status != AuthStatus.unknown) return null;
    return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
  }

  Future<void> _leaveSplash() async {
    await session.ready;
    router.go(
      AppGate.resolve(
        isAuthenticated: session.state.isAuthenticated,
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
              session: session,
              onCreateAccount: () => router.push<void>(AppRoutes.authRegister),
              onForgotPassword: null,
            ),
          ),
          GoRoute(
            path: AppRoutes.registerSegment,
            builder: (context, state) => SignUpScreen(
              session: session,
              onLogInLink: () => router.push<void>(AppRoutes.authLogin),
            ),
          ),
          GoRoute(
            path: AppRoutes.verifySegment,
            builder: (context, state) => VerifyAccountScreen(
              session: session,
              destination: state.extra as String? ?? '',
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
