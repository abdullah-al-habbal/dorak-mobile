import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/session/auth_coordination.entity.dart';
import 'package:client_app/src/features/auth/password_recovery.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';

// todo: read this file, and I think is better to make a fakes folder and then move each block/class into a file for better code.
Widget routerHarness(AppRouter appRouter) {
  return MaterialApp.router(
    routerConfig: appRouter.router,
    debugShowCheckedModeBanner: false,
    theme: DorakTheme.forLocale(const Locale('en'), Brightness.light),
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

AppRouter buildRouter({
  required SessionBloc session,
  required AuthBloc auth,
  required AppPreferences preferences,
  required ApiClient apiClient,
  PasswordRecoveryBloc? recovery,
  AuthRepository? recoveryRepository,
  VoidCallback switchLocale = _noSwitchLocale,
}) {
  return AppRouter(
    session: session,
    auth: auth,
    recovery: recovery ??
        PasswordRecoveryBloc(recoveryRepository ?? FakeAuthRepository()),
    preferences: preferences,
    onboardingConfig: fakeOnboardingConfig(),
    switchLocale: switchLocale,
    apiClient: apiClient,
  );
}

({AuthBloc auth, SessionBloc session, StreamSubscription<AuthState> coordinator})
    sessionPair(
  AuthRepository repository,
  TokenStorage storage,
) {
  final auth = AuthBloc(repository, storage);
  final session = SessionBloc(repository, storage);
  final coordinator = auth.stream.listen(
    (authState) => coordinateAuthSuccess(authState, session),
  );
  return (auth: auth, session: session, coordinator: coordinator);
}

void _noSwitchLocale() {}

ApiClient fakeApiClient() {
  return ApiClient(
    baseUrl: 'https://api.example.com',
    tokenProvider: () async => null,
    enableLogging: false,
  );
}

class InMemoryTokenStorage implements TokenStorage {
  String? token;
  int clearCount = 0;

  InMemoryTokenStorage([this.token]);

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async {
    token = null;
    clearCount++;
  }
}

class InMemoryAppPreferences implements AppPreferences {
  @override
  bool dontShowOnboarding;

  InMemoryAppPreferences({this.dontShowOnboarding = false});

  @override
  Future<void> setDontShowOnboarding(bool value) async {
    dontShowOnboarding = value;
  }
}

class FakeAuthRepository implements AuthRepository {
  static const ClientDto _client = ClientDto(
    id: 'uuid-1',
    name: 'Sara',
    email: 'sara@example.com',
    phone: null,
  );

  Object? refreshTokenError;
  Object? loginError;
  Object? registerError;
  Object? verifyEmailError;
  Object? forgotPasswordError;
  Object? resetPasswordError;

  String? forgotPasswordEmail;
  int forgotPasswordCalls = 0;
  Map<String, String>? resetPasswordPayload;

  /// Counts session re-probes. One `RestoreRequested` with a stored token calls
  /// `refreshToken` exactly once, so this is how a test observes a restore
  /// without depending on frame timing.
  int refreshTokenCalls = 0;

  /// When set, `refreshToken` blocks on it. Lets a test hold the session in
  /// `AuthStatus.unknown` / `isLoading`. Null by default, so every other test
  /// keeps resolving in a microtask.
  Completer<void>? refreshTokenGate;

  int sendVerificationCalls = 0;
  String? verifiedCode;

  @override
  Future<String> refreshToken() async {
    refreshTokenCalls++;
    final gate = refreshTokenGate;
    if (gate != null) await gate.future;
    final error = refreshTokenError;
    if (error != null) throw error;
    return 'rotated-token';
  }

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final error = loginError;
    if (error != null) throw error;
    return const AuthResponseDto(token: 'login-token', client: _client);
  }

  @override
  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final error = registerError;
    if (error != null) throw error;
    return const AuthResponseDto(token: 'register-token', client: _client);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendEmailVerification() async {
    sendVerificationCalls++;
  }

  @override
  Future<void> verifyEmail(String code) async {
    verifiedCode = code;
    final error = verifyEmailError;
    if (error != null) throw error;
  }

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordEmail = email;
    forgotPasswordCalls++;
    final error = forgotPasswordError;
    if (error != null) throw error;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    resetPasswordPayload = {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final error = resetPasswordError;
    if (error != null) throw error;
  }
}

class FakeOnboardingConfigRepository implements OnboardingConfigRepository {
  @override
  Future<OnboardingConfigDto> fetchOnboardingConfig({String? locale}) async {
    return const OnboardingConfigDto(
      heroImageUrl: '',
      season: null,
      locale: 'en',
    );
  }
}

OnboardingConfigBloc fakeOnboardingConfig() {
  return OnboardingConfigBloc(FakeOnboardingConfigRepository());
}

ApiException unauthorized() => const ApiException(
      statusCode: 401,
      code: 'UNKNOWN',
      message: 'Unauthenticated.',
    );

NetworkException offline() => const NetworkException(
      type: DioExceptionType.connectionError,
      retryable: true,
      message: 'Connection refused',
    );
