# Async State

Status: `DONE`

How a bloc represents the lifecycle of an asynchronous operation. Rules live in
[`conventions.md`](./conventions.md) §4–§5; this page is the matrix and the
worked examples.

---

## The five conditions

Every async surface distinguishes five conditions. They are **fields on one flat
state class**, never a sealed subclass hierarchy.

| Condition | Expressed as | Never |
|---|---|---|
| Initial | the `const` default constructor | conflated with loading or empty |
| Loading | `isLoading` (read) / `isSubmitting` (write) | both at once for one operation |
| Success | `error == null` and data present | a separate `isSuccess` flag |
| Empty | `success && data.isEmpty` | rendered as an error |
| Error | `error != null` | rethrown out of the bloc |

**Initial is not loading.** A bloc that has never been asked to do anything is
not busy. `SessionState.status == AuthStatus.unknown` is the reference: the
router holds on `/splash` for `unknown`, which is a different decision from
"a request is in flight".

**Empty is not an error.** A successful request that returned nothing is a
product state with its own copy and often its own call to action. Collapsing it
into the error branch is the most common way this goes wrong — and it is exactly
what `ApiClient.getPaginated` used to cause by returning an empty page for a
failed envelope.

## `isLoading` versus `isSubmitting`

| | Meaning | Example |
|---|---|---|
| `isLoading` | reading — the screen is populating itself | `SessionState.isLoading` during restore; `OnboardingConfigState.isLoading` |
| `isSubmitting` | a user-initiated write is in flight | `AuthState.isSubmitting` during login, register, verify, resend |

The distinction is not cosmetic: `isSubmitting` disables the form and shows an
in-button spinner, `isLoading` shows a skeleton or placeholder. A bloc that does
both operations names them separately.

## The `_run` idiom

Mutating handlers follow one shape. `AuthBloc._run` is the reference:

```
emit(busy: true, clearError: true, signal: none)
  → await action()
  → success: emit(result, busy: false, signal: <one-shot>)
  → failure: emit(busy: false, error: e, signal: none)
```

Two properties matter:

- **`clearError: true` on entry.** A retry must not render the previous
  failure while it is in flight.
- **The bloc does not rethrow.** The error is state. Screens read
  `state.error` and map it — see rule 20 in `conventions.md`.

## Error mapping is the UI's job

A backend `message` is an untranslated key (`core::messages.invalid_credentials`
arrives literally). Blocs store the raw exception; the screen converts:

```dart
final error = state.error == null
    ? null
    : AuthError.from(state.error!, l10n,
        unauthorizedMessage: l10n.loginErrorInvalidCredentials);
```

`AuthError.from` handles `ValidationException` (per-field errors, which *are*
real messages and safe to show), `NetworkException`, and `ApiException` by
status. Anything else falls back to a generic localized string.

## Retry

Retry re-dispatches the **same event**. There is no `RetryRequested`.

The trap is a guard that also blocks the retry. `OnboardingConfigBloc` had it:
it assigned `localeCode` before fetching, then compared against it, so a failed
load could never be retried for that locale. The guard must distinguish
"a request for this input is already in flight or already succeeded" from
"a request for this input failed":

```dart
final sameLocale = state.localeCode == event.localeCode;
final alreadyLoaded = state.config != null && state.error == null;
if (sameLocale && (state.isLoading || alreadyLoaded)) return;
```

Covered by `apps/client_app/test/onboarding_config_bloc_test.dart`.

## Paginated async state

A paginated surface has more conditions than the five above — first-load versus
next-page versus refresh, each with its own loading and failure rendering. That
is what `Paged<T>` encodes; see [`pagination.md`](./pagination.md).

## Verification

```bash
cd dorak-mobile
dart run melos run test
```
