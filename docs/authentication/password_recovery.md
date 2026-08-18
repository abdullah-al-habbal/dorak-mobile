# Password Recovery

Status: `DONE` — Stitch 011–014, four routes, live backend.

Flow: `/auth/login` → `/auth/forgot-password` → `/auth/forgot-password/otp` →
`/auth/reset-password` → `/auth/reset-password/success` → `/auth/login`.

---

## 1. The backend contract, and the three things it forces

```
POST /client/forgot-password   { email }
    email: required, email, exists:clients,email

POST /client/reset-password    { email, code, password, password_confirmation }
    code:     required, size:6
    password: required, min:8, confirmed
```

Both already existed in `AuthRepository` (`packages/core`) before this track; no
core change was needed.

### A. There is no verify-reset-code endpoint

The complete client auth route list is login, register, social, forgot-password,
reset-password, logout, refresh-token, avatar, email/verify, email/verify/send.
**Nothing validates a recovery code on its own.** `ForgotPasswordHandler` stores it
as `Cache::put("password_reset_{$client->id}", $code, now()->addMinutes(10))`, and
only `ResetPasswordHandler` reads it back.

Consequence, and it is the defining shape of this flow: **the OTP screen (012)
cannot validate the code.** It collects six digits and carries them in state; the
code is first checked when 013 submits `reset-password`. So a wrong or expired code
surfaces on **013**, after the user has already typed a new password.

`CreateNewPasswordContent` therefore inspects
`PasswordRecoveryState.isCodeRejected` (a `code` key in the `ValidationException`
errors) and renders a `StatusBanner` with a **"Re-enter code"** action back to 012 —
not just inline text under a field, which would leave the user stuck.

Do not add a client-side "verify code" step. There is no endpoint for it, and
inventing one would mean guessing at an API.

### B. The code expires in 10 minutes

Longer than the 60 s resend cooldown, so the cooldown UX is compatible. Stated in
`recoveryOtpSubtitle` so the user knows.

### C. `exists:clients,email` is an account-enumeration oracle

A 422 from forgot-password means "this address is not registered". Surfacing it
would let anyone test whether an email has a Dorak account.

**Mitigation, client-side, no backend change:** `PasswordRecoveryBloc._onCodeRequested`
catches `ValidationException` and **still emits `RecoverySignal.codeSent`**, so the
flow advances identically for registered and unregistered addresses. Copy is neutral
— *"If {email} is registered, we've sent it a 6-digit code."*

A `NetworkException` or any other `ApiException` does **not** advance — the user
genuinely cannot proceed, and hiding that would be worse than the leak.

Trade-off, accepted: someone who mistypes their address waits for a code that never
arrives. They can go back and correct it, and resend re-triggers the request.

Covered by `password_recovery_bloc_test.dart` and `password_recovery_flow_test.dart`;
both name the reason, so the behaviour is not "simplified" later by someone who
reads it as a swallowed error.

## 2. Recovery resend is *not* email verification

Resend on 012 calls **`forgotPassword(email)` again**, which regenerates the code.

It is **not** `sendEmailVerification`. They are different endpoints with different
throttles — `/client/email/verify/send` carries `throttle:3,1`; forgot-password is
unthrottled (a recorded backend defect). Conflating them would send the wrong kind
of code.

## 3. State

`PasswordRecoveryBloc` lives in **`apps/client_app`**, not `packages/core`.
`SessionBloc`/`AuthBloc` are in core because every app needs session truth
(ADR 0001); password recovery is a client feature flow. The precedent is
`OnboardingConfigBloc` — an app-layer bloc over a core repository.

Extending `AuthBloc` was rejected: it would carry `email`/`code` fields that login,
register and verify never use, against `state_management/conventions.md` rule 5.

| Event | Effect |
|---|---|
| `RecoveryCodeRequested(email)` | `POST /client/forgot-password`; stores the email; `codeSent` |
| `RecoveryCodeEntered(code)` | local only; stores the code; `codeAccepted` |
| `RecoveryPasswordSubmitted(password, passwordConfirmation)` | `POST /client/reset-password` with the carried email + code; `passwordReset` |
| `RecoveryRestarted()` | clears email and code — dispatched when the flow is entered from login |
| `RecoverySignalAcknowledged()` | the router consumed the signal |

`RecoverySignal` is one-shot (`none | codeSent | codeAccepted | passwordReset`),
consumed by `AppRouter._onRecoveryChanged`, then acknowledged. **The bloc never
navigates** (conventions rule 44).

**Why `codeAccepted` is a signal rather than a direct `context.push`:** `bloc.add`
goes through the event queue, so a screen that pushed immediately could build 013
*before* the code reached state. Routing on the emitted state makes the ordering
correct by construction.

`copyWith` carries explicit `clearError` / `clearFieldErrors` flags — conventions
rule 12, the rule that exists because `copyWith(client: null)` was once a silent
no-op.

## 4. Reuse

Nothing new was invented. `AuthShell` (layout), `AuthHeader`, `AuthTextField`,
`OtpInputField`, `StatusBanner`, `PrimaryButton.isLoading`, `AuthValidators`,
`AuthError.from`, and the 60 s cooldown pattern from `verify_account_content`.

**Screen 014 is `StatusView`'s first production consumer** — icon, title, message,
single action is exactly its shape. That is what validates the Track 12 contract on
something real.

## 5. Known limits

- **`MAIL_MAILER=log` on dev** — the code only ever reaches
  `storage/logs/laravel.log`. Read it from there when testing by hand. Pre-existing
  backend defect, unrelated to this track.
- **forgot-password is unthrottled** server-side, so the client's 60 s cooldown is
  the only rate limit. Client-side only, therefore bypassable.
- No "change password while signed in" — `/client/password` exists but belongs to
  Track 17.

## 6. Verification

```bash
cd dorak-mobile
dart run melos run verify
```

`password_recovery_bloc_test.dart` (8) covers the transitions, the enumeration
mitigation, and the carried code. `password_recovery_flow_test.dart` (6) covers the
route walk end to end, including that an unregistered email still advances and that
a rejected code offers a way back to 012.
