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
