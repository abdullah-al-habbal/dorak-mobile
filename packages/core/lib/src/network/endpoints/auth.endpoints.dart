class AuthEndpoints {
  AuthEndpoints._();

  static const String login = '/client/login';
  static const String register = '/client/register';
  static const String logout = '/client/logout';
  static const String refreshToken = '/client/refresh-token';
  static const String forgotPassword = '/client/forgot-password';
  static const String resetPassword = '/client/reset-password';
  static const String verifyEmail = '/client/email/verify';
  static const String sendEmailVerification = '/client/email/verify/send';
  static const String changePassword = '/client/password';

  static String socialLogin(String provider) => '/client/social/$provider';
}
