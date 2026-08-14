import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PagePaginationNotifier', () {
    test('loads first page and tracks next/prev bounds', () async {
      final notifier = PagePaginationNotifier<int>(
        perPage: 2,
        fetch: ({required int page, int perPage = 15}) async {
          final all = [1, 2, 3, 4, 5];
          final start = (page - 1) * perPage;
          final items = start >= all.length ? <int>[] : all.skip(start).take(perPage).toList();
          return PaginatedData(
            data: items,
            meta: PaginationMeta(
              total: 5,
              count: items.length,
              perPage: perPage,
              currentPage: page,
              totalPages: 3,
            ),
          );
        },
      );

      expect(notifier.hasPrev, isFalse);
      await notifier.loadFirst();

      expect(notifier.items, [1, 2]);
      expect(notifier.currentPage, 1);
      expect(notifier.totalPages, 3);
      expect(notifier.hasNext, isTrue);
      expect(notifier.hasPrev, isFalse);

      await notifier.next();
      expect(notifier.currentPage, 2);
      expect(notifier.items, [3, 4]);
      expect(notifier.hasPrev, isTrue);

      await notifier.goTo(3);
      expect(notifier.items, [5]);
      expect(notifier.hasNext, isFalse);

      await notifier.previous();
      expect(notifier.currentPage, 2);
    });

    test('records fetch errors and keeps prior page state', () async {
      final notifier = PagePaginationNotifier<int>(
        fetch: ({required int page, int perPage = 15}) async {
          if (page == 2) {
            throw const ApiException(statusCode: 500, code: 'SERVER_ERROR', message: 'boom');
          }
          return PaginatedData(
            data: const [1],
            meta: const PaginationMeta(
              total: 10, count: 1, perPage: 15, currentPage: 1, totalPages: 2),
          );
        },
      );

      await notifier.loadFirst();
      await notifier.next();

      expect(notifier.error, isA<ApiException>());
      expect(notifier.isLoading, isFalse);
      expect(notifier.items, [1]);
      expect(notifier.currentPage, 1);
    });
  });

  group('ScrollPaginationNotifier', () {
    test('appends pages until last page', () async {
      final notifier = ScrollPaginationNotifier<int>(
        perPage: 2,
        fetch: ({required int page, int perPage = 15}) async {
          final all = [1, 2, 3, 4, 5];
          final start = (page - 1) * perPage;
          final items = start >= all.length ? <int>[] : all.skip(start).take(perPage).toList();
          return PaginatedData(
            data: items,
            meta: PaginationMeta(
              total: 5,
              count: items.length,
              perPage: perPage,
              currentPage: page,
              totalPages: 3,
            ),
          );
        },
      );

      await notifier.loadFirst();
      expect(notifier.items, [1, 2]);
      expect(notifier.hasMore, isTrue);

      await notifier.loadMore();
      await notifier.loadMore();
      expect(notifier.items, [1, 2, 3, 4, 5]);
      expect(notifier.hasMore, isFalse);

      final before = notifier.items.length;
      await notifier.loadMore();
      expect(notifier.items.length, before);
    });
  });
}
