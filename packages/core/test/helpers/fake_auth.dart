import 'package:core/core.dart';
import 'package:dio/dio.dart';

class InMemoryTokenStorage implements TokenStorage {
  String? token;
  int writeCount = 0;
  int clearCount = 0;

  Object? readError;

  InMemoryTokenStorage([this.token]);

  @override
  Future<String?> read() async {
    final error = readError;
    if (error != null) throw error;
    return token;
  }

  @override
  Future<void> write(String value) async {
    token = value;
    writeCount++;
  }

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
  static const ClientDto defaultClient = ClientDto(
    id: 'uuid-1',
    name: 'Sara',
    email: 'sara@example.com',
    phone: null,
  );

  Object? refreshTokenError;
  String refreshedToken = 'rotated-token';

  Object? loginError;
  Object? registerError;
  Object? verifyEmailError;
  Object? sendVerificationError;
  Object? logoutError;

  AuthResponseDto loginResponse = const AuthResponseDto(
    token: 'login-token',
    client: defaultClient,
  );
  AuthResponseDto registerResponse = const AuthResponseDto(
    token: 'register-token',
    client: defaultClient,
  );

  int refreshTokenCalls = 0;
  int sendVerificationCalls = 0;
  int logoutCalls = 0;
  String? verifiedCode;
  Map<String, Object?>? registeredPayload;

  @override
  Future<String> refreshToken() async {
    refreshTokenCalls++;
    final error = refreshTokenError;
    if (error != null) throw error;
    return refreshedToken;
  }

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final error = loginError;
    if (error != null) throw error;
    return loginResponse;
  }

  @override
  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    registeredPayload = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
    };
    final error = registerError;
    if (error != null) throw error;
    return registerResponse;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    final error = logoutError;
    if (error != null) throw error;
  }

  @override
  Future<void> sendEmailVerification() async {
    sendVerificationCalls++;
    final error = sendVerificationError;
    if (error != null) throw error;
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
