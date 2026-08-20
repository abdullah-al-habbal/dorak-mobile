# Application Lifecycle — Dorak Client App (`apps/client_app`)

Track 10 — *Application lifecycle*. Monorepo track index:
[`docs/index.md`](../../../../docs/index.md).

---

## 1. What this covers

Exactly one behaviour: **when the app returns to the foreground it re-probes the
stored session token.**

Nothing else about the lifecycle is handled here. There is no background task
scheduling, no data refresh on resume, no analytics session boundary, no
connectivity listener. Those are separate tracks and MUST NOT be folded into
this observer.

## 2. Why it exists

Before this, a session was only re-checked at two moments:

1. **Cold start** — `SessionBloc.ready` dispatches `RestoreRequested`.
2. **Mid-request 401** — `ApiClient.unauthorizedStream` → `UnauthorizedDetected`.

Both leave the same hole. A token can expire or be revoked server-side while the
app sits in the background — a Sanctum token deleted by an admin, a password
reset elsewhere, a `SANCTUM_EXPIRATION` window elapsing. On resume the app has no
idea. It keeps rendering authenticated UI, with authenticated affordances, until
the user happens to trigger a request that returns 401.

The resume probe closes that hole by re-running the check the app already trusts
at cold start, at the one other moment the client can know time has passed.

## 3. Implementation

`lib/app.dart`, in `_DorakAppState`:

```dart
late final AppLifecycleListener _lifecycleListener;

// initState, alongside the other external-signal wiring
_lifecycleListener = AppLifecycleListener(onResume: _probeSessionOnResume);

// dispose, first — before the blocs the callback talks to are closed
_lifecycleListener.dispose();

void _probeSessionOnResume() {
  final session = _sessionBloc.state;
  if (session.status == AuthStatus.unknown) return;
  if (session.isLoading) return;
  _sessionBloc.add(RestoreRequested());
}
```

That is the entire feature. **No new bloc, no new event, no new state field, no
routing change.** `RestoreRequested` and `SessionBloc` already existed and are
reused verbatim.

### Why `AppLifecycleListener`

Flutter offers two APIs for this. `AppLifecycleListener` (Flutter 3.13+; the repo
runs 3.44) is preferred over the older `WidgetsBindingObserver` mixin because:

| | `AppLifecycleListener` | `WidgetsBindingObserver` |
|---|---|---|
| Registration | self-registering, `dispose()` unregisters | manual `addObserver` / `removeObserver` |
| Resume detection | `onResume` — fires on the transition | `didChangeAppLifecycleState`, hand-compare states |
| Scope | one object, one callback | mixin on `State`, all lifecycle callbacks |

The mixin form would require adding a mixin to `_DorakAppState`, storing the
previous `AppLifecycleState`, and comparing it by hand to distinguish *resumed*
from *already resumed*. `onResume` is edge-triggered by the framework, so that
bookkeeping disappears. Fewer moving parts, one owner, one `dispose`.

### The two guards

**`status == AuthStatus.unknown` → skip.** The startup restore owns that status.
`SessionBloc.ready` memoises its restore (`_restoration ??= …`) and the splash
awaits it; a concurrent second restore would resolve the session twice behind
that completer. The startup probe is already in flight, so the resume probe has
nothing to add.

**`isLoading` → skip.** A restore or a logout is already running. `SessionBloc`
uses Bloc's default `concurrent()` event transformer, so a second
`RestoreRequested` would overlap the first rather than queue behind it — two
`refreshToken()` calls and two interleaved emits.

Deliberately **not** a guard: `status == guest`. It is true today that a guest has
no token, so the probe is a single storage read and no network call. But that
fact lives in `SessionBloc._onRestore`, and duplicating it in the app layer would
turn a future change there into a silent bug here. The bloc stays the single
source of truth for what a stored token means.

### Why not in `build`

The listener is constructed in `initState` and destroyed in `dispose`. It is never
touched from `build`, so the locale-toggle rebuild (`BlocBuilder<LocaleBloc>`) and
every other rebuild cannot create a second observer or fire a second probe.

## 4. Interaction with existing behaviour

**Splash / startup — unchanged.** `AppRouter._redirect` only forces the splash
while `status == AuthStatus.unknown`. `_onRestore` never returns to `unknown` — it
seeds `guest` and emits `guest` or `authenticated` — so a resume probe cannot
re-enter the splash. `session.ready` is memoised and is not re-awaited.

**Session expiry — unchanged.** The resume probe reuses `_onRestore`, which for a
revoked token clears storage and resolves to `guest` **without** raising
`SessionSignal.sessionExpired`. That is the pre-existing cold-start contract,
pinned by `test/session_expired_test.dart` → *"a revoked token at restore does not
raise sessionExpired"*. The resume path inherits it rather than inventing a second
expiry semantics.

The consequence is stated plainly: **a resume probe that finds a dead token
resolves the session to guest but does not navigate.** The user stays on whatever
route they were on. Route-level enforcement is Track 11 (*Authentication guards —
`PARTIAL`; there are no per-route guards*), not Track 10. See §6.

**Repeated resumes.** Each background→foreground round-trip probes once. There is
no debounce and no minimum interval; the guards make an overlapping probe
impossible, and a resume is a user-scale event, not a frame-scale one.

## 5. Tests

`test/widget_test.dart`, group `application lifecycle` — the only test that pumps
the real `DorakApp`, which is where the listener lives.

Observability comes from `FakeAuthRepository.refreshTokenCalls` in
`test/helpers/fakes.dart`. One `RestoreRequested` with a stored token calls
`refreshToken` exactly once, so a restore is counted, never timed. No pixel
assertions, no `pump` duration tuning.

| Test | Asserts |
|---|---|
| resuming from the background re-probes the session | 1 call after startup, 2 after one resume |
| each resume re-probes exactly once | 1 → 2 → 3 → 4; a duplicate observer would double each step |
| ordinary rebuilds do not re-probe | count stays 1 across five pumped frames |
| a resume while the startup restore is unresolved is ignored | count stays 1 — the `unknown` guard |
| a resume after the token was revoked resolves to guest | probe runs, route is not replaced (the §4 contract) |

The unresolved-startup test gates the fake with
`FakeAuthRepository.refreshTokenGate`, a `Completer` that is null by default so no
other test's timing changes.

Resume transitions are driven with the full legal chain
`inactive → hidden → paused → hidden → inactive → resumed`; the framework rejects
illegal jumps and `onResume` is edge-triggered, so both directions must be walked.

**Verified against the unfixed code.** With the listener reverted, 3 of the 5 fail
(`Expected: <2> Actual: <1>`). The other 2 assert an *absence* of probes and pass
trivially without the feature — they guard the guards, not the feature.

## 6. Known limitation — not in scope

A resume probe that finds a revoked token leaves the user on an authenticated
route showing guest state. Fixing that means either:

- raising `sessionExpired` from `_onRestore` — changes authentication logic and
  breaks the cold-start contract in §4, or
- adding a per-route authentication guard — **Track 11**.

The second is correct and is deferred to that track. Recorded here so it is not
rediscovered as a bug.

## 7. Not implemented

- `business_app` and `stylist_app` — untouched. Track 10 lists their bootstrap as
  outstanding; the lifecycle observer follows their bootstrap, not before it.
- Resume-time data refresh for any feature.
- Background task scheduling / `onDetach` teardown.
- Connectivity or offline detection on resume.
