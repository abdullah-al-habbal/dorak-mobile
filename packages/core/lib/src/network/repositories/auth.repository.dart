import 'package:core/src/network/api.client.dart';
import 'package:core/src/network/dto/auth_response.dto.dart';
import 'package:core/src/network/dto/token_response.dto.dart';
import 'package:core/src/network/endpoints/auth.endpoints.dart';

abstract class AuthRepository {
  Future<AuthResponseDto> login({required String email, required String password});

  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  });

  Future<void> logout();

  Future<String> refreshToken();

  Future<void> sendEmailVerification();

  Future<void> verifyEmail(String code);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });
}

class DioAuthRepository implements AuthRepository {
  final ApiClient _client;

  DioAuthRepository(this._client);

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      AuthEndpoints.login,
      data: {'email': email, 'password': password},
      parser: (json) => AuthResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) {
    return _client.post(
      AuthEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': ?phone,
      },
      parser: (json) => AuthResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<void> logout() {
    return _client.post<void>(
      AuthEndpoints.logout,
      parser: _discardBody,
    );
  }

  @override
  Future<String> refreshToken() async {
    final response = await _client.post(
      AuthEndpoints.refreshToken,
      parser: (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.token;
  }

  @override
  Future<void> sendEmailVerification() {
    return _client.post<void>(
      AuthEndpoints.sendEmailVerification,
      parser: _discardBody,
    );
  }

  @override
  Future<void> verifyEmail(String code) {
    return _client.post<void>(
      AuthEndpoints.verifyEmail,
      data: {'code': code},
      parser: _discardBody,
    );
  }

  @override
  Future<void> forgotPassword(String email) {
    return _client.post<void>(
      AuthEndpoints.forgotPassword,
      data: {'email': email},
      parser: _discardBody,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) {
    return _client.post<void>(
      AuthEndpoints.resetPassword,
      data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      parser: _discardBody,
    );
  }

  static void _discardBody(dynamic _) {}
}
