# Pagination

Status: `DONE` — transport layer only. The legacy `PagePaginationNotifier` /
`ScrollPaginationNotifier` `ChangeNotifier`s were **deleted** in Phase 4.
Paging UI state is now app-layer Bloc work; nothing in `packages/core`
implements a pager anymore.

## What core provides

`ApiClient.getPaginated` decodes the backend page envelope into a
`PaginatedData<T>` (items + `PaginationMeta`):

```dart
final page = await api.getPaginated(
  '/client/discovery-feed',
  parser: DiscoveryDto.fromJson,
  queryParameters: {'page': 2, 'perPage': 15},
);
page.items;      // List<T>
page.meta.page;        // 1-based, matches meta.pagination.current_page
page.meta.perPage;
page.meta.totalPages;  // drives hasMore: page < totalPages
```

## Feature paging state

Paging is business state, so it belongs in a Bloc at the app layer (see
`docs/state_management/`). The locked pattern:

* a `<feed>_bloc.dart` (`.event.dart` + `.state.dart`) owns `items`,
  `page`, `hasMore`, `isLoading`, `error`;
* `LoadMoreRequested` fetches `page + 1` when `hasMore`; `RefreshRequested`
  reloads page 1;
* fetch errors land in `state.error`, keeping the last loaded items — retry is
  an explicit user action.

A shared paging Bloc in `packages/core` is not built yet; do not reintroduce a
`ChangeNotifier` pager to fill the gap.

## Verification

Envelope decode is covered by `packages/core/test/api_client_test.dart`.
