# State Management Conventions

Status: `DONE` — this is the canonical contract for all Dorak state.

Architecture: **Pure Bloc** + **go_router**. Locked. See
[ADR 0001](../architecture/decisions/0001-bloc-in-core.md) for why blocs are
permitted in `packages/core`.

Prohibited everywhere, without exception: **Cubit**, **`ChangeNotifier`
application state**, **Provider**, **Riverpod**, **GetIt** or any service
locator. `provider` appears in the lock file only as a transitive dependency of
`flutter_bloc` (its `InheritedWidget` plumbing) — never import it.

---

## 1. Bloc

1. One bloc per concern. Files: `<subject>.bloc.dart`, `<subject>.event.dart`,
   `<subject>.state.dart`.
2. Every state change is an event. There is no Cubit and no direct setter.
3. **Shared infrastructure blocs live in `packages/core`** using pure `bloc`
   (`SessionBloc`, `AuthBloc`). **Feature blocs live in their owning app or
   feature package** and may use `flutter_bloc`. Core never gets `flutter_bloc`
   or `go_router`.
4. A bloc owns exactly one concern. `SessionBloc` (global session truth) versus
   `AuthBloc` (active auth operations) is the reference split.
5. Dependency injection is constructor wiring in `DorakApp.initState`. There is
   no container.

### 1a. The single-value-state exemption

> **A bloc whose entire state is one value-equal type may use that type
> directly as its state, and omit `.state.dart`.**

The `.bloc`/`.event`/`.state` triple is a naming convention for files that
exist. `tool/check_taxonomy.dart` validates the names of files present; it never
requires the triple to be complete. **Do not create a wrapper class only to
satisfy the pattern.**

`LocaleBloc` is the sanctioned instance:

```dart
class LocaleBloc extends Bloc<LocaleEvent, Locale>
```

`Locale` implements value equality in the Flutter SDK
(`platform_dispatcher.dart`, comparing `languageCode`, `scriptCode`,
`countryCode`), so bloc's duplicate-emission suppression works and setting the
locale already in effect emits nothing — covered by
`apps/client_app/test/locale_bloc_test.dart`.

**Conversion trigger.** Introduce `LocaleState` the moment a second real state
field is needed — persisted-versus-system locale, a loading flag, or another
genuine responsibility. Not before. The change is safe to defer:
`BlocBuilder<LocaleBloc, Locale>` names the type explicitly, so introducing a
state class is a compile error at every call site, never a silent break.

## 2. Events

6. Events extend `Equatable`; `props` lists every field.
7. Naming: **past-tense fact** for something that happened
   (`UnauthorizedDetected`); **`…Requested`** for user or system intent
   (`LoginRequested`, `LoadMoreRequested`). Never `SetX` / `UpdateX` — those
   name a mutation, not an event.
8. Events carry data only. Never a callback, never a `BuildContext`.
9. One-shot signals are cleared by an explicit acknowledgement event
   (`SignalAcknowledged`, `AuthSignalAcknowledged`), never implicitly on the
   next emission.

## 3. State

10. **One flat `Equatable` class per bloc.** No sealed status hierarchy — it
    forces exhaustive switches in widgets and makes partial updates verbose.
    Loading is a field, not a subclass.
11. Every state has a `const` default constructor usable as the initial state.
12. **`copyWith` exposes an explicit `clearX` flag for every nullable field.**
    `field ?? this.field` makes `null` unsettable. This is not theoretical:
    `SessionState.copyWith(client: null)` was a silent no-op and left an expired
    user cached in state. Current flags: `clearError`, `clearClient`,
    `clearConfig`.
13. `props` lists every field. A field missing from `props` is a silent
    stale-render or missed-redirect bug.
14. Derived values are getters, never stored — `isAuthenticated`, `hasMore`,
    `isEmpty`.

## 4. Loading · success · empty · error

15. **`isLoading` means reading. `isSubmitting` means a user-initiated write.**
    Never both for one operation.
16. Initial, loading and empty are three distinct conditions and must be
    distinguishable from state alone.
17. Success is the absence of `error` plus populated data — not a separate flag.
18. **Empty is `success && data.isEmpty`.** Never conflated with initial, and
    never rendered as an error.
19. Errors land in `state.error` as `Object?`. **Blocs never rethrow.**
20. **The UI maps errors to localized strings** — see `AuthError.from`
    (`apps/client_app/.../auth/auth_error.entity.dart`). A backend `message` is
    an untranslated key (`core::messages.*`) and is never rendered.

## 5. Retry

21. **Retry re-dispatches the same event.** There is no `RetryRequested`.
22. **A guard that prevents a duplicate in-flight request must not prevent a
    retry after failure.** `OnboardingConfigBloc` violated this — it assigned
    `localeCode` before fetching and then compared against it, so a failed load
    could never be retried for that locale. The guard now also requires either
    an in-flight load or an already-successful one.
23. Retry preserves surrounding state — filters, query, loaded items.

## 6. Refresh

24. Refresh reloads from the first page **while keeping current data visible**,
    so the screen never flashes empty.
25. Refresh is distinguishable from first-load and from load-more in state — see
    `PageTrigger` in [`pagination.md`](./pagination.md).
26. A failed refresh keeps the existing list. It is a transient notification,
    not a full-screen error.

## 7. Pagination

27. The contract is `Paged<T>` in `packages/core`. Full specification in
    [`pagination.md`](./pagination.md).
28. **There is no generic `PaginationBloc<T>`** and none should be added. Bloc
    dispatches on event *type*, so generic events work badly, and every real feed
    carries more than a list. Feature blocs hold a `Paged<T>` as a field.

## 8. Concurrency and event ordering

29. **Bloc's default event transformer is `concurrent()`.** Events of different
    types always interleave. Events of the *same* type also start concurrently —
    each handler runs synchronously only up to its first `await`, then yields.
30. **A handler that can emit before its first `await` uses a state guard**, and
    must emit first so a same-frame duplicate observes it:

    ```dart
    if (state.results.isBusy) return;
    if (!state.results.hasMore) return;
    emit(state.copyWith(results: state.results.loadingMore())); // before any await
    ```

31. **A handler that must `await` before it can emit uses a synchronous bool
    latch.** Reference: `SessionBloc._expiring`, which is what collapses a burst
    of 401s into exactly one expiration.
32. **Cancellation semantics use `bloc_concurrency.restartable()`.** The package
    is deliberately **not yet a dependency** — it is added with its first real
    consumer, expected to be the Discovery feed's search field (Stitch 016).
    Until then, **do not hand-roll a generation counter to fake cancellation.**
    Surface the need instead.
33. Cross-bloc coordination goes through the app layer, keyed on a **signal**,
    never on incidental state. Reference:
    `apps/client_app/lib/src/core/session/auth_coordination.entity.dart`, which
    fires on `AuthSignal.loginSucceeded | registrationSucceeded` — an earlier
    version keyed on `client != null` and re-authenticated an expired session.
    **No bloc-to-bloc `add()`.**
34. Where two listeners observe one bloc, subscription order is the contract and
    must be stated. `DorakApp.initState` subscribes the session coordinator
    before constructing `AppRouter`, so the session updates before the router
    navigates.

### Known gap

`OnboardingConfigBloc` can have two loads in flight for different locales if the
user toggles twice inside one round-trip; the later response wins regardless of
order. This is the concrete case rule 32 defers — it is fixed by
`restartable()`, not by a hand-rolled counter.

## 9. Async operations and repository boundaries

35. `UI → Bloc → repository → ApiClient → backend`. A bloc never touches `Dio`
    or a storage key directly; a widget never touches a repository.
36. Repositories throw typed exceptions — `ApiException`, `ValidationException`,
    `NetworkException`. **Transport types never reach the UI.** The single
    deliberate leak is `NetworkException.type`; do not widen it.
37. Repositories are stateless. Caching and session state belong to a bloc or a
    storage contract.
38. Exactly one component writes a given storage key.
39. A private `_run` helper is the idiom for
    `emit(busy) → action → emit(result | error)`. See `AuthBloc._run`.

## 10. UI interaction

40. UI dispatches events and renders from state through `BlocBuilder`.
41. **Ephemeral widget state stays in `State`** — `TextEditingController`,
    `FocusNode`, `AnimationController`, cooldown `Timer`, obscure-text toggles.
    These are not application state and must not move into a bloc.
42. A screen never calls a repository, touches storage, or decides where to
    navigate next.
43. A widget never holds a bloc it was not given.

## 11. Navigation separation

44. **A bloc never navigates.** `context.go`, `context.push`, or `Navigator.*`
    inside a `*.bloc.dart` is a defect.
45. Navigation reacts to a **one-shot signal** consumed and acknowledged by
    `AppRouter`. `SessionSignal` and `AuthSignal` are the reference.
46. **`go` versus `push` is a contract**: `sessionExpired` → `router.go`
    (replaces the stack, so a dead-session screen cannot be back-navigated
    into); `authenticationRequired` → `router.push` (back returns to the guest
    destination). See [`../navigation/guards.md`](../navigation/guards.md).
47. Routing lives in `app.router.dart` and `app_routes.entity.dart`, never in a
    screen or a bloc.

## 12. Testing

48. `blocTest` per transition. `expect` the **full emission sequence**, not only
    the final state.
49. **Construct blocs inside the `testWidgets` body, never in `setUp`.** A bloc
    built in `setUp` sits outside the FakeAsync zone, so its event stream never
    delivers and `await ready` hangs.
50. Hand-written fakes in `test/helpers/`. `mocktail` arrives transitively with
    `bloc_test` and must not be used for repositories or storage.
51. **Every `clearX` flag needs a test proving the field actually clears.** That
    bug class has shipped once.
52. A regression test must be shown to fail against the unfixed code. Otherwise
    it documents an assumption rather than protecting behaviour.
53. Widget tests set a phone viewport (`1290 × 2796`, dpr `3.0`) — the 800×600
    default overflows these screens.
54. No real network, no platform channels.

## Verification

```bash
cd dorak-mobile
dart run melos run verify
```
