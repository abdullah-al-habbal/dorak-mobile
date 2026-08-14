import 'package:core/src/network/api.client.dart';
import 'package:core/src/network/dto/auth_response.dto.dart';
import 'package:core/src/network/endpoints/auth.endpoints.dart';

abstract class AuthRepository {
  Future<AuthResponseDto> login({required String email, required String password});

  Future<AuthResponseDto> register({
    required String name,
    required String email,
    required String password,
    String? phone,
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
    String? phone,
  }) {
    return _client.post(
      AuthEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      },
      parser: (json) => AuthResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
