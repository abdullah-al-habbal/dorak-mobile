# Forgot Password (Stitch 011)

Route: `/auth/forgot-password` · Screen: `forgot_password.screen.dart`

Entry: the "Forgot Password?" link on `/auth/login`. That link was wired to `null`
until this track, which hid it entirely.

## Layout

`AuthShell(pinnedHeader: true)` over `AuthEntryBackground`, `AuthHeader` with back +
locale toggle. Content is three staggered `FadeTransition`s (800 ms, intervals
0.0–0.6 / 0.1–0.7 / 0.2–0.8) — the same rhythm as login and sign-up.

Title, subtitle, one `AuthTextField` (email), `PrimaryButton` ("Send Code"), and a
`SkipButton` "Return to Log In".

## Behaviour

Client-side validation via `AuthValidators.email` before dispatch. Submitting
dispatches `RecoveryCodeRequested(email)`; `PrimaryButton.isLoading` reflects
`state.isSubmitting`.

**A 422 does not surface here.** The backend validates `exists:clients,email`, so
showing that error would expose which addresses have accounts. The flow advances to
012 either way — see `authentication/password_recovery.md` §1C. Only transport and
non-validation API failures render a `StatusBanner`.

Deviation from the Stitch design: the field is **Email** only, not "Email or Phone".
There is no phone-based recovery endpoint.

## Localization

`recoveryEmailTitle`, `recoveryEmailSubtitle`, `recoveryEmailLabel`,
`recoverySendCodeButton`, `recoveryReturnToLogIn`.
