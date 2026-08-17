import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

PaginatedData<String> page(
  List<String> items, {
  int currentPage = 1,
  int totalPages = 1,
  int total = 0,
  int perPage = 15,
}) {
  return PaginatedData<String>(
    data: items,
    meta: PaginationMeta(
      total: total == 0 ? items.length : total,
      count: items.length,
      perPage: perPage,
      currentPage: currentPage,
      totalPages: totalPages,
    ),
  );
}

void main() {
  const empty = Paged<String>.initial();

  group('derived flags', () {
    test('hasMore reflects the page window, not the item count', () {
      final mid = empty
          .loadingFirst()
          .succeeded(page(['a'], currentPage: 1, totalPages: 3));
      expect(mid.hasMore, isTrue);

      final last = empty
          .loadingFirst()
          .succeeded(page(['a'], currentPage: 3, totalPages: 3));
      expect(last.hasMore, isFalse);

      final none = empty
          .loadingFirst()
          .succeeded(page([], currentPage: 1, totalPages: 1));
      expect(none.hasMore, isFalse);
    });

    test('isEmpty is true only on a successful load with no items', () {
      expect(empty.isEmpty, isFalse, reason: 'initial is not empty');
      expect(empty.loadingFirst().isEmpty, isFalse, reason: 'loading is not empty');
      expect(
        empty.loadingFirst().failed(Exception('x')).isEmpty,
        isFalse,
        reason: 'a failure is not an empty result',
      );
      expect(empty.loadingFirst().succeeded(page([])).isEmpty, isTrue);
    });

    test('isEndOfList needs items and no further pages', () {
      final last = empty
          .loadingFirst()
          .succeeded(page(['a'], currentPage: 2, totalPages: 2));
      expect(last.isEndOfList, isTrue);

      final more = empty
          .loadingFirst()
          .succeeded(page(['a'], currentPage: 1, totalPages: 2));
      expect(more.isEndOfList, isFalse);

      expect(
        empty.loadingFirst().succeeded(page([])).isEndOfList,
        isFalse,
        reason: 'an empty result is the empty state, not end-of-list',
      );
    });
  });

  group('transitions', () {
    test('succeeded appends after loadingMore and replaces after refreshing', () {
      final first = empty
          .loadingFirst()
          .succeeded(page(['a', 'b'], currentPage: 1, totalPages: 2));

      final appended = first
          .loadingMore()
          .succeeded(page(['c'], currentPage: 2, totalPages: 2));
      expect(appended.items, ['a', 'b', 'c']);
      expect(appended.meta.currentPage, 2);

      final refreshed = appended
          .refreshing()
          .succeeded(page(['z'], currentPage: 1, totalPages: 1));
      expect(refreshed.items, ['z'], reason: 'refresh replaces, never appends');
    });

    test('failed keeps the loaded items and records which operation failed', () {
      final loaded = empty
          .loadingFirst()
          .succeeded(page(['a', 'b'], currentPage: 1, totalPages: 2));

      final failedMore = loaded.loadingMore().failed(Exception('boom'));
      expect(failedMore.items, ['a', 'b'], reason: 'a failed page keeps the list');
      expect(failedMore.meta.currentPage, 1);
      expect(failedMore.hasFailedMore, isTrue);
      expect(failedMore.hasFailedFirst, isFalse);

      final failedFirst = empty.loadingFirst().failed(Exception('boom'));
      expect(failedFirst.hasFailedFirst, isTrue);
      expect(failedFirst.items, isEmpty);
    });

    test('reset returns to initial, discarding items and error', () {
      final dirty = empty
          .loadingFirst()
          .succeeded(page(['a'], currentPage: 1, totalPages: 4))
          .loadingMore()
          .failed(Exception('boom'));

      final fresh = dirty.reset();
      expect(fresh, empty);
      expect(fresh.items, isEmpty);
      expect(fresh.error, isNull);
      expect(fresh.status, PageStatus.initial);
    });
  });

  test('equality is structural across separately decoded pages', () {
    final a = empty
        .loadingFirst()
        .succeeded(page(['a'], currentPage: 1, totalPages: 2));
    final b = empty
        .loadingFirst()
        .succeeded(page(['a'], currentPage: 1, totalPages: 2));

    expect(
      a,
      b,
      reason: 'PaginationMeta has no value equality, so Paged compares its '
          'fields — otherwise every refetch would re-trigger every listener',
    );
  });
}
