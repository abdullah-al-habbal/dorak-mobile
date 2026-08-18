# Create New Password (Stitch 013)

Route: `/auth/reset-password` · Screen: `create_new_password.screen.dart`

## Layout

`AuthShell(pinnedHeader: true)`, staggered fades. Title, subtitle, two
`AuthTextField`s (new password with the `signUpPasswordHint` helper, confirm),
`PrimaryButton` ("Reset Password").

## Behaviour

Submitting dispatches `RecoveryPasswordSubmitted`, which sends the **carried** email
and code from `PasswordRecoveryState` together with the new password —
`reset-password` takes all four in one request.

Client validation first: `AuthValidators.password` (min 8) and
`AuthValidators.passwordConfirmation` (must match). The backend applies the same
rules (`min:8`, `confirmed`).

## This is where a bad code appears

Because no endpoint validates a recovery code on its own, an invalid or expired code
is only discovered here. When `state.isCodeRejected` (a `code` key in the
`ValidationException` errors), the screen renders a `StatusBanner` carrying a
**"Re-enter code"** action that routes back to 012 — inline text alone would leave
the user with no way forward. Background: `authentication/password_recovery.md` §1A.

The code-rejected banner takes precedence over the generic error banner, so the user
sees the actionable message rather than "Something went wrong".

## Localization

`recoveryNewPasswordTitle`, `recoveryNewPasswordSubtitle`,
`recoveryNewPasswordLabel`, `recoveryConfirmPasswordLabel`, `recoveryResetButton`,
`recoveryCodeRejected`, `recoveryReenterCode`, plus the shared `fieldPassword*` keys.
