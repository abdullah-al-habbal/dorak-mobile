# Networking

Status: `DONE`

## Purpose

`packages/core` provides the single networking architecture for all Dorak apps. Apps must not introduce a second HTTP stack; every outbound request goes through `ApiClient`.

## Contracts

* Backend envelope (`Modules\Core\Helpers\ApiResponseTrait`):
  `{success, statusCode, code, message, timestamp, data, meta?, errors?}`.
* Success codes: `SUCCESS`, `CREATED`, `UPDATED`, `DELETED`.
* Error codes: `BAD_REQUEST`, `VALIDATION_FAILED`, `UNAUTHORIZED`, `FORBIDDEN`, `RESOURCE_NOT_FOUND`, `CONFLICT`, `UNPROCESSABLE_ENTITY`, `TOO_MANY_REQUESTS`, `SERVER_ERROR`.

## ApiClient

Thin typed wrapper over Dio (`lib/src/network/api.client.dart`). Construction:

```dart
final client = ApiClient(
  baseUrl: ConfigProvider.config.apiBaseV1Url,
  localeResolver: () => 'en',
  tokenProvider: () async => null,   // enables AuthInterceptor
  enableLogging: kDebugMode,
  maxRetries: 3,
);
```

`ApiClient` requires an explicit `baseUrl` — no hardcoded defaults. Resolve it
from the environment-backed `ConfigProvider` (see below). Timeouts: connect 15 s,
receive 30 s. Verbs: `get`, `post`, `put`, `patch` (parser-typed), `delete`,
`getPaginated`.

`ApiClient` never leaks raw `DioException`s. Transport failures become
`NetworkException`; envelope failures become `ApiException` /
`ValidationException` (see `core/exceptions.md`).

## Config & Base URL

Configuration lives in each app's `.env` file (loaded at startup via
`flutter_dotenv`), accessed through the `core` config module:

* `lib/src/config/app_config.entity.dart` — `AppConfig` value object
  (`apiBaseUrl`, `apiBaseV1Url`).
* `lib/src/config/config.provider.dart` — `ConfigProvider.config` builds
  `AppConfig` from `dotenv`, throwing if not loaded.

Each app declares `.env` as an asset and loads it in `main()`:

```dart
Future<void> main() async {
  await dotenv.load();
  runApp(const DorakApp());
}
```

Environment keys:

| Key | Value |
| --- | --- |
| `API_BASE_URL` | `https://dev-dorak-backend.io/api` |
| `API_BASE_URL_V1` | `https://dev-dorak-backend.io/api/v1` |

Commit `.env.example`; keep `.env` (with real values) out of version control.

## Pagination

Backend paginated responses carry `meta.pagination`:

```json
{"total": 25, "count": 2, "per_page": 15, "current_page": 1, "total_pages": 2}
```

Decode with `getPaginated`, which returns `PaginatedData<T>`:

```dart
page.data;              // List<T> — the field is `data`, not `items`
page.meta.currentPage;  // 1-based
page.meta.perPage;
page.meta.totalPages;
```

`getPaginated` validates the envelope like every other verb — a `success: false`
body or `statusCode >= 400` **throws**. An API or network failure is never
turned into a successful empty page; that distinction is what makes an empty
state meaningful.

Paging **state** is app-layer Bloc work over the `Paged<T>` contract — the
legacy `PagePaginationNotifier` / `ScrollPaginationNotifier` `ChangeNotifier`s
were deleted in Phase 4 (see `state_management/pagination.md`).

## Repositories

Network calls live behind repository interfaces (`*.repository.dart`),
e.g. `OnboardingConfigRepository` + `DioOnboardingConfigRepository`.
`DioOnboardingConfigRepository` caches per locale in memory.

## Verification

```bash
melos run analyze
melos run test
```
