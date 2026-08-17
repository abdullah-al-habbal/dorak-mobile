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
  testWidgets('renders icon and title', (tester) async {
    await tester.pumpWidget(
      _harness(
        const StatusView(
          icon: Icons.inbox_outlined,
          title: 'Nothing here yet',
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('renders the optional message', (tester) async {
    await tester.pumpWidget(
      _harness(
        const StatusView(
          icon: Icons.inbox_outlined,
          title: 'Nothing here yet',
          message: 'There is nothing to show right now.',
        ),
      ),
    );

    expect(find.text('There is nothing to show right now.'), findsOneWidget);
  });

  testWidgets('action button appears only when label and callback are given',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        StatusView(
          icon: Icons.cloud_off,
          title: "You're offline",
          actionLabel: 'Try again',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('Try again'), findsOneWidget);

    await tester.pumpWidget(
      _harness(
        const StatusView(
          icon: Icons.inbox_outlined,
          title: 'Nothing here yet',
          actionLabel: 'Try again',
        ),
      ),
    );
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('tapping the action fires onAction', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _harness(
        StatusView(
          icon: Icons.cloud_off,
          title: "You're offline",
          actionLabel: 'Try again',
          onAction: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Try again'));
    expect(taps, 1);
  });
}