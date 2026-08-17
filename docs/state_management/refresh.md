# Refresh

Status: `DONE` — conventions defined. No screen implements pull-to-refresh yet;
the first will be the Discovery feed (Stitch 016).

---

## Three reloads, three renderings

They are different operations and must be distinguishable from state alone.
`Paged<T>` carries a `PageTrigger` for exactly this reason.

| Operation | Trigger | Items during | On failure |
|---|---|---|---|
| **First load** | `first` | none to show — full skeleton | full-screen error + retry |
| **Load more** | `more` | list stays, footer spinner | list stays, footer retry |
| **Refresh** | `refresh` | **list stays**, refresh indicator | **list stays**, transient notice |

The rule that ties them together: **refresh never flashes empty.** A user who
pulls to refresh is looking at content; replacing it with a skeleton and then
restoring it is a worse experience than a brief indicator over stale data. So
`Paged.refreshing()` keeps `items`, and only `succeeded()` replaces them.

## Refresh versus filter change

They look similar and behave differently.

| | Refresh | Filter / query change |
|---|---|---|
| Transition | `refreshing()` | `reset()` then `loadingFirst()` |
| Existing items | kept until the response lands | **discarded immediately** |
| Page | back to 1 | back to 1 |
| Rationale | same query, newer data | different query — showing old results under new filters is a lie |

For `/explore/branches`, the filters (`available_now`, `price_range`,
`rating_min`, `catalog_item_ids[]`, `radius`) are query parameters, so any change
is a new query and takes the `reset()` path.

## Failed refresh

Rule 26 in [`conventions.md`](./conventions.md): a failed refresh keeps the
existing list and surfaces a transient notice — a snackbar, not a full-screen
error. The user still has usable content; replacing it with an error page
destroys that for no gain.

`hasFailedRefresh` distinguishes this from `hasFailedFirst` (nothing to show,
full error) and `hasFailedMore` (footer retry).

## Concurrency

Refresh and load-more must not run together. Both go through the same guard:

```dart
if (state.results.isBusy) return;
```

emitted **before the first `await`** — see [`conventions.md`](./conventions.md)
§8. `isBusy` is true for all three triggers, so any in-flight operation blocks
the others.

A refresh arriving while a load-more is in flight is therefore **dropped**, not
queued. That is deliberate: the load-more response will land and the user can
pull again. Queueing would need cancellation semantics, which is
`bloc_concurrency.restartable()` — not yet a dependency (§8 rule 32).

## Non-paginated refresh

A bloc without pagination re-dispatches its load event. The retry guard must not
block it — see [`async_state.md`](./async_state.md). `OnboardingConfigBloc`
refetches when the locale changes, which is the same mechanism.

## Verification

```bash
cd dorak-mobile
dart run melos run test
```

Transition behaviour is covered by `packages/core/test/paged_test.dart` —
specifically that `succeeded` after `refreshing()` replaces rather than appends,
and that `failed` keeps the loaded items.
