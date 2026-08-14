import 'package:flutter/widgets.dart';
import 'package:core/core.dart';

class OnboardingConfigController extends ChangeNotifier {
  OnboardingConfigController(this._repository, this._localeResolver);

  final OnboardingConfigRepository _repository;
  final Locale Function() _localeResolver;

  OnboardingConfigDto? _config;
  String? _localeCode;
  bool _loading = false;
  Object? _error;
  bool _disposed = false;

  OnboardingConfigDto? get config => _config;
  String? get heroImageUrl => _config?.heroImageUrl;
  bool get isLoading => _loading;
  Object? get error => _error;

  Future<void> load() async {
    final locale = _localeResolver().languageCode;
    if (locale == _localeCode) return;
    _localeCode = locale;
    await fetch();
  }

  Future<void> fetch() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      _config = await _repository.fetchOnboardingConfig(locale: _localeCode);
    } catch (e) {
      _error = e;
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
