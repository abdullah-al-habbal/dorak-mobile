import 'package:client_app/app.dart';
import 'package:client_app/src/features/auth/auth_entry.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://test/api\nAPI_BASE_URL_V1=http://test/api/v1',
    );
  });

  testWidgets('bootstrap runs splash, then the launch gate', (tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DorakApp(
        preferences: InMemoryAppPreferences(),
        tokenStorage: InMemoryTokenStorage(),
        authRepository: FakeAuthRepository(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Dorak'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(AuthEntryScreen), findsOneWidget);
  });
}
