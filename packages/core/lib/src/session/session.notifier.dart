import 'package:flutter/widgets.dart';

import 'package:core/src/network/dto/client.dto.dart';
import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/exceptions/network.exception.dart';
import 'package:core/src/network/repositories/auth.repository.dart';
import 'package:core/src/session/auth_status.entity.dart';
import 'package:core/src/session/session_notice.entity.dart';
import 'package:core/src/storage/token.storage.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._repository, this._tokenStorage);

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.unknown;
  ClientDto? _client;
  bool _loading = false;
  Object? _error;
  bool _disposed = false;
  Future<void>? _restoration;
  SessionNotice _notice = SessionNotice.none;

  AuthStatus get status => _status;
  ClientDto? get client => _client;
  bool get isLoading => _loading;
  Object? get error => _error;
  bool get isAuthenticated => _status.isAuthenticated;
  SessionNotice get notice => _notice;

  Future<void> get ready => _restoration ??= restore();

  Future<void> restore() async {
    _loading = true;
    _error = null;
    _notice = SessionNotice.none;
    _notify();
    try {
      final stored = await _tokenStorage.read();
      if (stored == null) {
        _status = AuthStatus.guest;
        return;
      }

      try {
        final rotated = await _repository.refreshToken();
        if (rotated.isNotEmpty) {
          await _tokenStorage.write(rotated);
        }
        _status = AuthStatus.authenticated;
      } on NetworkException catch (e) {
        _error = e;
        _status = AuthStatus.authenticated;
      } on ApiException catch (e) {
        if (e.isUnauthorized || e.isForbidden) {
          await _tokenStorage.clear();
          _status = AuthStatus.guest;
        } else {
          _error = e;
          _status = AuthStatus.authenticated;
        }
      }
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> login({required String email, required String password}) {
    return _run(() async {
      final response = await _repository.login(email: email, password: password);
      await _acceptSession(response.token, response.client);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) {
    return _run(() async {
      final response = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );
      await _acceptSession(response.token, response.client);
    });
  }

  Future<void> sendVerificationCode() {
    return _run(_repository.sendEmailVerification);
  }

  Future<void> verifyEmail(String code) {
    return _run(() => _repository.verifyEmail(code));
  }

  Future<void> logout() async {
    _loading = true;
    _error = null;
    _notice = SessionNotice.none;
    _notify();
    try {
      await _repository.logout();
    } catch (e) {
      _error = e;
    } finally {
      await _tokenStorage.clear();
      _client = null;
      _status = AuthStatus.guest;
      _loading = false;
      _notify();
    }
  }

  Future<void> _acceptSession(String token, ClientDto client) async {
    if (token.isNotEmpty) {
      await _tokenStorage.write(token);
    }
    _client = client;
    _status = AuthStatus.authenticated;
  }

  Future<void> handleUnauthorized() async {
    if (_notice == SessionNotice.sessionExpired) return;
    _notice = SessionNotice.sessionExpired;
    try {
      await _tokenStorage.clear();
    } catch (e) {
      _error = e;
    } finally {
      _client = null;
      _status = AuthStatus.guest;
      _notify();
    }
  }

  void requireAuthentication() {
    _notice = SessionNotice.authenticationRequired;
    _notify();
  }

  void acknowledgeNotice() {
    if (_notice == SessionNotice.none) return;
    _notice = SessionNotice.none;
    _notify();
  }

  Future<void> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    _notice = SessionNotice.none;
    _notify();
    try {
      await action();
    } catch (e) {
      _error = e;
      rethrow;
    } finally {
      _loading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
