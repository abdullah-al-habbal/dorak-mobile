# Session Management

Status: `DONE`

## Purpose

The session layer (`packages/core/lib/src/session/`) is split into two pure
`bloc`s — **no Flutter dependency**, both over `AuthRepository` +
`TokenStorage`:

* `AuthBloc` (`auth.bloc.dart` + `auth.event.dart` + `auth.state.dart`) owns the
  **active auth actions**: `LoginRequested`, `RegisterRequested`,
  `SendVerificationCodeRequested`, `VerifyEmailRequested`. It writes the returned
  token, exposes the signed-in `client`, and raises the matching `AuthSignal`.
* `SessionBloc` (`session.bloc.dart` + `session.event.dart` + `session.state.dart`)
  owns the **session truth**: `SessionBloc(AuthRepository, TokenStorage)`. It
  drives restore, logout, the unauthorized flow and signal acknowledgement. It
  has **no dependency on `AuthBloc`**: an `AuthBloc` success is coordinated by
  the app layer, which forwards it as `SessionAuthenticated(client)`
  (`session.event.dart`).

UI never calls either bloc directly; screens dispatch events and read state
through a `BlocBuilder`.

Success and failure never rethrow: auth actions emit `isSubmitting`, land
failures in `state.error`, and set a one-shot signal on success. The
app layer maps errors via `AuthError.from` and drives navigation from signals.

## State

`AuthStatus` (`auth_status.entity.dart`): `unknown | authenticated | guest`.

`unknown` is the pre-restore value. **Callers must not branch on it** — await
`ready` first.

```dart
SessionState {                 // SessionBloc — the session truth
  AuthStatus status;
  ClientDto? client;
  bool isAuthenticated;
  bool isLoading;
  Object? error;
  SessionSignal signal;
}
Future<void> get ready;   // completes when restore has resolved status

AuthState {                    // AuthBloc — active auth actions
  ClientDto? client;
  bool isSubmitting;
  Object? error;
  AuthSignal signal;
}
```

`ready` memoises the restore pass (`_restoration ??=`), so concurrent awaiters
join the in-flight restore instead of firing a second one. Re-adding
`RestoreRequested` after `ready` would run the probe again — don't.

`SessionBloc` and `AuthBloc` are **independent**. The app layer coordinates
them: it listens to the auth stream and dispatches `SessionAuthenticated`
(`status: authenticated`, same `client`) when an auth action succeeds. A
duplicate `SessionAuthenticated` for an already-authenticated client is a
no-op.

## Restoration

The backend exposes **no `GET /client/me`**, so there is no profile probe.
Validity is checked by rotating the token through
`POST /client/refresh-token`, which sits behind `auth:client`.

```text
token = await tokenStorage.read()

token == null            -> guest
refreshToken() succeeds  -> persist rotated token, authenticated
  ApiException 401/403   -> clear token, guest
  NetworkException       -> authenticated  (token kept)
  other ApiException     -> authenticated  (token kept)
```

The transport-failure branch is deliberate: Sanctum tokens have **no
server-side expiry** (`SANCTUM_EXPIRATION` is unset), so an unreachable server
is no evidence the session ended. Logging the user out on a flaky start would be
strictly worse.

Note that Laravel's guard returns a bare `{"message":"Unauthenticated."}` rather
than the API envelope, so `ApiClient` maps it to `ApiException(401, 'UNKNOWN')`.
Branch on `isUnauthorized`, never on `code`.

## Mutations

`LoginRequested`, `RegisterRequested`, `VerifyEmailRequested` (on `AuthBloc`)
go through a shared `_run` helper: emit `isSubmitting`, run the action, then
emit the success state + signal, or emit `error` on failure. Screens observe
`state.error` / `state.isSubmitting` through a `BlocBuilder`.

`LogoutRequested` (on `SessionBloc`) is the exception: it swallows the network
failure, always clears local storage, and emits a fresh `guest` state.

`SendVerificationCodeRequested` (on `AuthBloc`) swallows errors — registration
already succeeded and the token is stored; a failed dispatch must not block the
verify screen, which has Resend.

`RegisterRequested` requires `passwordConfirmation` — the backend applies
Laravel's `confirmed` rule and rejects the request without it.

## Token attachment

`ApiClient` receives `tokenProvider: tokenStorage.read`, which activates
`AuthInterceptor`. The provider reads storage directly rather than the bloc, so
`SessionBloc -> ApiClient` stays a one-way dependency.

## Global signals

Signals are split by owner, so each bloc's state is type-safe:

* `SessionSignal` (`none | sessionExpired | authenticationRequired`) lives on
  `SessionState`. `SessionBloc` raises `sessionExpired` (`UnauthorizedDetected`)
  and `authenticationRequired` (`RequireAuthentication`).
* `AuthSignal` (`none | loginSucceeded | registrationSucceeded |
  verificationSucceeded`) lives on `AuthState`. `AuthBloc` raises the matching
  value on auth success.

The router subscribes to **both** streams and switches each state's own signal
type, so a stale signal on one side never steers the other.
`registrationSucceeded` is the only signal that carries follow-up work: the
router dispatches `SendVerificationCodeRequested` and pushes the verify screen
with the client's email as `extra`.

Unauthorized flow:

* `ApiClient` owns a broadcast `unauthorizedStream`. `AuthInterceptor` calls
  `reportUnauthorized()` on a 401/403 for an authenticated, non-lifecycle
  request; the client fires **once per burst** and stays silent until
  `resetUnauthorizedSignal()`, so a burst of concurrent 401s collapses into one
  notification.
* The app layer forwards the signal to `UnauthorizedDetected`. The session bloc
  dedupes against an already-raised `sessionExpired`, clears the token, drops to
  `guest`, and raises the signal.
* `RequireAuthentication` raises `authenticationRequired` (guest-guarded
  action) without touching the session.
* `SignalAcknowledged` clears a **session** signal; `AuthSignalAcknowledged`
  clears an **auth** signal — the app layer sends each after navigating,
  re-arming the signal channel for the next burst.

Any auth mutating event resets `signal` to `none`, so a fresh auth attempt
clears a stale prompt.

The app layer (`AppRouter`, see `navigation/guards.md`) owns the two stream
listeners that re-run the router redirect and react to signals. Core never
imports app code and never navigates.

## Not yet implemented

Password recovery (`forgotPassword` / `resetPassword` exist on the repository
but no screen calls them), social login, `changePassword`, and profile
endpoints. Logout has a bloc handler but no UI affordance.

## Verification

```bash
dart run melos run analyze
dart run melos run test   # packages/core/test/{session_bloc,auth_bloc}_test.dart
```
