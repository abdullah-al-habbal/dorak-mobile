import 'package:client_app/src/core/navigation/app_routes.entity.dart';

class AppGate {
  AppGate._();

  static String resolve({
    required bool isAuthenticated,
    required bool dontShowOnboarding,
  }) {
    if (isAuthenticated) return AppRoutes.home;
    if (dontShowOnboarding) return AppRoutes.home;
    return AppRoutes.authEntry;
  }
}
