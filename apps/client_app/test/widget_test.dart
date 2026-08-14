import 'package:client_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://test/api\nAPI_BASE_URL_V1=http://test/api/v1',
    );
  });

  testWidgets('splash screen renders the brand', (WidgetTester tester) async {
    await tester.pumpWidget(const DorakApp());

    expect(find.text('Dorak'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
