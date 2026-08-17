# Pagination

Status: `IN_PROGRESS` — the contract (`Paged<T>`) exists and is tested, but **no
feature consumes it yet**. It is not marked `DONE` until a real feed validates
it (expected: Discovery, Stitch 016). If 016 finds the contract does not fit,
change `Paged<T>` — do not work around it.

The legacy `PagePaginationNotifier` / `ScrollPaginationNotifier` `ChangeNotifier`s
were deleted in Phase 4; they had no production consumers. Do not reintroduce a
`ChangeNotifier` pager, and **do not add a generic `PaginationBloc<T>`** — bloc
dispatches on event *type*, so generic events work badly, and every real feed
carries more than a list (filters, tab, query).

---

## 1. The backend contract

Envelope, from `modules/Core/Helpers/ApiResponseTrait.php::paginated`:

```json
{
  "data": [ ... ],
  "meta": { "pagination": {
    "total": 25, "count": 15, "per_page": 15,
    "current_page": 1, "total_pages": 2
  }}
}
```

Nine client-facing collections paginate today:

```
GET /explore/branches            <- the Discovery feed
GET /explore/barbers
GET /client/favorites
GET /client/history
GET /bookings
GET /branches/{branch}/reviews
GET /branches/{branch}/chairs
GET /service-catalog/items
GET /brands
```

`/explore/branches` requires `latitude`, `longitude`, `radius` and `universe`,
and accepts `per_page` (max 100), `catalog_item_ids[]`, `available_now`,
`price_range{min,max}`, `rating_min`, `face_shape_compatible`. Its `clientId` is
`$this->user()?->id` — nullable, so **the feed is guest-accessible**.

There is no `/client/discovery-feed` route. `/client/discovery-preferences` is a
separate preferences resource, not the feed.

## 2. What core provides

```dart
final page = await api.getPaginated<BranchDto>(
  '/explore/branches',
  queryParameters: {'page': 2, 'per_page': 15, 'latitude': …},
  itemParser: (json) => BranchDto.fromJson(json as Map<String, dynamic>),
);

page.data;              // List<T>   — the field is `data`, not `items`
page.meta.currentPage;  // 1-based
page.meta.perPage;
page.meta.totalPages;
```

`getPaginated` validates the envelope like every other verb: a `success: false`
body or a `statusCode >= 400` **throws**. An API or network failure is never
converted into a successful empty page — that distinction is the whole point of
the empty state.

## 3. Modes Dorak actually needs

| Mode | Needed | Note |
|---|---|---|
| Numbered pages | **No** | No screen in Stitch 010–020 shows page numbers. `currentPage` is still carried, so a numbered UI remains possible without a contract change. |
| Load-more / infinite | **Yes** | The only mode any real screen uses |
| Pull-to-refresh | **Yes** | Stitch 016 §38 |
| Retry | **Yes** | Separately for the first page and the next page |
| Empty | **Yes** | Must not look like an error |
| End-of-list | **Yes** | Derived, never stored |

## 4. `Paged<T>`

`packages/core/lib/src/network/paged.entity.dart` — an immutable value object.
No bloc, no Flutter, no JSON. A feature state **holds one as a field**:

```dart
class DiscoveryState extends Equatable {
  final Paged<BranchDto> results;
  final DiscoveryFilters filters;
}
```

```dart
enum PageStatus  { initial, loading, success, failure }
enum PageTrigger { first, more, refresh }

class Paged<T> {
  List<T>        items
  PaginationMeta meta
  PageStatus     status
  PageTrigger    trigger    // which operation is in flight, or last completed
  Object?        error
}
```

### Derived getters

```
hasMore          meta.currentPage < meta.totalPages
isEmpty          success and no items
isEndOfList      items present and no further pages
isBusy           status == loading            <- the load-more guard
isFirstLoad      loading + first
isLoadingMore    loading + more
isRefreshing     loading + refresh
hasFailedFirst   failure + first
hasFailedMore    failure + more
hasFailedRefresh failure + refresh
```

### Transitions — there is no public `copyWith`

`Paged` exposes named transitions instead. They encode the rules, so a feature
bloc cannot get append-versus-replace wrong, and there are no nullable setters
to reproduce the `client: null` no-op defect.

| Transition | Effect |
|---|---|
| `loadingFirst()` | `loading` + `first`, error cleared, items kept |
| `loadingMore()` | `loading` + `more`, error cleared, items kept |
| `refreshing()` | `loading` + `refresh`, error cleared, **items kept** so the list never flashes empty |
| `succeeded(PaginatedData<T>)` | `more` → **appends**; `first` / `refresh` → **replaces**. Always adopts the new `meta`. `success`, error cleared |
| `failed(Object)` | `failure`, records the error, **keeps items and meta**, leaves `trigger` so the UI knows which operation failed |
| `reset()` | back to `initial` — the filter/query-change path |

### Equality

`props` compares `PaginationMeta`'s **fields**, not the instance.
`PaginationMeta` is a plain `json_serializable` DTO with no value equality, so
two structurally identical pages decoded from separate responses would otherwise
compare unequal and re-trigger every listener. Do not collapse that back to
`meta`.

## 5. UI decision matrix

Every state Stitch 016 §39 requires, from one object. The concrete components
are Track 12's (`design_system`): see `docs/design_system/index.md`.

| Condition | Render | Component |
|---|---|---|
| `isFirstLoad` | full-screen skeleton | `ShimmerBox` list or `AppLoader.page()` |
| `isLoadingMore` | list + footer spinner | `AppLoader.inline()` |
| `isRefreshing` | list + refresh indicator | `RefreshIndicator` (framework) |
| `hasFailedFirst` | full-screen error + retry | `StatusView` + `l10n.actionRetry` |
| `hasFailedMore` | list + footer retry | `StatusBanner` + retry action |
| `hasFailedRefresh` | transient notice | `SnackBar` (framework) |
| `isEmpty` | empty state — **not** an error | `StatusView` (neutral copy) |
| `isEndOfList` | end-of-list marker | text line — no component warranted |

## 6. Rules

1. Load-more appends. Refresh and filter-change replace.
2. **Any filter or query change calls `reset()` and refetches page 1** —
   `/explore/branches` filters are query parameters.
3. A failed next page never discards loaded items.
4. `hasMore` is derived, never stored.
5. Page size is a per-feature constant; the backend caps `per_page` at 100.
6. **Load-more dedupe uses a state guard, emitted before the first `await`**
   (see [`conventions.md`](./conventions.md) §8). A scroll fling dispatches the
   event repeatedly.

## 7. Feature bloc shape

Illustrative. Discovery is **not** implemented — this is the pattern 016 will
follow.

```dart
Future<void> _onLoadMore(LoadMoreRequested e, Emitter<DiscoveryState> emit) async {
  if (state.results.isBusy) return;
  if (!state.results.hasMore) return;

  emit(state.copyWith(results: state.results.loadingMore()));  // before any await

  try {
    final next = await _repository.fetchBranches(
      page: state.results.meta.currentPage + 1,
      filters: state.filters,
    );
    emit(state.copyWith(results: state.results.succeeded(next)));
  } catch (e) {
    emit(state.copyWith(results: state.results.failed(e)));
  }
}
```

## Verification

```bash
cd dorak-mobile
dart run melos run test
```

`packages/core/test/paged_test.dart` covers the boundaries — `hasMore` at
mid-list / last page / empty, `isEmpty` only on success-with-no-items, append
versus replace, failure keeping items, `reset`, and structural equality.
`packages/core/test/api_client_test.dart` covers the envelope guard.
