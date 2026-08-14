import 'package:flutter/material.dart';
import 'package:client_app/src/features/home/home.screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void replaceWith(Widget screen) {
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  static void push(Widget screen) {
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  static void goHome() => replaceWith(const HomeScreen());

  static void pop<T>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }
}