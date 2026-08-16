// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get splashTitle => 'Dorak';

  @override
  String get skip => 'تخطي';

  @override
  String get onboardingWelcomeTitle => 'تجربة العناية بك، من جديد.';

  @override
  String get onboardingWelcomeSubtitle =>
      'اكتشف نخبة المحترفين، واحجز بسهولة، وخصص رحلتك الأنيقة.';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get skipOnboardingQuestion => 'تخطي مرحلة التعريف؟';

  @override
  String get skipForNow => 'تخطَّ الآن';

  @override
  String get dontShowAgain => 'لا تظهر مجددًا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get discoveryTitle => 'اعثر على الأنسب لك.';

  @override
  String get discoverySubtitle =>
      'استكشف المتاجر القريبة وأفضل الحلاقين والخدمات المتميزة المصممة لاحتياجاتك.';

  @override
  String get next => 'التالي';

  @override
  String get discoveryCardShops => 'المتاجر';

  @override
  String get discoveryCardBarbers => 'الحلاقون';

  @override
  String get discoveryCardServices => 'الخدمات';

  @override
  String get previous => 'رجوع';

  @override
  String get localeArabic => 'العربية';

  @override
  String get localeEnglish => 'English';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get bookingTitle => 'احجز متى يناسبك.';

  @override
  String get bookingSubtitle =>
      'اختر خدمتك ومحترفك والوقت المناسب — ثم احجز في بضع لمسات.';

  @override
  String get bookingServiceLabel => 'بريميوم فايد';

  @override
  String get bookingServiceMeta => '45 دقيقة • \$65';

  @override
  String get bookingProfessionalLabel => 'ماركوس تي.';

  @override
  String get bookingProfessionalRating => '4.9';

  @override
  String get bookingDateLabel => 'غدًا';

  @override
  String get bookingTimeLabel => '2:30 مساءً';

  @override
  String get aiTitle => 'اكتشف تسريحات صُممت من أجلك.';

  @override
  String get aiSubtitle =>
      'احصل على توصيات شخصية مبنية على تفضيلاتك، وإذا أردت، على ملامح وجهك.';

  @override
  String get aiMatchLabel => 'تطابق 98٪';

  @override
  String get aiRecommendedLabel => 'موصى به';

  @override
  String get aiStyleFade => 'بريميوم فايد';

  @override
  String get aiStyleCrop => 'قصّة تكستشر كروب';

  @override
  String get aiFaceShapeLabel => 'شكل الوجه: بيضاوي';

  @override
  String get aiPrivacyNote => 'تحليل الوجه اختياري بالكامل.';

  @override
  String get authWelcomeTitle => 'مرحباً بك في دوراك';

  @override
  String get authSubtitle =>
      'سجّل الدخول للوصول إلى تجربتك المخصصة، أو تابع كزائر للاستكشاف.';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authContinueAsGuest => 'المتابعة كزائر';

  @override
  String get authGuestHint => 'استكشف دوراك دون إنشاء حساب.';

  @override
  String get back => 'رجوع';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول إلى حسابك';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginSignUpPrompt => 'ليس لديك حساب؟';

  @override
  String get loginCreateAccountLink => 'إنشاء حساب';

  @override
  String get loginErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpSubtitle =>
      'انضم إلى دوراك للحصول على عناية شخصية وحجز سهل.';

  @override
  String get signUpFullNameLabel => 'الاسم الكامل';

  @override
  String get signUpEmailLabel => 'البريد الإلكتروني';

  @override
  String get signUpPasswordLabel => 'كلمة المرور';

  @override
  String get signUpConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get signUpPasswordHint => 'على الأقل 8 أحرف';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get signUpAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signUpLogInLink => 'تسجيل الدخول';

  @override
  String get verifyTitle => 'تحقق من حسابك';

  @override
  String verifySubtitle(String email) {
    return 'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إلى $email';
  }

  @override
  String get verifyButton => 'تحقق واستمر';

  @override
  String get verifyDidNotReceive => 'لم تستلم الرمز؟';

  @override
  String get verifyResend => 'إعادة إرسال الرمز';

  @override
  String verifyResendDisabled(int seconds) {
    return 'إعادة إرسال الرمز ($secondsث)';
  }

  @override
  String get verifyErrorInvalid => 'رمز غير صحيح. يرجى المحاولة مرة أخرى.';

  @override
  String get verifySkip => 'التحقق لاحقاً';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get fieldInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get fieldPasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get fieldPasswordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get errorNetwork => 'لا يوجد اتصال. تحقق من شبكتك وحاول مرة أخرى.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';
}
