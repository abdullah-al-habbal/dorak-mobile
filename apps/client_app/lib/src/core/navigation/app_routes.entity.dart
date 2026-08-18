class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';

  static const String onboarding = '/onboarding';
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingDiscovery = '/onboarding/discovery';
  static const String onboardingBooking = '/onboarding/booking';
  static const String onboardingAiStyle = '/onboarding/ai-style';

  static const String authEntry = '/auth';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authVerify = '/auth/verify';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authRecoveryOtp = '/auth/forgot-password/otp';
  static const String authResetPassword = '/auth/reset-password';
  static const String authResetPasswordSuccess = '/auth/reset-password/success';

  static const String home = '/home';

  static const String welcomeSegment = 'welcome';
  static const String discoverySegment = 'discovery';
  static const String bookingSegment = 'booking';
  static const String aiStyleSegment = 'ai-style';
  static const String loginSegment = 'login';
  static const String registerSegment = 'register';
  static const String verifySegment = 'verify';
  static const String forgotPasswordSegment = 'forgot-password';
  static const String recoveryOtpSegment = 'otp';
  static const String resetPasswordSegment = 'reset-password';
  static const String resetPasswordSuccessSegment = 'success';
}
