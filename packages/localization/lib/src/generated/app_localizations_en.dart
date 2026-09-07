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

  @override
  String get actionRetry => 'Try again';

  @override
  String get errorTitleGeneric => 'Something went wrong';

  @override
  String get errorTitleOffline => 'You\'re offline';

  @override
  String get emptyTitleGeneric => 'Nothing here yet';

  @override
  String get emptyMessageGeneric => 'There\'s nothing to show right now.';

  @override
  String get recoveryEmailTitle => 'Forgot Password?';

  @override
  String get recoveryEmailSubtitle =>
      'Enter the email on your account and we\'ll send you a 6-digit reset code.';

  @override
  String get recoveryEmailLabel => 'Email';

  @override
  String get recoverySendCodeButton => 'Send Code';

  @override
  String get recoveryReturnToLogIn => 'Return to Log In';

  @override
  String get recoveryOtpTitle => 'Enter Reset Code';

  @override
  String recoveryOtpSubtitle(String email) {
    return 'If $email is registered, we\'ve sent it a 6-digit code. It expires in 10 minutes.';
  }

  @override
  String get recoveryOtpContinueButton => 'Continue';

  @override
  String get recoveryOtpIncomplete => 'Enter all 6 digits';

  @override
  String get recoveryResend => 'Resend Code';

  @override
  String recoveryResendDisabled(int seconds) {
    return 'Resend Code (${seconds}s)';
  }

  @override
  String get recoveryDidNotReceive => 'Didn\'t receive the code?';

  @override
  String get recoveryNewPasswordTitle => 'Create New Password';

  @override
  String get recoveryNewPasswordSubtitle =>
      'Choose a new password for your account.';

  @override
  String get recoveryNewPasswordLabel => 'New Password';

  @override
  String get recoveryConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get recoveryResetButton => 'Reset Password';

  @override
  String get recoveryCodeRejected => 'That code is invalid or has expired.';

  @override
  String get recoveryReenterCode => 'Re-enter code';

  @override
  String get passwordResetSuccessTitle => 'Password Updated';

  @override
  String get passwordResetSuccessMessage =>
      'Your password has been changed. You can now log in with your new password.';

  @override
  String get onboardingConfigUnavailable =>
      'Couldn\'t load the latest artwork.';

  @override
  String get bookingsTitle => 'No bookings yet';

  @override
  String get bookingsSubtitle =>
      'Your upcoming and past bookings will appear here.';

  @override
  String get bookingsActionLabel => 'Discover';

  @override
  String get favoritesTitle => 'No favorites yet';

  @override
  String get favoritesSubtitle =>
      'Tap the heart on a salon or barber to save it here.';

  @override
  String get favoritesActionLabel => 'Discover';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle =>
      'Your account and preferences will appear here.';

  @override
  String get profileActionLabel => 'Discover';

  @override
  String get locationRequiredTitle => 'Location Required';

  @override
  String get locationRequiredMessage =>
      'Enable location access to discover nearby branches.';

  @override
  String get enableLocationAction => 'Enable Location';

  @override
  String get availableNow => 'Available Now';

  @override
  String get price => 'Price';

  @override
  String get rating => 'Rating';

  @override
  String get distance => 'Distance';

  @override
  String get viewDetails => 'View Details';

  @override
  String get bookNow => 'Book Now';

  @override
  String get discoverUniverseMen => 'Men';

  @override
  String get discoverUniverseWomen => 'Women';

  @override
  String get discoverRankedByDistance => 'Ranked by distance';

  @override
  String discoverDistanceLabel(double km) {
    return '$km km';
  }

  @override
  String get discoverStaleLabel => 'Showing saved results';

  @override
  String discoverRankBadge(int rank) {
    return '#$rank';
  }

  @override
  String get discoverTabLabel => 'Discover';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordSubtitle =>
      'Enter your current password, then choose a new one.';

  @override
  String get changePasswordCurrentLabel => 'Current Password';

  @override
  String get changePasswordNewLabel => 'New Password';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePasswordSubmit => 'Update Password';

  @override
  String get changePasswordSuccessTitle => 'Password Updated';

  @override
  String get changePasswordSuccessMessage => 'Your password has been changed.';

  @override
  String get changePasswordDone => 'Done';

  @override
  String get bookingsTabLabel => 'Bookings';

  @override
  String get bookingFilterUpcoming => 'Upcoming';

  @override
  String get bookingFilterPast => 'Past';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusCanceled => 'Canceled';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String bookingWithBarber(String name) {
    return 'with $name';
  }

  @override
  String bookingChairLabel(String label) {
    return 'Chair $label';
  }

  @override
  String get bookingCancelAction => 'Cancel Booking';

  @override
  String get bookingCancelConfirmTitle => 'Cancel this booking?';

  @override
  String get bookingCancelConfirmMessage =>
      'Your slot will be freed. You can book again anytime.';

  @override
  String get bookingCancelConfirm => 'Yes, Cancel';

  @override
  String discoverCompatibilityBadge(int percent) {
    return '$percent%';
  }
}
