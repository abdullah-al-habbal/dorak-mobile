import 'package:shared_preferences/shared_preferences.dart';

abstract class AppPreferences {
  bool get dontShowOnboarding;

  Future<void> setDontShowOnboarding(bool value);
}

class SharedAppPreferences implements AppPreferences {
  static const String _dontShowOnboardingKey = 'dont_show_onboarding';

  final SharedPreferences _prefs;

  const SharedAppPreferences(this._prefs);

  static Future<SharedAppPreferences> create() async {
    return SharedAppPreferences(await SharedPreferences.getInstance());
  }

  @override
  bool get dontShowOnboarding =>
      _prefs.getBool(_dontShowOnboardingKey) ?? false;

  @override
  Future<void> setDontShowOnboarding(bool value) =>
      _prefs.setBool(_dontShowOnboardingKey, value);
}
