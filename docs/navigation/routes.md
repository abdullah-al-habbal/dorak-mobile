# Routes

Status: `IN_PROGRESS` — go_router route table in place; deep links and nested
navigation not yet.

## Approach

**`go_router` only** — declarative route table with redirects. No Navigator 1.0,
no `AppNavigator`, no named-route strings. Navigation lives in
`apps/client_app/lib/src/core/navigation/`:

| File | Owns |
| --- | --- |
| `app.router.dart` | `AppRouter` — constructs the `GoRouter`, owns the redirect (`AppGate.decide` + session-expired) and all flow wiring (`router.push/go` passed into screens as callbacks) |
| `app_routes.entity.dart` | `AppRoutes` — path constants (`/splash`, `/auth`, `/auth/login`, `/auth/register`, `/auth/verify`, `/onboarding/welcome|discovery|booking|ai-style`, `/home`) |
| `app_gate.entity.dart` | `AppGate.decide` — the post-splash branch, invoked from the router redirect |

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
/home                            HomeScreen (placeholder)
```

Flow wiring lives in `AppRouter._routes()`: each `GoRoute` receives callbacks
(`onNext`, `onSkipForNow`, `onLogin`, ...) that the router implements with
`router.push`/`router.go`. `context.go('/home')` clears the stack by
construction — there is no `pushAndRemoveUntil` bookkeeping.

## The redirect

`AppRouter._redirect` is the single entry point for guard logic:

- Launch gate: `AppGate.decide` after the splash (see `flows/app_launch.md`).
- Session-expired: a 401/403 on an authenticated request → session-expired
  signal → `router.push<void>(AppRoutes.authEntry)` (see `guards.md`).

## Taxonomy

`.router.dart` and `.bloc.dart`/`.event.dart`/`.state.dart` are the current
navigation/state roles (registered in `CLAUDE.md` §1, enforced by
`tool/check_taxonomy.dart`, `apps/*` only). `.navigator.dart` is **deprecated** —
removed from `client_app` in Phase 2; tolerated only in the `business_app` /
`stylist_app` stubs.

## Not implemented

Deep links, notification-driven navigation, nested navigation, and route-level
analytics. See `navigation/guards.md` for the guard gap.
