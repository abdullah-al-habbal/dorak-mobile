# Recovery Code (Stitch 012)

Route: `/auth/forgot-password/otp` · Screen: `recovery_otp.screen.dart`

## Layout

`AuthShell(pinnedHeader: true)`. Lock-reset icon, title, subtitle with the masked
destination, six `OtpInputField`s in a `Row`, `PrimaryButton` ("Continue"), and a
resend row with a 60 s cooldown.

`OtpInputField` is reused unchanged from account verification — it was already
flow-agnostic (auto-advance, backspace-to-previous).

## Behaviour

**This screen cannot validate the code.** There is no verify-reset-code endpoint;
`Continue` dispatches `RecoveryCodeEntered(code)`, which only stores it and raises
`codeAccepted` so the router advances to 013. The code is first checked when 013
submits. Full reasoning: `authentication/password_recovery.md` §1A.

Local validation is limited to completeness — fewer than six digits shows
`recoveryOtpIncomplete` without a request.

**Resend calls `forgotPassword(email)` again**, not `sendEmailVerification` — see
§2 of the recovery doc. The 60 s cooldown restarts on each resend; the server-side
code TTL is 10 minutes, so the cooldown never outlives the code.

The destination is masked (`s***@example.com`) using the same helper shape as the
verification screen.

## Localization

`recoveryOtpTitle`, `recoveryOtpSubtitle({email})`, `recoveryOtpContinueButton`,
`recoveryOtpIncomplete`, `recoveryDidNotReceive`, `recoveryResend`,
`recoveryResendDisabled({seconds})`.
