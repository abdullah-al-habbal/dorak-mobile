import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/navigation/app.router.dart';
import 'package:client_app/src/core/navigation/app_routes.entity.dart';
import 'package:client_app/src/features/booking/bookings.screen.dart';
import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/history.event.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakeHistoryRepository historyRepository;
  late InMemoryTokenStorage storage;
  late HistoryBloc history;

  setUp(() {
    authRepository = FakeAuthRepository();
    historyRepository = FakeHistoryRepository();
    storage = InMemoryTokenStorage('stored-token');
  });

  Future<AppRouter> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final pair = sessionPair(authRepository, storage);
    history = HistoryBloc(historyRepository);
    addTearDown(history.close);

    final router = buildRouter(
      session: pair.session,
      auth: pair.auth,
      history: history,
      preferences: InMemoryAppPreferences(dontShowOnboarding: true),
      apiClient: fakeApiClient(),
    );
    addTearDown(pair.coordinator.cancel);
    await tester.pumpWidget(routerHarness(router));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    router.router.go(AppRoutes.profile);
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('profile tab shows the header and the history list',
      (tester) async {
    await pumpProfile(tester);

    expect(find.text('Member'), findsOneWidget);
    expect(find.textContaining('Classic Fade'), findsOneWidget);
    expect(find.textContaining('Karim'), findsOneWidget);
    expect(find.text('Service History'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
  });

  testWidgets('history empty state renders when there are no records',
      (tester) async {
    historyRepository.firstPage = testHistoryPage(items: const []);
    await pumpProfile(tester);

    expect(find.text('No history yet'), findsOneWidget);
  });

  testWidgets('cancelling the picker dispatches nothing', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Book Again'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(historyRepository.rebookCalls, 0);
  });

  testWidgets('rebook success navigates to bookings and resets', (tester) async {
    await pumpProfile(tester);

    history.add(
      HistoryRebookRequested(
        'history-1',
        DateTime(2026, 9, 20, 9),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Booked Again'), findsOneWidget);

    await tester.tap(find.text('View My Bookings'));
    await tester.pumpAndSettle();

    expect(find.byType(BookingsScreen), findsOneWidget);
    expect(history.state.rebooked, isFalse);
  });
}