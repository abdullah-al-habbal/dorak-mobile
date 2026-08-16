import 'package:core/core.dart';
import 'package:localization/localization.dart';

class AuthError {
  final String message;
  final Map<String, List<String>> fieldErrors;

  const AuthError({required this.message, this.fieldErrors = const {}});

  factory AuthError.from(
    Object error,
    AppLocalizations l10n, {
    String? unauthorizedMessage,
    String? unprocessableMessage,
  }) {
    if (error is ValidationException) {
      return AuthError(
        message: unprocessableMessage ?? l10n.errorGeneric,
        fieldErrors: error.errors,
      );
    }
    if (error is NetworkException) {
      return AuthError(message: l10n.errorNetwork);
    }
    if (error is ApiException) {
      if (error.isUnauthorized || error.isForbidden) {
        return AuthError(message: unauthorizedMessage ?? l10n.errorGeneric);
      }
      if (error.statusCode == 422) {
        return AuthError(message: unprocessableMessage ?? l10n.errorGeneric);
      }
      return AuthError(message: l10n.errorGeneric);
    }
    return AuthError(message: l10n.errorGeneric);
  }

  List<String>? errorsFor(String field) => fieldErrors[field];

  String? firstErrorFor(String field) {
    final messages = fieldErrors[field];
    if (messages == null || messages.isEmpty) return null;
    return messages.first;
  }
}
