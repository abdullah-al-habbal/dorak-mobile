import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const String _tokenKey = 'dorak_client_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> read() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  @override
  Future<void> write(String token) => _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
