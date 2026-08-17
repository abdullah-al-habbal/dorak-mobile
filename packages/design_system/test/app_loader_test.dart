import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/design_system.dart';

void main() {
  testWidgets('page() centres a 32px indicator and expands',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DorakTheme.light,
        home: Scaffold(body: SizedBox.expand(child: AppLoader.page())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final indicator = tester.getSize(find.byType(CircularProgressIndicator));
    expect(indicator, const Size(32, 32));

    final alignment = tester.getCenter(
      find.byType(CircularProgressIndicator),
    );
    final center = tester.getCenter(find.byType(Scaffold));
    expect(alignment, center);
  });

  testWidgets('inline() shrink-wraps at the requested size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DorakTheme.light,
        home: Scaffold(body: AppLoader.inline(size: 20)),
      ),
    );

    final indicator = tester.getSize(find.byType(CircularProgressIndicator));
    expect(indicator, const Size(20, 20));
  });
}