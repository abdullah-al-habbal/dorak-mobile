# Stitch 012 — Forgot Password OTP Verification

## 1. Screen Identity

* Stitch export: `012_forgot_password_otp_verification`
* Screen: Forgot Password — OTP Verification
* Feature: Authentication / Password Recovery
* Client app: `apps/client_app`
* Track: `Track 16 — Authentication`
* Feature registry: `CL-08b`
* Previous screen: `011 Forgot Password Initial Screen`
* Next screen: `013 Create New Password`

This screen verifies the OTP/code sent during password recovery.

This is a password-reset verification step.

It is NOT the existing account-email-verification screen from Stitch 009 and must not be conflated with it.

---

## 2. Source of Truth

### Visual source

```text
docs/stitch/exports/012_forgot_password_otp_verification/screen.png
```

Use the screenshot for visual verification.

### Layout source

```text
docs/stitch/exports/012_forgot_password_otp_verification/code.html
```

Read the HTML for:

* layout
* ordering
* interaction intent
* visible states
* animation intent

Do not copy HTML or Tailwind classes into Flutter.

### Global design source

The export `DESIGN.md` is the global Dorak design specification already represented by:

```text
packages/design_system
```

Do not regenerate or duplicate:

* colors
* typography
* spacing
* radii
* global theme

Use the existing:

* `DorakColors`
* `DorakTypography`
* `DorakDimensions`
* `DorakTheme`

---

## 3. Product / Engineering Context

The screen belongs to the password-recovery flow:

```text
011 Forgot Password
        ↓
send recovery code
        ↓
012 OTP Verification
        ↓
013 Create New Password
        ↓
014 Password Reset Success
```

The existing authentication repository already contains password-recovery support.

Inspect the actual repository contract before implementing.

Do not invent API endpoints or request fields.

The password-reset OTP must remain distinct from normal account-email verification.

---

## 4. Architecture Rules

Follow:

```text
screen
  ↓
AppRouter (go_router)
  ↓
repository
  ↓
ApiClient
  ↓
backend
```

The screen must remain dumb.

The screen must not:

* call `ApiClient`
* call the repository directly
* access storage
* decide the next route
* import routing code

Flow logic belongs in:

```text
apps/client_app/lib/src/core/navigation/app.router.dart
apps/client_app/lib/src/core/navigation/app_routes.entity.dart
```

Navigation must continue using the existing go_router / authentication navigation conventions.

Do not introduce:

* another router
* named-route architecture
* Navigator 1.0 coordinators (`.navigator.dart`)
* another navigation state system

---

## 5. Expected Flutter Files

Preferred structure:

```text
apps/client_app/lib/src/features/auth/
├── forgot_password_otp.screen.dart
└── widgets/
    └── forgot_password_otp_content.widget.dart
```

Only create additional files when they are actually justified.

Prefer reuse of the existing:

```text
otp_input_field.widget.dart
```

if its existing behavior can safely support this flow.

Do not duplicate the OTP input implementation without a concrete reason.

---

## 6. Important Reuse Decision — Existing OTP Input

The existing client app already contains:

```text
apps/client_app/lib/src/features/auth/widgets/otp_input_field.widget.dart
```

Inspect it before creating a new OTP widget.

Existing implementation already supports important behaviors such as:

* six-digit input
* auto-advance
* keyboard deletion behavior
* focus handling
* existing verification flow conventions

The password-recovery screen should reuse it when possible.

If the existing widget has assumptions specific to account-email verification, make the smallest clean change needed to make it flow-agnostic.

Do not create:

```text
forgot_password_otp_input_field.widget.dart
```

unless the existing widget fundamentally cannot support both contexts.

If a modification is made, add/update tests for BOTH:

* account verification
* password recovery OTP

to prevent regressions.

---

## 7. Screen Layout

Overall structure:

```text
Scaffold
└── SafeArea
    ├── Top App Bar
    │   ├── Back button
    │   ├── Dorak brand
    │   └── balancing spacer
    │
    └── Centered content
        └── Password recovery card
            ├── Decorative background element
            ├── Email verification icon
            ├── Heading
            ├── Supporting text
            ├── OTP input
            ├── Error/reserved area
            ├── Verify & Continue
            └── Resend Code
```

The screen is centered vertically within the available space.

The primary content is constrained to the existing authentication max width.

---

## 8. Top App Bar

The Stitch screen uses a simple transactional header.

Required:

* full-width background
* mobile horizontal margins
* approximately 64px height
* back control
* Dorak brand
* balancing trailing spacer

The brand should remain visually centered.

Use the existing auth-header pattern if compatible.

Back behavior:

```text
012
 ↓
011
```

Use the authentication flow (go_router).

The directional icon must support RTL correctly.

---

## 9. Recovery Card

The main content is visually presented as a soft glass-like card.

The Stitch HTML uses:

* translucent surface
* blur
* rounded large radius
* subtle shadow
* faint border
* decorative purple circle

Flutter should NOT blindly reproduce CSS blur.

Use the project's established lightweight glass-card approximation where appropriate.

Preferred visual direction:

* `surface` / `surface-container` tonal layer
* subtle transparency where supported
* existing Dorak radius
* low-elevation/subtle shadow
* no expensive or unnecessary `BackdropFilter` unless the existing project already uses it

The card should remain visually soft and integrated with the page.

Do not introduce a new global card component solely for this screen.

---

## 10. Decorative Background Element

The HTML contains:

```text
large blurred purple circle
```

This is decorative only.

Translate it into an inexpensive Flutter visual such as:

* a circular container
* radial/soft gradient
* low-alpha `primaryFixedDim` / equivalent token

Do not use a custom painter.

Do not create a reusable design-system component unless another screen genuinely needs it.

The decoration must never affect interaction.

---

## 11. Recovery Icon

Use the Material icon corresponding to the Stitch design:

```text
mark_email_read
```

Use:

* primary color token
* appropriate size
* outlined visual style where practical

Do not ship Google-hosted icon assets.

Use Flutter Material icons.

The icon is decorative and should not carry essential meaning that is missing from the text.

---

## 12. Heading

Stitch text:

```text
Verify Your Account
```

Because this is password recovery, check whether this copy should remain exactly as-is or be made more explicit for password reset.

Preferred product-facing meaning:

```text
Verify the recovery code
```

or an equivalent localized password-reset-specific wording.

Do not blindly reuse the existing account-verification string from Stitch 009.

The heading must clearly communicate that this OTP belongs to password recovery.

Use the appropriate Dorak typography token.

Suggested key:

```text
forgotPasswordOtpTitle
```

Reuse an existing generic OTP title only if it does not create semantic ambiguity.

---

## 13. Supporting Text

Stitch example:

```text
Enter the 6-digit code we sent to j***@example.com to reset your password.
```

The email must be dynamic.

Do not hardcode:

```text
j***@example.com
```

The screen should receive the recovery email/context from the preceding 011 flow.

Suggested localization key:

```text
forgotPasswordOtpSubtitle
```

The generated localization string should use an ICU placeholder.

Example concept:

```text
forgotPasswordOtpSubtitle(String email)
```

Do not duplicate an existing generic verification placeholder if a reusable semantic string already exists.

---

## 14. Email Masking

Display a privacy-safe masked email.

Example:

```text
j***@example.com
```

The actual user email must not be fully exposed in the UI.

The masking logic should be deterministic and testable.

Prefer a small value-object/helper implementation consistent with the project's file taxonomy if masking logic becomes non-trivial.

Do not expose or log the unmasked email unnecessarily.

Tests must include normal and edge-case addresses.

---

## 15. OTP Input

The screen requires six digits.

Required behavior:

```text
6-digit numeric OTP
auto-advance
backspace navigation
focus management
paste/autofill support where practical
```

The existing:

```text
otp_input_field.widget.dart
```

should be reused when possible.

Each digit should visually follow the Stitch pattern:

* approximately 56px tall on mobile
* centered text
* bottom-outline emphasis
* subtle container background
* primary focus state
* Dorak typography
* directional-safe layout

Do not hardcode the Tailwind values directly.

Use existing tokens/dimensions.

---

## 16. OTP Validation

Required states:

```text
empty
partial
complete
invalid
valid
loading
```

The Verify button should only submit when a complete six-digit code exists.

The screen should not repeatedly submit incomplete codes.

Before API submission:

```text
OTP length == 6
digits only
```

The backend is the final authority for correctness.

---

## 17. Verification Request

On valid six-digit OTP:

```text
012
 ↓
password reset verification repository operation
 ↓
ApiClient
 ↓
backend
```

Inspect `AuthRepository` before implementation.

Do not invent a request method or endpoint.

The repository already contains the password reset surface; verify whether the existing method is designed as:

* OTP verification as part of reset
* combined reset operation
* another supported flow

Use the real backend contract.

If the current repository lacks a separate OTP-verification method but the backend requires one, update the repository/core contract properly rather than bypassing it from the app.

---

## 18. Navigation After Successful Verification

Successful verification must navigate to:

```text
013 Create New Password
```

The router owns this transition.

The OTP step must pass forward only the minimum necessary recovery context.

Likely context:

* email
* verified reset token / reset identifier if the backend requires one

Do not store recovery data globally when local flow state is sufficient.

The implementation must follow the actual backend contract discovered from the repository/API code.

---

## 19. Invalid OTP

The Stitch design explicitly includes an error area.

On invalid code:

* preserve layout height
* show an error state
* use the error color token
* optionally use the error icon shown by Stitch
* do not shift the entire screen vertically
* allow the user to correct/resubmit the code

Suggested localized concept:

```text
forgotPasswordOtpInvalid
```

Reuse an existing OTP validation string only if semantically correct.

Do not display raw backend error messages.

---

## 20. Error Mapping

Continue using the existing exception taxonomy.

Expected behavior:

### 422

Map the validation response to a localized user-facing error.

### Network failure

Show a retryable network error.

### Other API failure

Use existing authentication/API error mapping.

Never render:

```text
ApiException.message
```

because backend messages may be untranslated keys.

---

## 21. Verify & Continue Button

Primary CTA:

```text
Verify & Continue
```

Suggested localization key:

```text
forgotPasswordOtpVerify
```

Required states:

```text
disabled
enabled
loading
error
success
```

During loading:

* disable the button
* prevent duplicate requests
* show the existing primary-button loading state where possible

Do not create a second button implementation.

---

## 22. Resend Code

Bottom interaction:

```text
Didn't receive the code? Resend Code (0:59)
```

Required behavior:

```text
initial state
 ↓
cooldown active
 ↓
Resend disabled
 ↓
countdown
 ↓
cooldown reaches zero
 ↓
Resend enabled
```

The existing account-verification screen already has resend cooldown behavior.

Inspect:

```text
verify_account.screen.dart
verify_account_content.widget.dart
auth_flow_test.dart
```

Reuse the established cooldown approach.

Do not copy it blindly; make the implementation reusable where appropriate without introducing unnecessary abstraction.

The countdown must not be hardcoded as `0:59`.

It must derive from state.

Suggested localization:

```text
forgotPasswordOtpResendPrompt
forgotPasswordOtpResendDisabled(int seconds)
forgotPasswordOtpResend
```

Reuse an existing generic resend key when it is semantically correct.

---

## 23. Resend Request

Inspect the existing authentication repository and backend contract.

Use the appropriate existing password-recovery request.

Do not assume that account-verification resend and password-reset resend are the same endpoint.

If a reset-specific resend operation is required but does not exist in `AuthRepository`, extend the repository/core contract using the project's normal endpoint/repository pattern.

Do not call the API directly from the screen.

---

## 24. Resend Error Behavior

If resend fails:

* keep the OTP screen
* do not discard valid recovery context
* show a localized retryable error
* restore resend availability according to the intended cooldown rules
* do not create duplicate timers

The user must be able to try again.

---

## 25. Timer / Lifecycle Safety

The resend countdown must be lifecycle-safe.

Requirements:

* cancel timers when the screen is disposed
* no `setState` after disposal
* no timer multiplication when resend occurs
* no overlapping countdowns
* test the cooldown deterministically

Prefer the same proven approach already used by the existing verification implementation.

---

## 26. Initial Focus

Stitch focuses the first OTP input shortly after page load.

Flutter should provide sensible initial focus.

Avoid forcing the keyboard open in a way that makes the page unusable on every device.

Use a focus request pattern consistent with the existing OTP implementation.

If existing `OtpInputField` already manages this, reuse that behavior.

---

## 27. Animation

Stitch uses:

```text
fade-in-up
600ms
cubic-bezier(0.16, 1, 0.3, 1)
```

Follow the existing Dorak motion convention.

Do not add an animation package.

A simple fade + upward slide is sufficient.

Do not animate every small child independently unless the existing design system already does so.

---

## 28. Responsive Layout

Primary target: mobile.

Use:

```text
20px mobile margins
64px desktop margins
authentication max width around 448–480px
```

Use Dorak dimensions rather than literal values where possible.

OTP spacing must adapt to narrow screens.

Do not assume six 56px fields plus large fixed gaps always fit.

Use flexible spacing / constraints so smaller devices remain usable.

Avoid horizontal overflow.

---

## 29. RTL

Arabic must work.

Requirements:

* back icon direction changes appropriately
* text alignment follows text direction
* card remains centered
* OTP digits remain logically ordered
* resend row remains visually correct
* no hardcoded `left` / `right`
* use directional padding/alignment APIs where needed

The numeric OTP itself must preserve logical digit order.

Test RTL behavior with the existing Arabic locale.

---

## 30. Accessibility

Each OTP input must have a meaningful semantic label.

Examples of concepts:

```text
Digit 1
Digit 2
...
Digit 6
```

The verify button needs a clear semantic label.

The resend action must expose disabled/enabled state correctly.

The validation error should be discoverable to assistive technologies.

Do not rely solely on color.

---

## 31. Security

Do not:

* log OTP values
* persist OTP values unnecessarily
* expose reset credentials in debug UI
* place OTP values in analytics/logging
* expose unmasked email unnecessarily

The OTP should remain in memory for the duration of the flow.

If the backend returns a reset token, store only the minimum context needed to advance the flow.

---

## 32. Existing Components to Inspect

Before implementation inspect:

```text
apps/client_app/lib/src/features/auth/widgets/otp_input_field.widget.dart
apps/client_app/lib/src/features/auth/verify_account.screen.dart
apps/client_app/lib/src/features/auth/widgets/verify_account_content.widget.dart
apps/client_app/test/auth_flow_test.dart

packages/core/.../repositories/auth.repository.dart
packages/core/.../network/endpoints/auth.endpoints.dart
packages/core/.../dto/
```

Likely reuse candidates:

```text
OtpInputField
PrimaryButton
AuthHeader
AuthErrorBanner
```

Reuse only where semantics match.

Do not duplicate existing OTP behavior.

---

## 33. Expected File Structure

Preferred:

```text
apps/client_app/lib/src/features/auth/
├── forgot_password_otp.screen.dart
└── widgets/
    └── forgot_password_otp_content.widget.dart
```

Potentially modify:

```text
apps/client_app/lib/src/features/auth/widgets/otp_input_field.widget.dart
```

only if required to make the widget safely reusable between:

* account verification
* password recovery

If modifications are made, protect both flows with tests.

---

## 34. Localization

Before implementation:

1. Inspect existing ARB keys.
2. Reuse existing generic OTP/resend keys where semantically correct.
3. Add only missing password-recovery-specific keys.
4. Add each key to:

   * `app_en.arb`
   * `app_ar.arb`
5. Generate localization.

Expected concepts:

```text
Password reset verification title
Password reset OTP subtitle with masked email placeholder
Verify & Continue
Invalid code
Resend prompt
Resend cooldown
Resend action
Network/retry message if not already available
```

Use ICU placeholders for dynamic email/seconds where required.

---

## 35. Tests

Add/update tests covering:

### Rendering

* heading
* subtitle
* six OTP inputs
* verify button
* resend area
* back button

### OTP interaction

* digit entry advances focus
* backspace moves focus correctly
* partial OTP cannot submit
* six-digit OTP enables verification

### Verification

* success navigates to 013
* invalid OTP displays error
* network failure displays retryable error
* duplicate submission is prevented
* loading state behaves correctly

### Resend

* cooldown starts
* resend disabled during cooldown
* countdown progresses
* resend becomes enabled after cooldown
* resend request succeeds
* resend failure behaves correctly
* no timer leaks after disposal

### Navigation

* back returns to 011
* successful verification proceeds to 013

### Regression

If `OtpInputField` is modified:

* existing Stitch 009 account-verification tests still pass
* password-recovery OTP tests pass

### Security

* OTP is not rendered in logs/test output beyond explicit field assertions
* masked email is displayed rather than full email

Use existing test fakes.

Do not hit the real backend.

Use the existing phone viewport setup.

---

## 36. Stitch-to-Flutter Deviations

### Deviation 1 — Password recovery vs account verification

The Stitch heading says:

```text
Verify Your Account
```

This screen is actually part of password recovery.

The product-facing implementation should make the password-reset context clear.

Do not blindly copy the account-verification semantics from Stitch 009.

### Deviation 2 — Reuse existing OTP field

The repository already has an OTP input implementation.

Reuse it rather than creating a second OTP component unless the current implementation truly cannot support this flow.

### Deviation 3 — Glass effect

The HTML uses CSS blur.

Flutter should use the project's lightweight tonal/glass approximation rather than blindly introducing expensive blur rendering.

### Deviation 4 — Raw Tailwind values

Use the existing Dorak design system.

Do not copy colors, font sizes, or spacing from the HTML directly into application code.

---

## 37. Acceptance Criteria

```text
[ ] Screen visually matches Stitch 012.
[ ] Password-recovery semantics are distinct from account verification.
[ ] Existing design tokens are reused.
[ ] No raw color literals in app code.
[ ] No hardcoded user-visible strings.
[ ] EN + AR localization exists.
[ ] Dynamic masked email is supported.
[ ] Exactly six OTP digits are supported.
[ ] Existing OTP widget is reused or cleanly generalized.
[ ] Auto-advance works.
[ ] Backspace navigation works.
[ ] Verification loading works.
[ ] Invalid-code error works.
[ ] Successful verification proceeds to 013.
[ ] Back returns to 011.
[ ] Resend cooldown works.
[ ] Resend is protected from duplicate requests.
[ ] Timer is disposed safely.
[ ] API errors use the existing exception model.
[ ] Backend messages are never rendered directly.
[ ] No API call is made directly from the screen.
[ ] RTL works.
[ ] Accessibility semantics exist.
[ ] Existing account verification remains intact.
[ ] Tests pass.
[ ] Analyze passes.
[ ] Taxonomy passes.
[ ] Full melos verify passes.
```

---

## 38. Verification

From:

```text
/home/lenovo/work/projects/dorak/dorak-mobile
```

run:

```bash
dart run melos run generate
dart run melos run build
dart run melos run analyze
dart run melos run taxonomy
dart run melos run test
dart run melos run verify
```

The authoritative completion gate is:

```bash
dart run melos run verify
```

Do not mark Stitch 012 as migrated until the gate passes.

---

## 39. Export Cleanup

Only after the implementation is verified:

```text
Verify
  ↓
Confirm plan/code alignment
  ↓
Delete:
docs/stitch/exports/012_forgot_password_otp_verification/
```

Do not delete the export before verification.

---

## 40. Final Implementation Principle

This plan is the normalized implementation contract.

The coding agent may inspect:

```text
code.html
screen.png
```

to resolve visual details.

The coding agent must use:

```text
plan.md
AGENTS.md
CLAUDE.md
existing Flutter code
existing repository/backend contract
```

to make engineering decisions.

When Stitch conflicts with the actual backend contract or existing architecture, the backend and architecture win. The deviation must remain documented rather than silently ignored.
