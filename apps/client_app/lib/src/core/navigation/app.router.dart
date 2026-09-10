import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/navigation/app_gate.entity.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:client_app/src/features/auth/change_password.bloc.dart';
import 'package:client_app/src/features/auth/change_password.screen.dart';
import 'package:client_app/src/features/auth/create_new_password.screen.dart';
import 'package:client_app/src/features/auth/forgot_password.screen.dart';
import 'package:client_app/src/features/auth/login.screen.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/auth/password_recovery.event.dart';
import 'package:client_app/src/features/auth/password_recovery.state.dart';
import 'package:client_app/src/features/auth/password_reset_success.screen.dart';
import 'package:client_app/src/features/auth/recovery_otp.screen.dart';
import 'package:client_app/src/features/auth/recovery_signal.entity.dart';
import 'package:client_app/src/features/auth/sign_up.screen.dart';
import 'package:client_app/src/features/auth/verify_account.screen.dart';
import 'package:client_app/src/features/booking/booking.bloc.dart';
import 'package:client_app/src/features/booking/bookings.screen.dart';
import 'package:client_app/src/features/booking/branch_detail.bloc.dart';
import 'package:client_app/src/features/booking/branch_detail.screen.dart';
import 'package:client_app/src/features/discovery/discovery.bloc.dart';
import 'package:client_app/src/features/discovery/discovery.screen.dart'
    as discovery_feed;
import 'package:client_app/src/features/onboarding/ai_showcase.screen.dart';
import 'package:client_app/src/features/onboarding/booking.screen.dart';
import 'package:client_app/src/features/onboarding/discovery.screen.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/onboarding/welcome.screen.dart';
import 'package:client_app/src/features/profile/favorites.screen.dart';
import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/profile.screen.dart';
import 'package:client_app/src/features/splash/splash.screen.dart';

class AppRouter {
  final SessionBloc session;
  final AuthBloc auth;
  final PasswordRecoveryBloc recovery;
  final AppPreferences preferences;
  final OnboardingConfigBloc onboardingConfig;
  final BookingBloc bookings;
  final BranchDetailBloc branchDetail;
  final ChangePasswordBloc passwordChange;
  final DiscoveryBloc discovery;
  final HistoryBloc history;
  final VoidCallback switchLocale;
  final ApiClient apiClient;

  late final GoRouter router;
  late final StreamSubscription<SessionState> _sessionSubscription;
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<PasswordRecoveryState> _recoverySubscription;

  AppRouter({
    required this.session,
    required this.auth,
    required this.recovery,
    required this.preferences,
    required this.onboardingConfig,
    required this.bookings,
    required this.branchDetail,
    required this.passwordChange,
    required this.discovery,
    required this.history,
    required this.switchLocale,
    required this.apiClient,
  }) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: _redirect,
      routes: _routes(),
    );
    _sessionSubscription = session.stream.listen(_onSessionChanged);
    _authSubscription = auth.stream.listen(_onAuthChanged);
    _recoverySubscription = recovery.stream.listen(_onRecoveryChanged);
  }

  void dispose() {
    _sessionSubscription.cancel();
    _authSubscription.cancel();
    _recoverySubscription.cancel();
    router.dispose();
  }

  void _onRecoveryChanged(PasswordRecoveryState state) {
    switch (state.signal) {
      case RecoverySignal.codeSent:
        router.push<void>(AppRoutes.authRecoveryOtp);
        recovery.add(RecoverySignalAcknowledged());
      case RecoverySignal.codeAccepted:
        router.push<void>(AppRoutes.authResetPassword);
        recovery.add(RecoverySignalAcknowledged());
      case RecoverySignal.passwordReset:
        router.push<void>(AppRoutes.authResetPasswordSuccess);
        recovery.add(RecoverySignalAcknowledged());
      case RecoverySignal.none:
        break;
    }
  }

  void _onSessionChanged(SessionState state) {
    router.refresh();
    switch (state.signal) {
      case SessionSignal.sessionExpired:
        router.go(AppRoutes.authEntry);
        session.add(SignalAcknowledged());
        apiClient.resetUnauthorizedSignal();
      case SessionSignal.authenticationRequired:
        router.push<void>(AppRoutes.authEntry);
        session.add(SignalAcknowledged());
        apiClient.resetUnauthorizedSignal();
      case SessionSignal.none:
        break;
    }
  }

  void _onAuthChanged(AuthState state) {
    switch (state.signal) {
      case AuthSignal.loginSucceeded:
        router.go(AppRoutes.discover);
        auth.add(AuthSignalAcknowledged());
      case AuthSignal.registrationSucceeded:
        router.push<void>(AppRoutes.authVerify, extra: state.client?.email ?? '');
        auth.add(AuthSignalAcknowledged());
      case AuthSignal.verificationSucceeded:
        router.go(AppRoutes.discover);
        auth.add(AuthSignalAcknowledged());
      case AuthSignal.none:
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

  void _skipForNow() => router.go(AppRoutes.discover);

  void _onBookNow() {
    if (!session.state.isAuthenticated) {
      session.add(RequireAuthentication());
    }
  }

  Future<void> _dismissForever() async {
    try {
      await preferences.setDontShowOnboarding(true);
    } finally {
      router.go(AppRoutes.discover);
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
          onLocaleToggle: switchLocale,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.loginSegment,
            builder: (context, state) => LoginScreen(
              auth: auth,
              onCreateAccount: () => router.push<void>(AppRoutes.authRegister),
              onForgotPassword: () {
                recovery.add(RecoveryRestarted());
                router.push<void>(AppRoutes.authForgotPassword);
              },
              onLocaleToggle: switchLocale,
            ),
          ),
          GoRoute(
            path: AppRoutes.registerSegment,
            builder: (context, state) => SignUpScreen(
              auth: auth,
              onLogInLink: () => router.push<void>(AppRoutes.authLogin),
              onLocaleToggle: switchLocale,
            ),
          ),
          GoRoute(
            path: AppRoutes.verifySegment,
            builder: (context, state) => VerifyAccountScreen(
              auth: auth,
              destination: state.extra as String? ?? '',
              onSkip: () => router.go(AppRoutes.discover),
              onLocaleToggle: switchLocale,
            ),
          ),
          GoRoute(
            path: AppRoutes.forgotPasswordSegment,
            builder: (context, state) => ForgotPasswordScreen(
              recovery: recovery,
              onReturnToLogIn: () => router.go(AppRoutes.authLogin),
              onLocaleToggle: switchLocale,
            ),
            routes: [
              GoRoute(
                path: AppRoutes.recoveryOtpSegment,
                builder: (context, state) => RecoveryOtpScreen(
                  recovery: recovery,
                  onLocaleToggle: switchLocale,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.resetPasswordSegment,
            builder: (context, state) => CreateNewPasswordScreen(
              recovery: recovery,
              onReenterCode: () => router.go(AppRoutes.authRecoveryOtp),
              onLocaleToggle: switchLocale,
            ),
            routes: [
              GoRoute(
                path: AppRoutes.resetPasswordSuccessSegment,
                builder: (context, state) => PasswordResetSuccessScreen(
                  onLogIn: () => router.go(AppRoutes.authLogin),
                ),
              ),
            ],
          ),
        ],
      ),
      // Legacy home route redirects to the shell (Discover tab)
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => AppRoutes.discover,
      ),
      // Main authenticated shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Discover
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => discovery_feed.DiscoveryScreen(
                  bloc: discovery,
                  onLocaleToggle: switchLocale,
                  onBookNow: _onBookNow,
                  onViewDetails: (branchId) => router.push<void>(
                    AppRoutes.branchDetail(branchId),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.branchDetailSegment,
                    builder: (context, state) => BranchDetailScreen(
                      bloc: branchDetail,
                      branchId:
                          state.pathParameters['branchId'] ?? '',
                      onLocaleToggle: switchLocale,
                      onViewBookings: () => router.go(AppRoutes.bookings),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 1: Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                builder: (context, state) => BookingsScreen(
                  bloc: bookings,
                  onLocaleToggle: switchLocale,
                ),
              ),
            ],
          ),
          // Tab 2: Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => ProfileScreen(
                  history: history,
                  clientName: session.state.client?.name,
                  onChangePassword: () =>
                      router.push<void>(AppRoutes.profilePassword),
                  onViewBookings: () => router.go(AppRoutes.bookings),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.profilePasswordSegment,
                    builder: (context, state) => ChangePasswordScreen(
                      passwordChange: passwordChange,
                      onLocaleToggle: switchLocale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: colors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: l10n.discoverTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.bookingsTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_outlined),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.favoritesActionLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profileActionLabel,
          ),
        ],
      ),
    );
  }
}