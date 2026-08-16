# Authentication Flow

Status: `IN_PROGRESS` — login, registration and email verification are wired;
password recovery (Stitch 011–014) is not.

## Backend contract

Laravel 13 + **Sanctum opaque bearer tokens** (not JWT), base `/api/v1`.
Endpoint constants live in `packages/core/.../endpoints/auth.endpoints.dart`.

| Call | Route | Notes |
| --- | --- | --- |
| Register | `POST /client/register` | 201. Requires `password_confirmation` (Laravel `confirmed`). Returns `{token, client}` — **the user is authenticated immediately, before verifying.** |
| Login | `POST /client/login` | `{email, password}` → `{token, client}`. 401 on bad credentials. Email only — there is no phone login. |
| Refresh | `POST /client/refresh-token` | `auth:client`. Revokes the current token, returns a replacement. Used as the session-validity probe. |
| Send code | `POST /client/email/verify/send` | `auth:client`. 6-digit code, 10-minute TTL. |
| Verify | `POST /client/email/verify` | `auth:client`, `{code}` with `size:6`. 422 on a wrong code. |
| Logout | `POST /client/logout` | `auth:client`. 200 with **no `data` key**. |

## Screen flow

```text
Auth Entry (006)
├── Log In        -> Login (007)  --success-->  Home
├── Create Account-> Sign Up (008) --success--> Verify (009) --+--> Home
└── Continue as Guest -> onboarding tour       (skip) ---------+
```

Wiring lives in `apps/client_app/lib/src/core/navigation/app.router.dart`
(`AppRouter`). Every success path ends in `router.go(AppRoutes.home)`, which
clears the stack by construction.

Logging in **bypasses the onboarding tour** — a returning user is assumed not to
need the introduction.

## Verification is non-blocking

`POST /client/register` already returns a valid token, so an unverified account
is authenticated. The verify screen therefore offers "Verify later", which goes
to Home. This is also the only workable behaviour today: the backend runs with
`MAIL_MAILER=log`, so the 6-digit code is written to
`storage/logs/laravel.log` and never delivered.

After a successful registration the code is dispatched automatically. A failure
of that dispatch is swallowed — registration already succeeded, and the verify
screen has a Resend (60-second cooldown).

## Error messages are resolved locally

**Never render `ApiException.message`.** `modules/Core/Lang` defines only four
keys while the Client module references eleven more, and the translator falls
back to returning the key, so a rejected login answers with the literal string
`core::messages.invalid_credentials`.

`AuthError.from` (`features/auth/auth_error.entity.dart`) maps the exception to
a local ARB string:

| Caught | Shown |
| --- | --- |
| `ValidationException` | per-field `errorText` from `errors` (real Laravel validator messages, safe to show) + a generic banner |
| `ApiException.isUnauthorized` on login | `loginErrorInvalidCredentials` |
| `ApiException` 422 on verify | `verifyErrorInvalid` |
| `NetworkException` | `errorNetwork` |
| anything else | `errorGeneric` |

## Client-side rules

`AuthValidators` mirrors the backend request rules so obvious mistakes do not
round-trip: email format, password `min:8`, confirmation match.

## Not implemented

Forgot/reset password screens (the repository methods exist, no UI calls them),
social login (Socialite has no configured drivers server-side), and profile
completion (Stitch 010). (The 401-triggered session-expired redirect is
implemented — see `docs/navigation/guards.md`.)

## Verification

```bash
cd apps/client_app && flutter test test/auth_flow_test.dart
cd packages/core   && flutter test test/auth_repository_test.dart test/session_controller_test.dart
```
