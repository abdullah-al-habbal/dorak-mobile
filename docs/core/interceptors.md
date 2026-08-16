# Interceptors & API Infrastructure

Status: `DONE`

## Purpose

Request/response plumbing shared across all apps, registered once in
`ApiClient` (`lib/src/network/api.client.dart`). Registration order:

```text
Locale → [Auth] → [Logging] → Retry
```

## LocaleInterceptor

Sends the current locale on every request. `ApiClient.localeResolver`
returns the active `Locale`; the interceptor sets `Accept-Language`
(and `?locale=` where a handler expects it). Falls back to `'en'`.

## AuthInterceptor

Adds `Authorization: Bearer <token>` when a `tokenProvider` is supplied.
Provider returns `null`/empty → header omitted. Token rotation happens
outside the interceptor (session layer).

### Global 401/403 detection (Track 12)

`AuthInterceptor.onError` watches responses for a dead session and raises it
through a single channel:

```text
401/403 + bearer attached + not an auth-lifecycle path
        -> UnauthorizedNotifier.fire()
        -> (app layer) SessionController.handleUnauthorized() -> redirect
```

Conditions — all three must hold before anything fires:

* `response.statusCode` is `401` or `403` (treated identically).
* The outgoing request carried `Authorization: Bearer` — a guest's request has
  no token, so its 401s are not session expiries.
* The path is not an auth-lifecycle route. `AuthEndpoints` declares ten
  lifecycle routes (`login`, `register`, `logout`, `refresh-token`,
  `forgot-password`, `reset-password`, `email/verify`, `email/verify/send`,
  `password`) plus the dynamic `/client/social/*`; all are exempt because they
  own their own 401 semantics in the repository/session layers. `refresh-token`
  is the restore probe — its 401 must keep meaning "clear token, guest", not
  "session expired". Every other authenticated route (future `/client/profile`
  etc.) correctly triggers the global state.

401/403 are **not** retryable, so `RetryInterceptor` never re-dispatches them —
no infinite-loop risk. The interceptor always calls `handler.next(err)`; the
error still surfaces as an `ApiException` at the call site, so existing
call-site error handling is unchanged.

`UnauthorizedNotifier` (`lib/src/network/unauthorized.notifier.dart`) fires at
most **once per burst**: concurrent 401/403 responses collapse into a single
`fire()`, and the app layer calls `reset()` after handling. This is what
prevents double navigations and repeated token clears under load.

## LoggingInterceptor

`kDebugMode`-gated request/response logging. No-op in release builds.
Logs method, path, status, latency.

## RetryInterceptor

Retries idempotent requests (`GET`, `PUT`, `PATCH`, `DELETE`) on transient
failures: connect/send/receive timeouts, connection errors, HTTP 429, and
any 5xx. `POST` is never retried.

* `maxRetries` (default 3), exponential backoff `500ms * 2^(attempt-1)`.
* Per-request attempt count stored in `requestOptions.extra['retry_count']`.
* `RetryInterceptor.isRetryable(err)` is public so `ApiClient._guard` can
  flag `NetworkException.retryable` consistently.

## Endpoints

Domain-split endpoint declarations (`lib/src/network/endpoints/*.endpoints.dart`)
instead of monolithic route files. Export via `endpoints.barrel.dart`.

## DTO Mapping

`*.dto.dart` classes own JSON parsing and MUST use `build_runner` +
`json_serializable` codegen (see `architecture/coding_conventions.md` and
`CLAUDE.md` § 4b). Examples: `OnboardingConfigDto`
(`{hero_image_url, season, locale}`), `PaginationMeta`, `ApiResponse<T>`,
`PaginatedData<T>`. Parsers are injected into verbs as `JsonParser<T>`;
DTOs stay free of Dio/transport types. Regenerate after edits:
`melos run build`.
