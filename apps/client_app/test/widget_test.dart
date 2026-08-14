import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/main.dart';

void main() {
  testWidgets('splash screen renders the brand', (WidgetTester tester) async {
    await tester.pumpWidget(const DorakApp());

    expect(find.text('Dorak'), findsOneWidget);

    // Dispose the tree, then flush the splash's pending navigation timer
    // without triggering the network-backed hero image.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
