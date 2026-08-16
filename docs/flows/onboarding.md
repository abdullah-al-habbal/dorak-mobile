# Onboarding Flow

Status: `DONE`

## Entry

The 4-step tour (Stitch 002–005) is reachable from exactly one place:
**"Continue as Guest"** on the auth entry screen. Logging in or signing up
bypasses it entirely.

`AppRouter` (`apps/client_app/lib/src/core/navigation/app.router.dart`) wires
the four onboarding routes; the screens themselves know nothing about their
neighbours and only receive callbacks.

```text
Welcome (push) -> Discovery (push) -> Booking (push) -> AI Showcase -> context.go('/home')
```

Progress dots are flow-wide: `count: 4`, `activeIndex` 0…3.

## Skip ≠ Don't show again

The skip sheet (`skip_bottom_sheet.sheet.dart`) offers three options. They are
**not** interchangeable — this is the behavioural core of the flow:

| Action | `dontShowOnboarding` | Navigation | Next cold start |
| --- | --- | --- | --- |
| Skip for now | untouched (`false`) | Home | tour shown again |
| Don't show again | set to `true` | Home | straight to Home |
| Cancel | untouched | stays on the current step | — |
| Complete the tour ("Get Started" on step 4) | set to `true` | Home | straight to Home |

The sheet dismisses itself before either decision runs, so navigation never
fires while the modal route is still on top.

`_dismissForever` writes the flag inside a `try` and navigates from a `finally`
— a failed write must not strand the user on the tour.

## Stack hygiene

Leaving the tour uses `context.go('/home')` — go_router's declarative `go`
clears the stack by construction. (Pre-Phase 2, `AppNavigator.goHome()` needed
`pushAndRemoveUntil` because `pushReplacement` swapped only the top route, which
left the onboarding screens alive beneath Home and reachable by back gesture;
from inside the sheet it replaced the sheet rather than the screen.)

## Known limitation

Screens 002–005 lay out in a non-scrolling `Column` and overflow on short
viewports. Making them scroll is not covered here.

## Verification

```bash
cd apps/client_app && flutter test test/onboarding_skip_test.dart
```

Covers both skip variants, cancel, the full four-step walk, and the empty
back-stack after leaving.
