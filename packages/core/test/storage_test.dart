import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedAppPreferences', () {
    test('dontShowOnboarding defaults to false on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedAppPreferences.create();

      expect(prefs.dontShowOnboarding, isFalse);
    });

    test('the flag round-trips and is readable synchronously', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedAppPreferences.create();

      await prefs.setDontShowOnboarding(true);

      // Synchronous read matters: the launch gate branches on it without an
      // await.
      expect(prefs.dontShowOnboarding, isTrue);
    });

    test('a previously persisted flag is picked up at startup', () async {
      SharedPreferences.setMockInitialValues({'dont_show_onboarding': true});
      final prefs = await SharedAppPreferences.create();

      expect(prefs.dontShowOnboarding, isTrue);
    });
  });

  group('TokenStorage contract', () {
    test('read returns null once cleared', () async {
      final storage = InMemoryTokenStorage('a-token');

      expect(await storage.read(), 'a-token');
      await storage.clear();
      expect(await storage.read(), isNull);
    });
  });
}
