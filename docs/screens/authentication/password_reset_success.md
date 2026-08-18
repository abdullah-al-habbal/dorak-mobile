# Password Reset Success (Stitch 014)

Route: `/auth/reset-password/success` · Screen: `password_reset_success.screen.dart`

## The screen is a `StatusView`

This is **`StatusView`'s first production consumer**, and the reason Track 12's
contract is now validated against something real rather than only its own tests.
The whole screen body is:

```dart
StatusView(
  icon: Icons.check_circle_outline,
  iconColor: colors.primary,
  title: l10n.passwordResetSuccessTitle,
  message: l10n.passwordResetSuccessMessage,
  actionLabel: l10n.authLogIn,
  onAction: onLogIn,
)
```

Inside `AuthShell` (unpinned — no header, because there is deliberately nothing to
go back to) over `AuthEntryBackground`.

## Behaviour

Deliberately terminal. One action, and it uses `router.go(AppRoutes.authLogin)` —
**`go`, not `push`** — so the entire recovery stack is discarded. A completed reset
cannot be back-navigated into, which matters because the code has already been
consumed and re-submitting it would fail.

Asserted by `password_recovery_flow_test.dart`: after tapping Log In, the router's
`currentConfiguration.uri.path` is `/auth/login` and the success screen is gone.

No auto-redirect timer. The user confirms.

## Localization

`passwordResetSuccessTitle`, `passwordResetSuccessMessage`, and the existing
`authLogIn`.
