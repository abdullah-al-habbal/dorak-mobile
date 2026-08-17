import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/design_system.dart';

void main() {
  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DorakTheme.light,
        home: Scaffold(
          body: LocaleSwitcher(label: 'العربية', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('tapping fires onPressed', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DorakTheme.light,
        home: Scaffold(
          body: LocaleSwitcher(label: 'English', onPressed: () => taps++),
        ),
      ),
    );

    await tester.tap(find.text('English'));
    expect(taps, 1);
  });
}