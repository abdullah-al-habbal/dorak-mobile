# AGENTS.md — `packages/core`

Infrastructure package: HTTP, config, storage, session, DTOs, exceptions.
No UI, no strings.

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)

---

## 1. Layout

```
lib/core.dart                            root barrel — 4 section barrels
lib/src/
  config/
    app_config.entity.dart               AppConfig {apiBaseUrl, apiBaseV1Url}
    config.provider.dart                 ConfigProvider.config, from dotenv
    config.barrel.dart
  network/
    api.client.dart                      ApiClient + JsonParser<T>
    api_response.dto.dart                ApiResponse<T> envelope
    paginated_data.dto.dart              PaginatedData<T>
    pagination_meta.dto.dart             PaginationMeta
    network.barrel.dart
    dto/                                 auth_response · client · onboarding_config · token_response
    endpoints/                           app · auth (+ endpoints.barrel.dart, orphaned)
    exceptions/                          api · network · validation
    interceptors/                        auth · locale · logging · retry
    pagination/                          page_pagination · scroll_pagination notifiers
    repositories/                        auth · onboarding_config
  session/
    auth_status.entity.dart              AuthStatus enum
    session.notifier.dart                SessionController
    session.barrel.dart
  storage/
    token.storage.dart                   TokenStorage + SecureTokenStorage
    preferences.storage.dart             AppPreferences + SharedAppPreferences
    storage.barrel.dart
```

Empty directories left from scaffolding: `src/models/{branch,currency,user}/`,
`src/utils/{formatters,validators}/`. Nothing lives there yet.

Consumers import **only** `package:core/core.dart`.

## 2. Config

```dart
ConfigProvider.config.apiBaseV1Url   // throws StateError if dotenv not loaded
```

Keys, per app `.env` (gitignored; `.env.example` committed):

```
API_BASE_URL=https://dev-dorak-backend.io/api
API_BASE_URL_V1=https://dev-dorak-backend.io/api/v1
```

There is no local-dev profile — no `localhost` or `10.0.2.2` anywhere.

## 3. ApiClient

```dart
ApiClient(
  baseUrl: ConfigProvider.config.apiBaseV1Url,
  localeResolver: () => 'en',
  tokenProvider: tokenStorage.read,   // omit -> AuthInterceptor is NOT installed
  enableLogging: kDebugMode,
  maxRetries: 3,
);
```

Verbs: `get` `post` `put` `patch` `delete` `getPaginated`. Each parser-typed
except `delete`. Timeouts: connect 15 s, receive 30 s.

Interceptor order: `Locale → [Auth] → [Logging] → Retry`.
`RetryInterceptor` covers `GET/PUT/PATCH/DELETE` on timeouts, connection
errors, 429 and 5xx, with `500ms * 2^(attempt-1)` backoff. **`POST` is never
retried.**

### Envelope

```json
{"success": bool, "statusCode": int, "code": "SUCCESS", "message": "...",
 "timestamp": "...", "data": ..., "meta": {...}, "errors": {...}}
```

`_parse` returns `body['data']`. `data`/`meta`/`errors` are **omitted** when
empty, not null — a parser must tolerate `null`. `getPaginated` reads
`meta.pagination`.

### Exceptions

| Type | Trigger | Carries |
|---|---|---|
| `ValidationException` | `code == 'VALIDATION_FAILED'` | `errors` as `Map<String, List<String>>`, `errorsFor(field)` |
| `NetworkException` | no response body | `type` (`DioExceptionType`), `retryable`; `statusCode` 0, `code` `NETWORK_ERROR` |
| `ApiException` | everything else | `statusCode`, `code`, `message`; `isUnauthorized`/`isForbidden`/`isNotFound`/`isRateLimited`/`isServerError` |

Non-envelope payload → `ApiException(status, 'INVALID_RESPONSE')`.

## 4. Repositories

`AuthRepository` / `DioAuthRepository` — `login`, `register`, `logout`,
`refreshToken`, `sendEmailVerification`, `verifyEmail`, `forgotPassword`,
`resetPassword`.

`OnboardingConfigRepository` / `DioOnboardingConfigRepository` —
`GET /app/onboarding-config`, cached per locale in memory.

`AuthEndpoints` declares 10 routes; the repository covers 8.
`changePassword` and `socialLogin(provider)` have constants but **no method**.

## 5. Session

`SessionController extends ChangeNotifier` over `AuthRepository` +
`TokenStorage`.

```dart
AuthStatus get status;      // unknown | authenticated | guest
ClientDto? get client;
bool get isAuthenticated;
bool get isLoading;
Object? get error;
Future<void> get ready;     // memoised restore()
```

`restore()`:

```
no stored token          -> guest
refreshToken() succeeds  -> persist rotated token, authenticated
  401 / 403              -> clear token, guest
  NetworkException       -> authenticated, token kept
  other ApiException     -> authenticated, token kept
```

`logout()` swallows the network failure and always clears local state.
Everything else rethrows.

## 6. Storage

| Contract | Impl | Key |
|---|---|---|
| `TokenStorage` | `SecureTokenStorage` | `dorak_client_token` (secure) |
| `AppPreferences` | `SharedAppPreferences` | `dont_show_onboarding` (prefs) |

`SecureTokenStorage.read()` normalises `''` to `null`.
`AppPreferences.dontShowOnboarding` is a **synchronous** getter — the launch
gate branches on it with no await. Build it once with
`await SharedAppPreferences.create()`; that factory exists so apps never
declare `shared_preferences` themselves.

## 7. Adding things

| Task | Steps |
|---|---|
| New endpoint | add the constant to the matching `*.endpoints.dart`, then a method on the repository. Never inline a path string. |
| New wire model | `dto/<name>.dto.dart` with `@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)` + `part`, export from `network.barrel.dart`, run `melos run build` |
| New backend domain | new `<domain>.endpoints.dart` + `<domain>.repository.dart`; do not extend `auth.endpoints.dart` |
| New persisted value | extend `AppPreferences` (non-secret) or `TokenStorage` (secret), keep the abstract contract |
| New shared async state | **not** a `.notifier.dart`. Transitional `ChangeNotifier` here is legacy (pagination) or Track 12 session infra; new state goes to app-layer `Bloc`s. Extend this package only when a repository/stream seam is missing |

## 8. Gotchas

- **`AuthInterceptor` only installs when `tokenProvider != null`.** Omitting it
  silently produces unauthenticated requests with no error.
- **`endpoints.barrel.dart` is orphaned** — `network.barrel.dart` exports both
  endpoint files directly. Do not rely on the barrel.
- **`register()` must send `password_confirmation`.** The backend applies
  Laravel's `confirmed` rule; omitting it 422s every signup.
- **Logout and verify return no `data` key.** Use a parser that ignores its
  argument (`_discardBody`), not one that casts.
- **A guard 401 bypasses the envelope**, arriving as bare
  `{"message":"Unauthenticated."}` → `ApiException(401, 'UNKNOWN')`. Branch on
  `isUnauthorized`, never on `code`.
- **Backend `message` is an untranslated key** (`core::messages.*`). Core
  passes it through unchanged; UI must never render it.
- **There is no `GET /client/me`** — which is why `restore()` probes with
  `refresh-token`.
- **`NetworkException` exposes `DioExceptionType`**, so any package
  constructing one in a test needs a `dio` dev dependency.
- **A 401/403 on an authenticated request is reported, not swallowed.**
  `ApiClient.unauthorizedNotifier` emits (`UnauthorizedNotifier`,
  Track 12); `client_app`'s `SessionController.handleUnauthorized()` then
  surfaces the session-expired notice and the router redirects to auth.

## 9. Tests

`packages/core/test/` — 59 tests.

| File | Covers |
|---|---|
| `api_client_test.dart` | envelope parse, 422, 404, invalid payload, transport error, all verbs, pagination |
| `retry_interceptor_test.dart` | retry on 5xx, give-up, POST not retried |
| `auth_repository_test.dart` | request bodies incl. `password_confirmation`, no-`data` responses, 401/422 mapping |
| `session_controller_test.dart` | all four `restore()` branches, `ready` idempotence, login/register/verify/logout |
| `unauthorized_notifier_test.dart` | Track 12: 401/403 emission on authenticated requests |
| `storage_test.dart` | preference defaults + round-trip |
| `pagination_test.dart`, `onboarding_config_repository_test.dart` | as named |

Helpers: `test/helpers/fake_dio.dart` (interceptor-based fake, envelope
builders, `clientWith`), `test/helpers/fake_auth.dart` (`InMemoryTokenStorage`,
`InMemoryAppPreferences`, scriptable `FakeAuthRepository`, `unauthorized()`,
`offline()`). No mocking package — do not add one.

## 10. Commands

```bash
cd dorak-mobile
dart run melos run build     # after a DTO change
dart run melos run analyze
dart run melos run test
```
