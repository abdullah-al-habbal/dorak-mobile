// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTitle => 'Dorak';

  @override
  String get skip => 'Skip';

  @override
  String get onboardingWelcomeTitle => 'Your grooming experience, reimagined.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Discover top-tier professionals, book with ease, and personalize your style journey.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get skipOnboardingQuestion => 'Skip Onboarding?';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get cancel => 'Cancel';

  @override
  String get discoveryTitle => 'Find the perfect fit.';

  @override
  String get discoverySubtitle =>
      'Explore nearby shops, expert barbers, and premium services tailored to your needs.';

  @override
  String get next => 'Next';

  @override
  String get discoveryCardShops => 'Shops';

  @override
  String get discoveryCardBarbers => 'Barbers';

  @override
  String get discoveryCardServices => 'Services';

  @override
  String get previous => 'Back';

  @override
  String get localeArabic => 'العربية';

  @override
  String get localeEnglish => 'English';

  @override
  String get homeTitle => 'Home';

  @override
  String get bookingTitle => 'Book when it works for you.';

  @override
  String get bookingSubtitle =>
      'Choose your service, professional, and time — then book in just a few taps.';

  @override
  String get bookingServiceLabel => 'Premium Fade';

  @override
  String get bookingServiceMeta => '45 min • \$65';

  @override
  String get bookingProfessionalLabel => 'Marcus T.';

  @override
  String get bookingProfessionalRating => '4.9';

  @override
  String get bookingDateLabel => 'Tomorrow';

  @override
  String get bookingTimeLabel => '2:30 PM';

  @override
  String get aiTitle => 'Discover styles made for you.';

  @override
  String get aiSubtitle =>
      'Get personalized style recommendations based on your preferences and, if you choose, your face profile.';

  @override
  String get aiMatchLabel => '98% Match';

  @override
  String get aiRecommendedLabel => 'Recommended';

  @override
  String get aiStyleFade => 'Premium Fade';

  @override
  String get aiStyleCrop => 'Textured Crop';

  @override
  String get aiFaceShapeLabel => 'Face Shape: Oval';

  @override
  String get aiPrivacyNote => 'Face analysis is entirely optional.';

  @override
  String get authWelcomeTitle => 'Welcome to Dorak';

  @override
  String get authSubtitle =>
      'Sign in to access your personalized experience, or continue as a guest to explore.';

  @override
  String get authLogIn => 'Log In';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authContinueAsGuest => 'Continue as Guest';

  @override
  String get authGuestHint => 'Explore Dorak without creating an account.';

  @override
  String get back => 'Back';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginSignUpPrompt => 'Don\'t have an account?';

  @override
  String get loginCreateAccountLink => 'Create Account';

  @override
  String get loginErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle =>
      'Join Dorak for personalized grooming and effortless booking.';

  @override
  String get signUpFullNameLabel => 'Full Name';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpPasswordLabel => 'Password';

  @override
  String get signUpConfirmPasswordLabel => 'Confirm Password';

  @override
  String get signUpPasswordHint => 'At least 8 characters';

  @override
  String get signUpButton => 'Create Account';

  @override
  String get signUpAlreadyHaveAccount => 'Already have an account?';

  @override
  String get signUpLogInLink => 'Log In';

  @override
  String get verifyTitle => 'Verify Your Account';

  @override
  String verifySubtitle(String email) {
    return 'Enter the 6-digit code we sent to $email';
  }

  @override
  String get verifyButton => 'Verify & Continue';

  @override
  String get verifyDidNotReceive => 'Didn\'t receive the code?';

  @override
  String get verifyResend => 'Resend Code';

  @override
  String verifyResendDisabled(int seconds) {
    return 'Resend Code (${seconds}s)';
  }

  @override
  String get verifyErrorInvalid => 'Invalid code. Please try again.';

  @override
  String get verifySkip => 'Verify later';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get fieldInvalidEmail => 'Please enter a valid email address';

  @override
  String get fieldPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get fieldPasswordMismatch => 'Passwords do not match';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
