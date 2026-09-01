# Application Lifecycle

Status: `DONE`

Part of **Track 10** (`docs/index.md`). The remaining objective, "application
lifecycle", is implemented in `apps/client_app/lib/app.dart` and covered by
`apps/client_app/test/widget_test.dart`. This doc records the mechanism, the
guards, and the deliberately-owned gaps so they are not re-derived.

## What the app does on resume

`_DorakAppState` owns exactly one `AppLifecycleListener`, built in `initState`
and disposed in `dispose`:

```dart
_lifecycleListener = AppLifecycleListener(onResume: _probeSessionOnResume);
```

`_probeSessionOnResume` re-runs the session restore:

```dart
final session = _sessionBloc.state;

// The startup restore owns the `unknown` status. Racing it would resolve
// the session twice behind the splash's `session.ready` completer.
if (session.status == AuthStatus.unknown) return;

// A restore or logout is already running. `RestoreRequested` uses Bloc's
// default concurrent transformer, so a second one would overlap the first.
if (session.isLoading) return;

_sessionBloc.add(RestoreRequested());
```

## Why

A session can die while the app is backgrounded — Sanctum tokens carry no
server-side expiry and there is no push channel telling the client a token was
revoked. Without a resume probe the app keeps rendering authenticated UI until
some later request happens to return a 401.

`RestoreRequested` already defines the correct semantics (see
`docs/core/session.md`): a valid token rotates and stays; a 401/403 clears to
`guest`; a `NetworkException` (offline resume) keeps the session.

## Event coverage

| `AppLifecycleState` | Handled | Why |
|---|---|---|
| `resumed` | ✅ probe the session | session may have died while backgrounded |
| `inactive`, `hidden`, `paused` | ❌ deliberately ignored | nothing to tear down; state survives backgrounding by design |
| `detached` | ❌ deliberately ignored | owned by `dispose()` |

Only `resumed` is of interest today. Adding per-event behavior (e.g. suspending
uploads on `paused`) is Track 13/14 work — see
`docs/state_management/background_operations.md`.

The listener is created **once in `initState`**, never in `build`, so ordinary
rebuilds do not attach duplicate observers (guarded by a test).

## Evidence — `apps/client_app/test/widget_test.dart`, group `application lifecycle`

| Test | Proves |
|---|---|
| resuming from the background re-probes the session | 1 startup probe → background round-trip → 1 more probe (2 total) |
| each resume re-probes exactly once | N resumes → N probes — no duplicate observer |
| ordinary rebuilds do not re-probe | 5 frames of pumping → count unchanged |
| a resume while the startup restore is unresolved is ignored | gated restore; resume while `unknown` → probe count still 1 |
| a resume after the token was revoked resolves to guest | `refreshTokenError = unauthorized()` on resume → guest, no route replacement (same cold-start contract as `session_expired_test.dart`) |

## Related

- `docs/flows/app_launch.md` — bootstrap + the launch gate (the cold-start path;
  resume is the warm path, same `RestoreRequested`).
- `docs/core/session.md` — `SessionBloc` restore matrix and the
  `unknown | authenticated | guest` statuses the guard reads.
- `apps/client_app/lib/app.dart` — the one place lifecycle is wired.