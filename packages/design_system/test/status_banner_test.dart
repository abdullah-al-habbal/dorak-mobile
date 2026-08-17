import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/design_system.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: DorakTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders the message', (tester) async {
    await tester.pumpWidget(
      _harness(const StatusBanner(message: 'Something went wrong')),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('defaults to the error color', (tester) async {
    await tester.pumpWidget(
      _harness(const StatusBanner(message: 'Something went wrong')),
    );

    final text = tester.widget<Text>(find.text('Something went wrong'));
    final expected = DorakColors.light.error;

    expect(text.style?.color, expected);
  });

  testWidgets('action appears and fires only when both fields are given',
      (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _harness(
        StatusBanner(
          message: 'Try again?',
          actionLabel: 'Retry',
          onAction: () => taps++,
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(taps, 1);

    await tester.pumpWidget(
      _harness(const StatusBanner(message: 'Try again?')),
    );
    expect(find.text('Retry'), findsNothing);
  });
}