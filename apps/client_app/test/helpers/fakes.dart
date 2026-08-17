import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/session/auth_coordination.entity.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';

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
  VoidCallback switchLocale = _noSwitchLocale,
}) {
  return AppRouter(
    session: session,
    auth: auth,
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

  int sendVerificationCalls = 0;
  String? verifiedCode;

  @override
  Future<String> refreshToken() async {
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
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {}
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
