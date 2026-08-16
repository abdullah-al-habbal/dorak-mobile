import 'package:localization/localization.dart';

class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const int minPasswordLength = 8;

  static String? required(String? value, AppLocalizations l10n) {
    if ((value ?? '').trim().isEmpty) return l10n.fieldRequired;
    return null;
  }

  static String? email(String? value, AppLocalizations l10n) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return l10n.fieldRequired;
    if (!_emailPattern.hasMatch(trimmed)) return l10n.fieldInvalidEmail;
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    final text = value ?? '';
    if (text.isEmpty) return l10n.fieldRequired;
    if (text.length < minPasswordLength) return l10n.fieldPasswordTooShort;
    return null;
  }

  static String? passwordConfirmation(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    final text = value ?? '';
    if (text.isEmpty) return l10n.fieldRequired;
    if (text != password) return l10n.fieldPasswordMismatch;
    return null;
  }
}
