import 'package:dio/dio.dart';

import 'package:core/src/network/endpoints/auth.endpoints.dart';

class AuthInterceptor extends Interceptor {
  static const String _socialPrefix = '/client/social/';

  static const Set<String> _authLifecyclePaths = {
    AuthEndpoints.login,
    AuthEndpoints.register,
    AuthEndpoints.logout,
    AuthEndpoints.refreshToken,
    AuthEndpoints.forgotPassword,
    AuthEndpoints.resetPassword,
    AuthEndpoints.verifyEmail,
    AuthEndpoints.sendEmailVerification,
    AuthEndpoints.changePassword,
  };

  final Future<String?> Function() tokenProvider;
  final void Function() reportUnauthorized;

  AuthInterceptor({
    required this.tokenProvider,
    required this.reportUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final carriedBearer = (err.requestOptions.headers['Authorization'] as String?)
            ?.startsWith('Bearer ') ??
        false;
    final isAuthLifecycle = _authLifecyclePaths.contains(path) ||
        path.startsWith(_socialPrefix);

    if (carriedBearer &&
        !isAuthLifecycle &&
        (status == 401 || status == 403)) {
      reportUnauthorized();
    }

    handler.next(err);
  }
}
