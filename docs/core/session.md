# Session Management

Status: `DONE`

## Purpose

`SessionController` (`packages/core/lib/src/session/session.notifier.dart`) owns
the authenticated-session lifecycle: restoration, login, registration, email
verification, logout.

It is a `ChangeNotifier` + repository, exposing state plus `isLoading` and
`error`. **Status: transitional.** The session layer predates the locked Pure
Bloc architecture; it stays as a `ChangeNotifier` until Phase 4 replaces it
with a `SessionBloc`/`AuthBloc` over an `AuthenticationRepository`, and the
unauthorized wiring with a Stream-based signal. Do not extend it — no new
`ChangeNotifier` state anywhere.

## State

`AuthStatus` (`auth_status.entity.dart`): `unknown | authenticated | guest`.

`unknown` is the pre-restore value. **Callers must not branch on it** — await
`ready` first.

```dart
AuthStatus get status;
ClientDto? get client;
bool get isAuthenticated;
bool get isLoading;
Object? get error;
Future<void> get ready;   // completes when restore() has resolved status
```

`ready` memoises the restore, so repeated awaits join the in-flight call instead
of firing a second one.

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

`login`, `register`, `sendVerificationCode`, `verifyEmail` all **rethrow** so
the calling screen can branch on `ValidationException` for per-field errors;
`error` is recorded for listeners as well.

`logout` is the exception: it swallows the network failure and clears local
state regardless. A token we can no longer reach is worse than one the server
still holds.

`register` requires `passwordConfirmation` — the backend applies Laravel's
`confirmed` rule and rejects the request without it.

## Token attachment

`ApiClient` receives `tokenProvider: tokenStorage.read`, which activates
`AuthInterceptor`. The provider reads storage directly rather than the
controller, so `SessionController -> ApiClient` stays a one-way dependency.

## Global notices (Track 12)

`SessionController` broadcasts two global UI states through `notice`
(`SessionNotice`: `none | sessionExpired | authenticationRequired`):

* `handleUnauthorized()` — called by the app layer when `AuthInterceptor`
  fires `UnauthorizedNotifier` on a 401/403. Clears the token, drops to
  `guest`, and raises `sessionExpired`. The notice is set **synchronously**
  before the storage clear, so a burst of concurrent 401s collapses into one
  clear and one notification.
* `requireAuthentication()` — raised by any guest-guarded action. Broadcasts
  `authenticationRequired` without touching the session.
* `acknowledgeNotice()` — the app layer calls this after handling a notice
  (typically after navigating), re-arming the notifier for the next burst.

Any mutating call (`restore`, `login`, `register`, `verify`, `logout`) resets
`notice` to `none`, so a fresh auth attempt clears a stale prompt.

The app layer (`AppRouter`, see `navigation/routes.md`) listens to the
notifier and the notice and owns all redirect navigation — core never imports
app code and never navigates.

## Not yet implemented

Password recovery (`forgotPassword` / `resetPassword` exist on the repository
but no screen calls them), social login, `changePassword`, and profile
endpoints.

## Verification

```bash
dart run melos run analyze
dart run melos run test   # packages/core/test/session_controller_test.dart
```
