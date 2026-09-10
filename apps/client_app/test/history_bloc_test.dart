import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/history.event.dart';
import 'package:client_app/src/features/profile/history.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeHistoryRepository repository;

  setUp(() => repository = FakeHistoryRepository());

  HistoryBloc bloc() => HistoryBloc(repository);

  group('HistoryStarted', () {
    blocTest<HistoryBloc, HistoryState>(
      'loads the first page on view',
      build: bloc,
      act: (bloc) => bloc.add(const HistoryStarted()),
      verify: (bloc) {
        expect(bloc.state.page.items, hasLength(1));
        expect(repository.lastPage, 1);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'second start is a no-op once items are loaded',
      build: bloc,
      seed: () => HistoryState(
        page: Paged<ServiceHistoryDto>.initial().succeeded(testHistoryPage()),
      ),
      act: (bloc) => bloc.add(const HistoryStarted()),
      expect: () => [],
      verify: (_) {
        expect(repository.getHistoryCalls, 0);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'empty first load fails the page',
      build: bloc,
      setUp: () => repository.error = offline(),
      act: (bloc) => bloc.add(const HistoryStarted()),
      verify: (bloc) {
        expect(bloc.state.page.hasFailedFirst, isTrue);
      },
    );
  });

  group('pagination', () {
    blocTest<HistoryBloc, HistoryState>(
      'load more appends the next page',
      build: bloc,
      seed: () => HistoryState(
        page: Paged<ServiceHistoryDto>.initial().succeeded(
          testHistoryPage(
            items: [testServiceHistory(id: 'history-1')],
            totalPages: 2,
          ),
        ),
      ),
      setUp: () {
        repository.morePage = testHistoryPage(
          items: [testServiceHistory(id: 'history-2')],
          currentPage: 2,
          totalPages: 2,
        );
      },
      act: (bloc) => bloc.add(const HistoryLoadMoreRequested()),
      verify: (bloc) {
        expect(repository.lastPage, 2);
        expect(
          bloc.state.page.items.map((item) => item.id),
          ['history-1', 'history-2'],
        );
      },
    );
  });

  group('HistoryRetryRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'retry reloads the first page',
      build: bloc,
      act: (bloc) => bloc.add(const HistoryRetryRequested()),
      verify: (bloc) {
        expect(repository.getHistoryCalls, 1);
        expect(bloc.state.page.items, hasLength(1));
      },
    );
  });

  group('HistoryRebookRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'rebook submits the slot and marks the booking rebooked',
      build: bloc,
      seed: () => HistoryState(
        page: Paged<ServiceHistoryDto>.initial().succeeded(testHistoryPage()),
      ),
      act: (bloc) => bloc.add(
        HistoryRebookRequested('history-1', DateTime(2026, 9, 20, 9)),
      ),
      verify: (bloc) {
        expect(repository.rebookCalls, 1);
        expect(repository.lastRebookedId, 'history-1');
        expect(repository.lastRebookSlot, DateTime(2026, 9, 20, 9));
        expect(bloc.state.rebookingId, isNull);
        expect(bloc.state.rebooked, isTrue);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'rebook failure records the error and stays on the list',
      build: bloc,
      seed: () => HistoryState(
        page: Paged<ServiceHistoryDto>.initial().succeeded(testHistoryPage()),
      ),
      setUp: () => repository.rebookError = offline(),
      act: (bloc) => bloc.add(
        HistoryRebookRequested('history-1', DateTime(2026, 9, 20, 9)),
      ),
      verify: (bloc) {
        expect(bloc.state.rebookingId, isNull);
        expect(bloc.state.rebooked, isFalse);
        expect(bloc.state.rebookError, isA<NetworkException>());
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'acknowledging the success returns to the list',
      build: bloc,
      seed: () => HistoryState(
        page: Paged<ServiceHistoryDto>.initial().succeeded(testHistoryPage()),
        rebooked: true,
      ),
      act: (bloc) => bloc.add(const HistoryRebookAcknowledged()),
      verify: (bloc) {
        expect(bloc.state.rebooked, isFalse);
      },
    );
  });
}