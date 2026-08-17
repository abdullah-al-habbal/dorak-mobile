# State Management

Architecture: **Pure Bloc** + **go_router**. Locked.

Start with [`conventions.md`](./conventions.md) — it is the canonical contract.
Everything else on this page elaborates one part of it.

---

## Map

| Document | Covers |
|---|---|
| [`conventions.md`](./conventions.md) | **The contract.** Bloc/Event/State, loading, success, empty, error, retry, refresh, pagination, concurrency, repository boundaries, UI rules, navigation separation, testing |
| [`async_state.md`](./async_state.md) | The five async conditions, `isLoading` vs `isSubmitting`, the `_run` idiom, error mapping, the retry-guard trap |
| [`refresh.md`](./refresh.md) | First-load vs load-more vs refresh; refresh vs filter change; failed refresh |
| [`pagination.md`](./pagination.md) | The `Paged<T>` contract, the real backend envelope, the UI decision matrix |
| `background_operations.md` | **Intentionally empty** — see below |

## The short version

- **Pure Bloc.** Every state change is an event. No Cubit.
- **No `ChangeNotifier` application state, no Provider, no Riverpod, no GetIt.**
- Shared infrastructure blocs live in `packages/core` with pure `bloc`
  ([ADR 0001](../architecture/decisions/0001-bloc-in-core.md)); feature blocs
  live in their owning app and may use `flutter_bloc`. Core never gets
  `flutter_bloc` or `go_router`.
- **One flat `Equatable` state class per bloc**, with an explicit `clearX` flag
  for every nullable field.
- **Blocs never navigate.** Navigation reacts to a one-shot signal consumed by
  `AppRouter`.
- Errors are state, not exceptions to rethrow. The UI localizes them; a backend
  `message` is never rendered.

## Current blocs

| Bloc | Location | State |
|---|---|---|
| `SessionBloc` | `packages/core/lib/src/session/` | `SessionState` + `SessionSignal` |
| `AuthBloc` | `packages/core/lib/src/session/` | `AuthState` + `AuthSignal` |
| `LocaleBloc` | `apps/client_app/lib/src/core/locale/` | `Locale` — see the exemption below |
| `OnboardingConfigBloc` | `apps/client_app/lib/src/features/onboarding/` | `OnboardingConfigState` |

### The single-value-state exemption

`LocaleBloc` is `Bloc<LocaleEvent, Locale>` and has no `.state.dart`. This is
sanctioned, not an oversight: a bloc whose entire state is one value-equal type
may use that type directly. The `.bloc`/`.event`/`.state` triple names files
that exist; it is not a mandate to create wrapper classes. Full rule and the
conversion trigger: [`conventions.md`](./conventions.md) §1a.

## Why `background_operations.md` is empty

Nothing in Dorak performs background work — no upload queue, no scheduler, no
isolate, no background fetch. Writing a contract for it would be fiction, and a
future agent would follow it. The file stays empty until Track 13 (File & Media
Infrastructure) creates something real to describe.

## Open items

| Item | Status |
|---|---|
| Pagination contract validated by a real feature | **pending** — `Paged<T>` exists and is tested, but has no consumer until Discovery (016) |
| `bloc_concurrency` for cancellation (`restartable()`) | **pending a consumer** — added with the first search field, not before |
| Global loading / empty / error / offline / retry **widgets** | Track 12 — this track defines state, not UI components |

## Verification

```bash
cd dorak-mobile
dart run melos run verify
```
