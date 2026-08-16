# Guest Access

Status: `DONE`

## What a guest is

A guest is a device with **no stored token**: `SessionController.status ==
AuthStatus.guest`. There is no guest account, no anonymous token, and no
server-side guest session — the client simply sends no `Authorization` header
(`AuthInterceptor` omits it when `tokenProvider` returns null).

## Becoming a guest

- Never signed in.
- Tapped **"Continue as Guest"** on the auth entry screen.
- Had a token that the backend rejected on restore (401/403) — the token is
  cleared and the device drops back to guest.
- Logged out.

## What a guest reaches

"Continue as Guest" starts the onboarding tour (see `flows/onboarding.md`); every
exit from that tour lands on Home. A guest that has already dismissed or
completed the tour goes straight to Home from the launch gate.

Home is currently a placeholder, so there is nothing yet that a guest is denied.

## Not implemented

- **Guest guards.** No screen currently gates itself on authentication, and
  there is no guest guard on any screen. The mechanism exists though: a
  guest-guarded action calls `SessionController.requireAuthentication()`, which
  raises the `authenticationRequired` global state and pushes the auth entry
  screen on top of the current screen (back returns to it). Per-route guest
  guards are Track 11.
- **Guest → account migration.** Nothing is carried across when a guest later
  signs in; there is no local guest state to migrate.
- **Re-entering auth from Home.** Once a guest reaches Home there is no route
  back to the auth entry screen — Home has no account affordance yet.

## Verification

```bash
cd apps/client_app && flutter test test/app_gate_test.dart
```
