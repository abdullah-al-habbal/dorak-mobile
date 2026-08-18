# Routes

Status: `IN_PROGRESS` — go_router route table in place; deep links and nested
navigation not yet.

## Approach

**`go_router` only** — declarative route table with redirects. No Navigator 1.0,
no `AppNavigator`, no named-route strings. Navigation lives in
`apps/client_app/lib/src/core/navigation/`:

| File | Owns |
| --- | --- |
| `app.router.dart` | `AppRouter` — constructs the `GoRouter`, owns the redirect, the launch gate (`AppGate.resolve`) and the session/auth signal listeners, plus all flow wiring (`router.push/go` passed into screens as callbacks) |
| `app_routes.entity.dart` | `AppRoutes` — path constants (`/splash`, `/auth`, `/auth/login`, `/auth/register`, `/auth/verify`, `/onboarding/welcome|discovery|booking|ai-style`, `/home`) |
| `app_gate.entity.dart` | `AppGate.resolve` — the post-splash branch, a pure function called from `AppRouter._leaveSplash` (**not** from the redirect) |

Screens receive callbacks only and know nothing about their neighbours. Bloc
never navigates — routing responds to state through the router's redirect and
listener. **Routing lives in the router, never in a screen or a bloc.**

## The route table

```
/splash                          SplashScreen
/onboarding/welcome              -> push /onboarding/discovery ... -> /home
/onboarding/ai-style             -> context.go('/home') when finished
/auth                            AuthEntry (Continue as Guest -> go /onboarding/welcome)
/auth/login  (parent: /auth)     -> context.go('/home') on success
/auth/register (parent: /auth)   -> push /auth/verify on success
/auth/verify  (parent: /auth)    -> context.go('/home') on success or skip
/auth/forgot-password            (parent: /auth)  -> push .../otp on codeSent
/auth/forgot-password/otp        -> push /auth/reset-password on codeAccepted
/auth/reset-password             (parent: /auth)  -> push .../success on passwordReset
/auth/reset-password/success     -> go /auth/login  (go, so the stack is dropped)
/home                            HomeScreen (placeholder)
```

Password recovery (Stitch 011–014) is driven by `RecoverySignal`, a third one-shot
signal alongside `SessionSignal` and `AuthSignal`. Its wrinkle is worth knowing
before touching it: the backend has no verify-reset-code endpoint, so the OTP screen
cannot validate the code and a rejected code surfaces on `/auth/reset-password`. See
`authentication/password_recovery.md`.

Flow wiring lives in `AppRouter._routes()`: each `GoRoute` receives callbacks
(`onNext`, `onSkipForNow`, `onLogin`, ...) that the router implements with
`router.push`/`router.go`. `context.go('/home')` clears the stack by
construction — there is no `pushAndRemoveUntil` bookkeeping.

## The redirect and the three listeners

Guard logic is split across three places, deliberately:

| Mechanism | Owns |
| --- | --- |
| `AppRouter._redirect` | holds the app on `/splash` while `SessionState.status` is `unknown`, and nothing else |
| `AppRouter._leaveSplash` | awaits `session.ready`, then `router.go(AppGate.resolve(...))` — the launch gate (see `flows/app_launch.md`) |
| `AppRouter._onSessionChanged` / `_onAuthChanged` / `_onRecoveryChanged` | `router.refresh()` on every session change, then react to `SessionSignal` / `AuthSignal` / `RecoverySignal` |

The launch gate is **not** in `_redirect`: the splash must hold for its 2500 ms
animation, which a redirect cannot express. `AppGate.resolve` is a pure function
(`app_gate.entity.dart`) and is unit-testable without pumping a widget.

**`go` vs `push` is a contract, not a detail:**

| Signal | Call | Why |
| --- | --- | --- |
| `SessionSignal.sessionExpired` | `router.go(/auth)` | **replaces** — no dead-session screen survives to be back-navigated into |
| `SessionSignal.authenticationRequired` | `router.push(/auth)` | **pushes** — back returns to the guest destination the user was on |
| `RecoverySignal.codeSent` / `codeAccepted` / `passwordReset` | `router.push(...)` | **pushes** — each recovery step stays back-navigable while the flow is in progress |
| 014's "Log In" action | `router.go(/auth/login)` | **replaces** — the code has been consumed, so a completed reset must not be re-enterable |

Each is acknowledged immediately after (`SignalAcknowledged` /
`AuthSignalAcknowledged`) together with `apiClient.resetUnauthorizedSignal()`.

## Taxonomy

`.router.dart` and `.bloc.dart`/`.event.dart`/`.state.dart` are the current
navigation/state roles (registered in `CLAUDE.md` §1, enforced by
`tool/check_taxonomy.dart`, `apps/*` only). `.navigator.dart` is **deprecated** —
removed from `client_app` in Phase 2; tolerated only in the `business_app` /
`stylist_app` stubs.

## Not implemented

Deep links, notification-driven navigation, nested navigation, and route-level
analytics. See `navigation/guards.md` for the guard gap.
