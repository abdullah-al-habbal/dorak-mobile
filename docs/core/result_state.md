# Result, Error & State Contracts

Status: `DONE`

## Purpose

Define how results, errors, and loading state flow from the transport layer
to the UI without leaking transport types.

## Envelope

`ApiResponse<T>` (`lib/src/network/api_response.dto.dart`) mirrors the
backend envelope. `ApiClient` unwraps `data`; UI never sees the raw body.

## Exception Taxonomy

See `core/exceptions.md` for the full taxonomy:

* `ApiException` — envelope/HTTP failure.
* `ValidationException` — `422 VALIDATION_FAILED` with field errors.
* `NetworkException` — transport failure, `retryable` flag.

Rules:

* Raw `DioException` never reaches UI — mapped inside `ApiClient._guard`.
* UIs treat a thrown exception as terminal state; retry is a user action.

## State Contracts

* Async UI state is expressed with explicit loading/error/data (see
  `state_management/async_state.md`).
* Pagination state is encapsulated in **legacy** `ChangeNotifier` notifiers (see
  `state_management/pagination.md`); Phase 4 replaces them with a Bloc/Stream
  story.
* `OnboardingConfigController` (`apps/client_app/.../onboarding_config.notifier.dart`)
  is a **transitional** `ChangeNotifier` + repository (config, `isLoading`,
  `error`, silent fallback to bundled assets). **Canonical new state is Pure
  Bloc** (`flutter_bloc`) at the app layer — `ChangeNotifier` is not a target
  pattern and no new instances may be added.

## Verification

```bash
melos run analyze
melos run test
```
