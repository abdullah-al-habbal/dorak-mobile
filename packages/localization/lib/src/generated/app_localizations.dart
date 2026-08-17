import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  /// App brand name displayed on splash screen
  ///
  /// In en, this message translates to:
  /// **'Dorak'**
  String get splashTitle;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Welcome screen headline
  ///
  /// In en, this message translates to:
  /// **'Your grooming experience, reimagined.'**
  String get onboardingWelcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover top-tier professionals, book with ease, and personalize your style journey.'**
  String get onboardingWelcomeSubtitle;

  /// Primary CTA on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Skip bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Skip Onboarding?'**
  String get skipOnboardingQuestion;

  /// Skip bottom sheet primary action
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Skip bottom sheet secondary action
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// Skip bottom sheet cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Discovery screen headline
  ///
  /// In en, this message translates to:
  /// **'Find the perfect fit.'**
  String get discoveryTitle;

  /// Discovery screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Explore nearby shops, expert barbers, and premium services tailored to your needs.'**
  String get discoverySubtitle;

  /// Discovery screen primary CTA
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Discovery card 1 label
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get discoveryCardShops;

  /// Discovery card 2 label
  ///
  /// In en, this message translates to:
  /// **'Barbers'**
  String get discoveryCardBarbers;

  /// Discovery card 3 label
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get discoveryCardServices;

  /// Discovery screen back action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get previous;

  /// Locale toggle label to switch to Arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get localeArabic;

  /// Locale toggle label to switch to English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Booking innovation screen headline
  ///
  /// In en, this message translates to:
  /// **'Book when it works for you.'**
  String get bookingTitle;

  /// Booking innovation screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose your service, professional, and time — then book in just a few taps.'**
  String get bookingSubtitle;

  /// Booking demo service card label
  ///
  /// In en, this message translates to:
  /// **'Premium Fade'**
  String get bookingServiceLabel;

  /// Booking demo service card meta
  ///
  /// In en, this message translates to:
  /// **'45 min • \$65'**
  String get bookingServiceMeta;

  /// Booking demo professional name
  ///
  /// In en, this message translates to:
  /// **'Marcus T.'**
  String get bookingProfessionalLabel;

  /// Booking demo professional rating
  ///
  /// In en, this message translates to:
  /// **'4.9'**
  String get bookingProfessionalRating;

  /// Booking demo date label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get bookingDateLabel;

  /// Booking demo time label
  ///
  /// In en, this message translates to:
  /// **'2:30 PM'**
  String get bookingTimeLabel;

  /// AI feature showcase screen headline
  ///
  /// In en, this message translates to:
  /// **'Discover styles made for you.'**
  String get aiTitle;

  /// AI feature showcase screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Get personalized style recommendations based on your preferences and, if you choose, your face profile.'**
  String get aiSubtitle;

  /// AI demo match card label
  ///
  /// In en, this message translates to:
  /// **'98% Match'**
  String get aiMatchLabel;

  /// AI demo recommendation card label
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get aiRecommendedLabel;

  /// AI demo recommended style one
  ///
  /// In en, this message translates to:
  /// **'Premium Fade'**
  String get aiStyleFade;

  /// AI demo recommended style two
  ///
  /// In en, this message translates to:
  /// **'Textured Crop'**
  String get aiStyleCrop;

  /// AI demo face shape chip label
  ///
  /// In en, this message translates to:
  /// **'Face Shape: Oval'**
  String get aiFaceShapeLabel;

  /// AI demo privacy note
  ///
  /// In en, this message translates to:
  /// **'Face analysis is entirely optional.'**
  String get aiPrivacyNote;

  /// Auth entry screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dorak'**
  String get authWelcomeTitle;

  /// Auth entry screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your personalized experience, or continue as a guest to explore.'**
  String get authSubtitle;

  /// Auth entry primary CTA
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogIn;

  /// Auth entry secondary CTA
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// Auth entry guest action
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authContinueAsGuest;

  /// Auth entry guest helper text
  ///
  /// In en, this message translates to:
  /// **'Explore Dorak without creating an account.'**
  String get authGuestHint;

  /// Back button tooltip
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// Login email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Login password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Login forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// Login submit button
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// Login footer prompt before the sign-up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginSignUpPrompt;

  /// Login footer sign-up link
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccountLink;

  /// Login 401 error message
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginErrorInvalidCredentials;

  /// Sign-up screen title
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// Sign-up screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Join Dorak for personalized grooming and effortless booking.'**
  String get signUpSubtitle;

  /// Sign-up full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signUpFullNameLabel;

  /// Sign-up email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signUpEmailLabel;

  /// Sign-up password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signUpPasswordLabel;

  /// Sign-up confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signUpConfirmPasswordLabel;

  /// Sign-up password requirement hint
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signUpPasswordHint;

  /// Sign-up submit button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpButton;

  /// Sign-up footer prompt before the login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signUpAlreadyHaveAccount;

  /// Sign-up footer login link
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get signUpLogInLink;

  /// Verify account screen title
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyTitle;

  /// Verify account subtitle with the masked destination
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {email}'**
  String verifySubtitle(String email);

  /// Verify account submit button
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyButton;

  /// Verify account resend prompt
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get verifyDidNotReceive;

  /// Verify account resend action
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get verifyResend;

  /// Verify account resend action during cooldown
  ///
  /// In en, this message translates to:
  /// **'Resend Code ({seconds}s)'**
  String verifyResendDisabled(int seconds);

  /// Verify account invalid code error
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get verifyErrorInvalid;

  /// Verify account skip action
  ///
  /// In en, this message translates to:
  /// **'Verify later'**
  String get verifySkip;

  /// Form validation error for an empty required field
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Form validation error for a malformed email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get fieldInvalidEmail;

  /// Form validation error for a short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get fieldPasswordTooShort;

  /// Form validation error when confirm password differs
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get fieldPasswordMismatch;

  /// Transport failure message
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errorNetwork;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Retry action label for failed states
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// Fallback error state title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitleGeneric;

  /// Offline state title
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get errorTitleOffline;

  /// Fallback empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitleGeneric;

  /// Fallback empty state message
  ///
  /// In en, this message translates to:
  /// **'There\'s nothing to show right now.'**
  String get emptyMessageGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
