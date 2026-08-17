# Guards

Status: `IN_PROGRESS` — the launch gate exists; per-route guards do not.

## What exists: the launch gate

`AppGate.resolve` is the only guard in the app. It runs once, after the splash,
and picks the first real screen from two checks in strict order — session first,
onboarding flag second. Full table in `flows/app_launch.md`.

`AppGate.resolve` is a **pure function** (`app_gate.entity.dart`) called from
`AppRouter._leaveSplash` once `session.ready` completes. It is deliberately not
inside `_redirect` — the splash has to hold for its animation, which a redirect
cannot express. `_redirect` does one thing only: hold on `/splash` while
`SessionState.status` is `unknown`.

It guards **entry into the app**, not individual routes.

Key properties:

- `await session.ready` before branching. `AuthStatus.unknown` is never a valid
  input to a decision.
- Authentication outranks the onboarding flag unconditionally.
- A failed restore (401/403) is not an error state — the token is cleared and the
  device is treated as a guest, falling through to the onboarding check.
- A transport failure during restore keeps the session (Sanctum tokens do not
  expire server-side).

## What does not exist

- **Per-route auth guards.** No screen refuses to build for a guest. Nothing
  currently needs to — Home is a placeholder — but any authenticated feature
  screen will need one. The mechanism to express it exists: a guest-guarded
  action adds `RequireAuthentication` to the session bloc, which raises the
  `authenticationRequired` signal.
- **Profile-completion guards** (Track 17).
- **Deep-link guards.** Deep links are not implemented at all.

## Session-expired handling (DONE)

`AuthInterceptor` (`docs/core/interceptors.md`) raises a 401/403 on an
authenticated, non-auth-lifecycle request through `ApiClient.reportUnauthorized`
(broadcast `unauthorizedStream`, once per burst). The app layer routes it back
to auth:

```text
401/403 (authenticated, non-lifecycle)
  -> ApiClient.unauthorizedStream fires   (once per burst)
  -> (app) SessionBloc.add(UnauthorizedDetected())
  -> token cleared, then ONE emission:
       status: guest, client: null, signal: sessionExpired
  -> AppRouter listener -> router.go(/auth)          <- replaces the stack
  -> SignalAcknowledged + apiClient.resetUnauthorizedSignal()
```

`_onUnauthorizedDetected` clears the token **before** it emits, so a burst of
401s produces exactly one expiration and one redirect. A synchronous `_expiring`
latch closes the window during the `await` — the emitted-signal guard alone
cannot, because the signal is not set until after the clear completes.

`go` versus `push` is the contract:

- **`sessionExpired` → `router.go`** replaces the stack, so a dead-session
  screen can never be back-navigated into.
- **`authenticationRequired` → `router.push`** puts the auth entry **on top**,
  so back returns to the guest destination the user was on.

While a `sessionExpired` signal is unacknowledged, `SessionAuthenticated` is
ignored — a stale auth success cannot resurrect a session that just died.
Full wiring: `app.router.dart`, `auth_coordination.entity.dart`.

## Verification

```bash
cd apps/client_app && flutter test test/app_gate_test.dart
```
