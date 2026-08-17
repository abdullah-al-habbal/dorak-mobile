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

**`docs/state_management/conventions.md` is the canonical state contract.** This
page covers only the transport-to-application error boundary; everything about
how a bloc represents loading, success, empty, error, retry, refresh and
pagination lives there.

* Async UI state is expressed with explicit loading/error/data (see
  `state_management/async_state.md`, and `state_management/pagination.md` for
  the paging story).
* `OnboardingConfigBloc` (`apps/client_app/.../onboarding_config.bloc.dart`,
  pure `bloc` over an `OnboardingConfigRepository`) holds config + `isLoading`
  + `error` with silent fallback to bundled assets, and reloads on locale
  switch. `ChangeNotifier` is not a target pattern and no new instances may be
  added.

## Verification

```bash
melos run analyze
melos run test
```
