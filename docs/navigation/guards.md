# Guards

Status: `IN_PROGRESS` — the launch gate exists; per-route guards do not.

## What exists: the launch gate

`AppGate.decide` is the only guard in the app. It runs once, after the splash,
and picks the first real screen from two checks in strict order — session first,
onboarding flag second. Full table in `flows/app_launch.md`.

It is installed as the **router redirect** (`AppRouter._redirect`), not an
imperative post-frame push.

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
  -> signal == sessionExpired
  -> AppRouter listener -> router.push<void>(/auth)
  -> SignalAcknowledged + apiClient.resetUnauthorizedSignal()
```

A dead-session screen is never back-navigated into because the redirect runs on
the next location change. A guest-guarded action instead raises
`authenticationRequired`, which pushes the auth entry **on top** so back
returns to the previous screen. Full wiring: `app.router.dart`.

## Verification

```bash
cd apps/client_app && flutter test test/app_gate_test.dart
```
