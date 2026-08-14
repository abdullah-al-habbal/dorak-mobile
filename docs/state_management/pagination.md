# Pagination

Status: `DONE`

## Purpose

Two ready-made pagination state machines in `packages/core`:

* `PagePaginationNotifier<T>` — page-based UI (Next / Previous, page
  indicator, numbered pages). Pages are 1-based to match the backend
  `meta.pagination.current_page`.
* `ScrollPaginationNotifier<T>` — infinite scroll. Appends pages as the
  user scrolls and stops once the last page is reached.

Both wrap a fetch callback taking a page number and returning
`PaginatedData<T>` (items + `PaginationMeta`):

```dart
final pager = PagePaginationNotifier(
  fetch: ({required int page, int perPage = 15}) =>
      repository.fetchBranches(page: page, perPage: perPage),
);
```

## PagePaginationNotifier

```dart
pager.loadFirst();          // page 1
pager.next();                // page 2
pager.previous();            // back
pager.goTo(3);
pager.refresh();             // reload current page

// State
pager.items;
pager.currentPage;
pager.totalPages;
pager.hasPrev;               // currentPage > 1
pager.hasNext;               // currentPage < totalPages
pager.isLoading;
pager.error;                 // ApiException?
```

## ScrollPaginationNotifier

```dart
final scroller = ScrollPaginationNotifier(
  fetch: ({required int page, int perPage = 15}) =>
      repository.fetchFeed(page: page),
);

scroller.loadFirst();
scroller.onScroll(controller);   // attach a ScrollController
scroller.loadMore();             // manual trigger
```

`onScroll` fires `loadMore` when the scroll position approaches the end
(~200 px threshold). Once the last page is appended, `hasMore` is false and
further scrolls are no-ops.

## Error Handling

Fetch errors are recorded in `error` (`ApiException?`) and the previous
page's items are kept. Retry is an explicit user action (`refresh()` or
calling `loadFirst()` again).

## Verification

Covered by `packages/core/test/pagination_test.dart`.
