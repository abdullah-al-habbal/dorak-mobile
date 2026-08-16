# Session Management

Status: `DONE`

## Purpose

`SessionBloc` (`packages/core/lib/src/session/session.bloc.dart` + `.event.dart`
+ `.state.dart`) owns the authenticated-session lifecycle: restoration, login,
registration, email verification, logout. It is a pure `bloc` — **no Flutter
dependency** — over `AuthRepository` + `TokenStorage`. UI never calls it
directly; it dispatches `SessionEvent`s and reads `SessionState`.

Success and failure never rethrow: mutating events emit `isLoading`, land
failures in `state.error`, and set a one-shot `SessionNotice` on success. The
app layer maps errors via `AuthError.from` and drives navigation from notices.

## State

`AuthStatus` (`auth_status.entity.dart`): `unknown | authenticated | guest`.

`unknown` is the pre-restore value. **Callers must not branch on it** — await
`ready` first.

```dart
SessionState {
  AuthStatus status;
  ClientDto? client;
  bool isAuthenticated;
  bool isLoading;
  Object? error;
  SessionNotice notice;
}
Future<void> get ready;   // completes when restore has resolved status
```

`ready` memoises the restore pass (`_restoration ??=`), so concurrent awaiters
join the in-flight restore instead of firing a second one. Re-adding
`RestoreRequested` after `ready` would run the probe again — don't.

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

`LoginRequested`, `RegisterRequested`, `VerifyEmailRequested` go through a
shared `_run` helper: emit `isLoading`, run the action, then emit the success
state + notice, or emit `error` on failure. Screens observe `state.error` /
`state.isLoading` through a `BlocBuilder`.

`LogoutRequested` is the exception: it swallows the network failure, always
clears local storage, and emits a fresh `guest` state.

`SendVerificationCodeRequested` swallows errors — registration already
succeeded and the token is stored; a failed dispatch must not block the verify
screen, which has Resend.

`RegisterRequested` requires `passwordConfirmation` — the backend applies
Laravel's `confirmed` rule and rejects the request without it.

## Token attachment

`ApiClient` receives `tokenProvider: tokenStorage.read`, which activates
`AuthInterceptor`. The provider reads storage directly rather than the bloc, so
`SessionBloc -> ApiClient` stays a one-way dependency.

## Global notices

`SessionNotice` (`none | sessionExpired | authenticationRequired |
loginSucceeded | registrationSucceeded | verificationSucceeded`) is the
router's one-shot navigation signal.

Unauthorized flow:

* `ApiClient` owns a broadcast `unauthorizedStream`. `AuthInterceptor` calls
  `reportUnauthorized()` on a 401/403 for an authenticated, non-lifecycle
  request; the client fires **once per burst** and stays silent until
  `resetUnauthorizedSignal()`, so a burst of concurrent 401s collapses into one
  notification.
* The app layer forwards the signal to `UnauthorizedDetected`. The bloc dedupes
  against an already-raised `sessionExpired`, clears the token, drops to
  `guest`, and raises the notice.
* `RequireAuthentication` raises `authenticationRequired` (guest-guarded
  action) without touching the session.
* `NoticeAcknowledged` clears the notice — the app layer sends it after
  navigating, re-arming the signal for the next burst.

Any mutating event resets `notice` to `none`, so a fresh auth attempt clears a
stale prompt.

The app layer (`AppRouter`, see `navigation/guards.md`) owns **one** session
stream listener that re-runs the router redirect and reacts to notices. Core
never imports app code and never navigates.

## Not yet implemented

Password recovery (`forgotPassword` / `resetPassword` exist on the repository
but no screen calls them), social login, `changePassword`, and profile
endpoints. Logout has a bloc handler but no UI affordance.

## Verification

```bash
dart run melos run analyze
dart run melos run test   # packages/core/test/session_bloc_test.dart
```
