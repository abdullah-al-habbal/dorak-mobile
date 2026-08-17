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
  testWidgets('renders at the given size', (tester) async {
    await tester.pumpWidget(
      _harness(
        const ShimmerBox(width: 120, height: 24),
      ),
    );

    final container = tester.getSize(find.byType(ShimmerBox));
    expect(container, const Size(120, 24));
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('animation advances on pump and disposes cleanly',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        const ShimmerBox(width: 120, height: 24),
      ),
    );

    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    await tester.pumpWidget(_harness(const SizedBox()));
    expect(tester.takeException(), isNull);
  });
}