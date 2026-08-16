# Backend-Driven Default Page Size (`pagination.per_page`)

Status: `DEFERRED` — not implemented. Codified for future execution.

## Problem

Both pagination notifiers in `packages/core` (legacy `ChangeNotifier`,
transitional until Phase 4) hardcode a default page size:

```dart
// page_pagination.notifier.dart
PagePaginationNotifier({required this.fetch, this.perPage = 15});

// scroll_pagination.notifier.dart
ScrollPaginationNotifier({required this.fetch, this.perPage = 15});
```

The value `15` is duplicated in the client and cannot change without an app
release. The backend already returns the authoritative page size in every
paginated envelope (`meta.pagination.per_page`), so the client should learn
it once and reuse it everywhere.

## Goal

On app start, the client fetches the small set of application-wide settings
it needs (starting with `pagination.per_page`) from a new backend
`ApplicationSetting` key-value store. Pagination notifiers then default to
the server-provided `per_page` instead of a hardcoded literal.

## Backend — `Modules\ApplicationSetting`

New module, following the existing module pattern (cf. `Modules\Onboarding`,
`Modules\Currency`).

### Model

`modules/ApplicationSetting/Models/ApplicationSettingModel.php`

| Column | Type | Notes |
| :--- | :--- | :--- |
| `key` | string | Unique, dotted path, e.g. `pagination.per_page`. |
| `value` | json | Typed value (string / int / bool / json). |
| `group` | string? | Optional grouping, e.g. `pagination`. |
| `is_public` | boolean | App-facing key; only public keys are served. |
| `is_active` | boolean | Soft enable/disable of a key. |

Enforce `key` uniqueness at the database level.

### Migration

`modules/ApplicationSetting/Database/Migrations/2026_MM_DD_HHMMSS_create_application_settings_table.php`

Creates `application_settings` with the columns above + timestamps.

### Seeder

`modules/ApplicationSetting/Database/Seeders/ApplicationSettingSeeder.php`

Seeds the default page size so the endpoint always has a value:

```php
['key' => 'pagination.per_page', 'value' => 15, 'group' => 'pagination', 'is_public' => true, 'is_active' => true]
```

### Endpoint

`GET /api/v1/app/settings` — public, same style as
`Modules\Onboarding\Routes\Api\V1\onboarding-config.php`.

Behavior:

* Optional `?keys[]=pagination.per_page` filter — client requests only the
  keys it needs. No filter → return all `is_public` && `is_active` keys.
* Response envelope: `{success, data: {settings: [{key, value}]}}`.
* Unknown/inactive keys are silently omitted (never 404 the whole call).
* `per_page` must be an integer ≥ 1; the server clamps invalid stored values.

Caching: file/database cache per key with a short TTL (e.g. 5 min); the
settings endpoint is hot on app cold-start.

## Client — `packages/core` + `apps/client_app`

### Fetch on app start

* New `AppSettingsRepository` + `DioAppSettingsRepository` in
  `packages/core` (dot-suffix `.repository.dart`), endpoint in
  `app.endpoints.dart` (`appSettings`).
* New `AppSettingsController` (`ChangeNotifier`) constructed at bootstrap in
  `apps/client_app/lib/main.dart` (mirror of
  `OnboardingConfigController`). Requests only needed keys, e.g.
  `['pagination.per_page']`.
  > Architecture note (Phase 2): new app state is Pure Bloc — implement this
  > as a `SettingsBloc`, not a `ChangeNotifier`. The spec above is otherwise
  > unchanged.
* Default `perPage`: `pagination.per_page` from settings, falling back to
  `15` while loading or on failure (never blocks startup).

### Wire into pagination

* `PagePaginationNotifier` / `ScrollPaginationNotifier` keep their optional
  `perPage` parameter (explicit callers still override), but default it
  from the settings controller instead of a literal:

```dart
final pager = PagePaginationNotifier(
  fetch: repository.fetchBranches,
  perPage: appSettings.paginationPerPage, // default 15 while unknown
);
```

* No change to `ApiClient.getPaginated` — it already forwards
  `queryParameters` including `per_page`.

## Acceptance Criteria

1. `pagination.per_page` seeded in backend; endpoint returns it.
2. App fetches settings once at startup; pagination uses server `per_page`.
3. Server value change (e.g. 15 → 20) takes effect after next app start with
   no client release.
4. Settings fetch failure → client falls back to 15, feature degrades
   gracefully.

## Out of Scope

* Admin UI for editing settings (Filament resource or settings page) — can be
  a follow-up; seeding suffices initially.
* Additional keys beyond `pagination.per_page`.

## Verification (when implemented)

```bash
melos run verify
```

plus backend tests for the settings endpoint (filter, clamping, public-only).
