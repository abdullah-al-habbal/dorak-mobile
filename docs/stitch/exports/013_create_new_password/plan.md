# Stitch 013 — Create New Password

## 1. Screen Identity

* Stitch export: `013_create_new_password`
* Screen: Create New Password
* Feature: Authentication / Password Recovery
* Client app: `apps/client_app`
* Track: `Track 16 — Authentication`
* Feature registry: `CL-08b`
* Previous screen: `012 Forgot Password OTP Verification`
* Next screen: `014 Password Reset Success`

This screen completes the password-reset credential update after successful recovery-code verification.

---

## 2. Source of Truth

### Visual source

```text
docs/stitch/exports/013_create_new_password/screen.png
```

Use the screenshot for visual verification.

### Layout source

```text
docs/stitch/exports/013_create_new_password/code.html
```

Read the HTML for:

* structure
* ordering
* interaction intent
* validation states
* loading/success/error states
* animation intent

Do not copy HTML or Tailwind classes into Flutter.

### Global design source

The `DESIGN.md` in this export contains a different design-token/specification set and references:

```text
Dorak High-End Grooming & Beauty
```

This conflicts with the repository's established Dorak design-system contract.

The existing Flutter design system remains authoritative:

```text
packages/design_system
```

Do not regenerate or replace the existing Dorak tokens from this export.

Use:

* `DorakColors`
* `DorakTypography`
* `DorakDimensions`
* `DorakTheme`

Any screen-specific visual deviation that is genuinely required by `screen.png` must be implemented using existing semantic tokens rather than introducing a second global design system.

---

## 3. Product / Engineering Context

Password recovery flow:

```text
011 Forgot Password
        ↓
012 OTP Verification
        ↓
013 Create New Password
        ↓
014 Password Reset Success
```

The user has already passed the recovery-code step.

This screen must receive whatever recovery context is required by the actual backend flow.

Possible context may include:

* email
* reset identifier
* verified recovery token
* other server-issued reset credential

Do not guess.

Inspect the actual `AuthRepository.resetPassword(...)` implementation, DTOs, and endpoint contract before implementation.

---

## 4. Backend Contract Is Authoritative

The HTML is only a visual/interaction source.

Before implementing validation or submission, inspect:

```text
packages/core/lib/src/network/repositories/auth.repository.dart
packages/core/lib/src/network/endpoints/auth.endpoints.dart
packages/core/lib/src/network/dto/
```

and the backend implementation where available.

Determine the exact `resetPassword` request contract.

Do not invent:

* endpoint
* request field names
* reset token semantics
* password rules
* success behavior

The Flutter implementation must match the real backend contract.

---

## 5. Critical Validation Discrepancy

The Stitch HTML validates:

```text
password length >= 8
AND
contains letters
AND
contains numbers
AND
confirmation matches
```

Do not automatically treat this as the backend contract.

The existing Dorak auth implementation already has password validation conventions.

Compare the reset-password backend rules with:

```text
auth_validators.entity.dart
```

and the existing registration rules.

Use the strongest common contract that is actually supported by the backend.

If the backend only requires:

```text
minimum 8 characters
password_confirmation
```

then the UI must not create an artificial client-only requirement for letters + numbers that the backend does not require.

If the backend does require the stronger rule, implement it consistently.

Record the final decision in the implementation diff / plan rather than silently copying the HTML.

---

## 6. Architecture Rules

Flow remains:

```text
screen
  ↓
app.router.dart (go_router)
  ↓
AuthRepository
  ↓
ApiClient
  ↓
backend
```

The screen must remain dumb.

The screen must not:

* call the repository directly
* call `ApiClient`
* access storage
* choose application-level navigation
* import routing code
* create its own HTTP client
* introduce its own state-management package

Flow decisions belong in:

```text
apps/client_app/lib/src/core/navigation/app.router.dart
apps/client_app/lib/src/core/navigation/app_routes.entity.dart
```

---

## 7. Expected Flutter Files

Preferred structure:

```text
apps/client_app/lib/src/features/auth/
├── create_new_password.screen.dart
└── widgets/
    └── create_new_password_content.widget.dart
```

Additional files only when justified.

Password-field widgets should be reused if the existing `AuthTextField` can support the required interaction.

Do not create a second password-field architecture without checking the existing implementation.

---

## 8. Screen Layout

Overall structure:

```text
Scaffold
├── Background decorative layers
├── Top transactional header
│   ├── Back button
│   ├── Dorak brand
│   └── balancing spacer
│
└── Centered content
    └── Password reset card
        ├── Header/icon
        ├── Title
        ├── Supporting text
        ├── New Password
        ├── Password requirements
        ├── Confirm New Password
        ├── Match error
        ├── System error
        └── Reset Password CTA
```

The main content is centered and constrained to the authentication form width.

---

## 9. Background

The Stitch export uses two large atmospheric background shapes:

* primary-purple blur near top-left
* secondary/lavender blur near bottom-right

These are decorative only.

Implement them using inexpensive Flutter decoration/gradient techniques and existing design tokens.

Prefer:

* `DecoratedBox`
* circular containers
* radial gradients
* low-alpha semantic colors

Avoid expensive blur effects unless existing project conventions already support them.

Do not create a custom painter for these effects.

---

## 10. Top Navigation

Transactional header:

* horizontal mobile margin
* approximately 64px height
* leading back action
* centered Dorak brand
* balancing trailing spacer

Back behavior:

```text
013
 ↓
012
```

Use authentication navigation.

Do not use direct global navigation from the screen.

The back icon must support RTL.

---

## 11. Main Password Reset Card

The HTML uses a translucent “glass panel”.

Flutter should approximate this with the established Dorak visual language:

* tonal surface
* subtle transparency if supported
* subtle border
* low elevation/shadow
* rounded container
* clean spacing

Do not duplicate the HTML's literal:

```text
rgba(...)
backdrop-filter
box-shadow(...)
```

Map it to the existing design system.

Do not create a global `GlassPanel` design-system component only for this screen.

---

## 12. Header Section

The card header contains:

```text
lock_reset icon
Create New Password
Your new password must be different from previous passwords.
```

Use the Material icon corresponding to:

```text
lock_reset
```

Use existing semantic tokens.

Suggested localization keys:

```text
createNewPasswordTitle
createNewPasswordSubtitle
```

Check existing ARB keys before creating duplicates.

---

## 13. Title

Stitch title:

```text
Create New Password
```

Use the appropriate existing Dorak headline/display typography.

Do not copy the export's separate `display-lg-mobile` token into the global design system.

The screen should use the existing Dorak typography API.

---

## 14. Supporting Text

Stitch intent:

```text
Your new password must be different from previous passwords.
```

Important:

Only keep this requirement if it is technically meaningful for the actual backend.

The backend may not know historical passwords or enforce password non-reuse.

Therefore, before displaying this as a hard product claim, inspect the backend behavior.

If the backend does not enforce password history, prefer safer copy that does not make a false guarantee.

Use a localized key.

---

## 15. New Password Field

Required:

* visible persistent label
* password input
* hidden password by default
* show/hide visibility action
* secure keyboard/input configuration
* appropriate autocomplete/password-manager configuration
* focus state
* error state
* directional-safe layout

Visual structure:

```text
Label
└── Input container
    ├── lock icon
    ├── password text field
    └── visibility toggle
```

Use the existing app-local authentication field implementation if it can represent this correctly.

Do not move `AuthTextField` to `design_system` as part of this screen.

---

## 16. Password Visibility

Behavior:

```text
hidden
 ↕
visible
```

Use the existing auth password-visibility implementation/pattern where available.

The visibility icon must be decorative to the text field action but still expose an accessible semantic label, such as:

```text
Show password
Hide password
```

Localize these labels.

---

## 17. Password Requirements

The Stitch screen shows live requirements:

```text
At least 8 characters
Letters and numbers
```

Each requirement switches from incomplete to complete as the password changes.

This is an interaction requirement, but the exact rules must come from the real backend contract.

Implementation should therefore:

1. Inspect backend password validation.
2. Compare with existing client validation.
3. Keep only rules that are actually authoritative.
4. Localize every requirement.
5. Update the requirement indicators live.

Do not use decorative validation rules that disagree with the server.

---

## 18. Requirement State Visuals

Incomplete:

* neutral text
* unchecked icon

Complete:

* positive/primary visual
* check icon

Use existing semantic colors.

Do not introduce raw colors.

The exact icon can follow the Stitch intent, using Material icons.

---

## 19. Confirm New Password Field

Second field:

```text
Confirm New Password
```

Use:

* persistent label
* password masking
* visibility toggle
* matching validation
* focused state
* error state

The confirmation value must match the new-password value.

This is a client-side validation rule and should also be enforced by backend submission.

---

## 20. Password-Mismatch Error

When confirmation is non-empty and does not match:

* show localized error
* use `error` semantic color
* visually mark confirmation field as invalid
* preserve layout stability where possible

Suggested key:

```text
createNewPasswordMismatch
```

Reuse an existing confirmation mismatch localization key if one already exists and is semantically appropriate.

---

## 21. System Error

The Stitch screen has an error banner for failures such as:

```text
Network error. Please try again.
```

In Flutter:

* use the project's existing error-state/banner pattern if appropriate
* use localized text
* preserve layout hierarchy
* provide retry through the primary action
* do not expose backend raw messages

Do not hardcode:

```text
Connection timed out. Please try again.
```

Use existing exception mapping conventions.

---

## 22. Reset Password Button

Primary CTA:

```text
Reset Password
```

Requirements:

```text
disabled
enabled
loading
success / transition
error
```

The button is enabled only when:

```text
password valid
AND
confirmation present
AND
passwords match
```

The exact password rules must follow the actual backend contract.

Use the existing `PrimaryButton` where compatible.

Do not create another button implementation.

During submission:

* disable repeated taps
* show loading indicator
* preserve the current form values
* do not navigate until backend success

---

## 23. Reset Password Request

On successful local validation:

```text
013 Create New Password
        ↓
AuthRepository.resetPassword(...)
        ↓
ApiClient
        ↓
backend
```

Send exactly the fields required by the existing repository/backend contract.

Possible fields must be confirmed from source, not guessed.

Do not call Dio directly.

Do not add a new HTTP stack.

Do not place password-reset business logic in a widget.

---

## 24. Successful Reset

On successful password reset:

```text
013
 ↓
014 Password Reset Success
```

Navigation must be owned by `app.router.dart` (go_router).

Do not show a browser-style `alert`.

Do not simulate success.

Do not use random success/failure behavior.

The HTML's:

```text
Math.random()
alert(...)
```

is demo-only behavior and must NOT exist in Flutter.

---

## 25. Recovery Context

The screen may require context from 012.

Examples:

```text
email
reset token
verified recovery identifier
```

The actual requirement must come from the backend contract.

Pass only the minimum required state.

Prefer explicit screen/navigation parameters over:

* global variables
* shared mutable singletons
* storage
* service locator

---

## 26. Error Handling

Continue using the existing exception taxonomy:

```text
ValidationException
NetworkException
ApiException
```

For `422`:

* map field errors appropriately
* display localized field-specific copy
* preserve server validation semantics

For network failure:

* display retryable local error
* keep the screen usable

For other API failures:

* use existing error mapping conventions

Never render:

```text
ApiException.message
```

because backend messages may be untranslated.

---

## 27. Security

This screen deals with a password.

Do not:

* log password values
* log confirmation password
* persist passwords
* include passwords in analytics
* include password values in debug output
* expose password values through exceptions

Use secure text input.

Password fields should not be retained after successful navigation.

---

## 28. Keyboard / Focus

Use normal Flutter form behavior:

* secure keyboard
* `TextInputAction.next`
* final field can submit
* visibility toggles must preserve focus
* form should remain accessible when keyboard is open

Avoid fixed-height vertical layouts that cause clipping when the keyboard appears.

The page should allow scrolling if needed on short screens or large text scale.

---

## 29. Animation

The export uses staggered:

```text
fade + translateY
delay 100ms
delay 200ms
delay 300ms
```

Use the existing Dorak animation conventions.

Do not introduce a third-party animation package.

Keep animation modest and deterministic.

---

## 30. Responsive Layout

Primary target is mobile.

Use existing Dorak dimensions rather than copying:

```text
20px
24px
48px
```

as raw values where equivalent tokens exist.

The form should remain usable under:

* narrow phone width
* large text scale
* Arabic text
* keyboard open

The two password fields must not horizontally overflow.

---

## 31. RTL

Arabic must work correctly.

Use:

* `AlignmentDirectional`
* `EdgeInsetsDirectional`
* `TextAlign.start`
* directional icon behavior

Password input text itself can remain logically left-oriented where Flutter/input semantics require it, but the surrounding layout must remain RTL-safe.

Do not hardcode left/right positioning for icons.

---

## 32. Accessibility

Required:

* visible labels
* semantic labels for visibility toggles
* clear button semantics
* accessible validation errors
* focus states
* sufficient touch targets

Requirement indicators must not rely only on color.

---

## 33. Existing Components to Inspect

Before implementation inspect:

```text
apps/client_app/lib/src/features/auth/widgets/auth_text_field.widget.dart
apps/client_app/lib/src/features/auth/login.screen.dart
apps/client_app/lib/src/features/auth/sign_up.screen.dart
apps/client_app/lib/src/features/auth/widgets/sign_up_content.widget.dart
apps/client_app/lib/src/features/auth/auth_validators.entity.dart
apps/client_app/test/auth_flow_test.dart

packages/core/.../repositories/auth.repository.dart
packages/core/.../network/endpoints/auth.endpoints.dart
packages/core/.../dto/
```

Likely reusable pieces:

```text
AuthTextField
PrimaryButton
AuthHeader
AuthErrorBanner
```

Reuse only when their existing behavior matches the screen.

---

## 34. Expected File Structure

Preferred:

```text
apps/client_app/lib/src/features/auth/
├── create_new_password.screen.dart
└── widgets/
    └── create_new_password_content.widget.dart
```

If the existing password field needs a small reusable extension, keep it local to auth unless another app genuinely needs it.

Do not preempt Track 15.

---

## 35. Localization

Inspect existing ARB keys first.

Reuse where appropriate.

New concepts may include:

```text
createNewPasswordTitle
createNewPasswordSubtitle
createNewPasswordLabel
createNewPasswordHint
createNewPasswordConfirmLabel
createNewPasswordConfirmHint
createNewPasswordMismatch
createNewPasswordRequirementLength
createNewPasswordRequirementMix
createNewPasswordReset
createNewPasswordResetting
showPassword
hidePassword
```

Do not add all of these blindly.

Use existing equivalents when they already exist.

Every new user-visible string must exist in:

```text
packages/localization/l10n/app_en.arb
packages/localization/l10n/app_ar.arb
```

Run localization generation afterward.

---

## 36. Tests

Add/update tests for:

### Initial rendering

* title
* subtitle
* two password fields
* requirement indicators
* Reset Password button

### Password behavior

* password hidden initially
* visibility toggle works
* password validation updates live
* requirement indicators update correctly
* confirmation validation updates live
* mismatch state displays correctly

### Submission

* invalid form cannot submit
* valid form submits
* duplicate submission is prevented
* loading state is correct
* success proceeds to 014

### Backend validation

* 422 password validation is mapped correctly
* confirmation validation is surfaced correctly

### Network/API failures

* network failure is displayed
* retry is possible
* raw backend message is never shown

### Navigation

* back returns to 012
* success proceeds to 014

### Regression

Existing login/register password validation must continue to pass if shared validation code is changed.

---

## 37. Stitch-to-Flutter Deviations

### Deviation 1 — `DESIGN.md`

This export's `DESIGN.md` names:

```text
Dorak High-End Grooming & Beauty
```

and contains a different token set.

Do not replace the Dorak global design system.

The screen must use the existing Dorak design system.

### Deviation 2 — Password validation

The HTML requires:

```text
8+ characters
letters + numbers
```

This must be reconciled against the real backend before implementation.

Backend rules win.

### Deviation 3 — Fake success/failure

HTML simulates network behavior randomly.

Flutter must use the real `AuthRepository.resetPassword()` flow.

No random behavior.

### Deviation 4 — JavaScript alerts

Do not reproduce browser `alert()`.

Use real navigation to 014.

### Deviation 5 — Success color

HTML swaps the button to a hardcoded green.

Do not introduce raw green styling in app code.

Success is represented by actual navigation to Stitch 014.

### Deviation 6 — CSS blur

Translate the glass/blur visual into existing Flutter-compatible Dorak decoration rather than copying CSS behavior.

---

## 38. Acceptance Criteria

```text
[ ] Screen visually matches Stitch 013.
[ ] Existing Dorak design system is used.
[ ] The conflicting export DESIGN.md does not replace global tokens.
[ ] No raw color literals in app code.
[ ] No hardcoded user-visible strings.
[ ] EN + AR localization exists.
[ ] Backend password contract was inspected before validation rules were finalized.
[ ] Password field supports secure input.
[ ] Password visibility toggles work.
[ ] Confirmation visibility toggle works.
[ ] Password requirements update correctly.
[ ] Password mismatch is displayed correctly.
[ ] Reset Password remains disabled until valid.
[ ] Loading state prevents duplicate requests.
[ ] Real resetPassword repository method is used.
[ ] No direct Dio/API call from UI.
[ ] No simulated/random success behavior.
[ ] Validation errors are mapped correctly.
[ ] Network/API errors are handled correctly.
[ ] Backend messages are never rendered directly.
[ ] Recovery context from 012 is preserved correctly.
[ ] Successful reset navigates to 014.
[ ] Back returns to 012.
[ ] RTL works.
[ ] Accessibility semantics exist.
[ ] Existing authentication password flows do not regress.
[ ] Tests pass.
[ ] Analyze passes.
[ ] Taxonomy passes.
[ ] Full melos verify passes.
```

---

## 39. Verification

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

Do not mark Stitch 013 as migrated unless the gate passes.

---

## 40. Export Cleanup

Only after implementation and verification:

```text
Verify
  ↓
Confirm plan/code alignment
  ↓
Delete:
docs/stitch/exports/013_create_new_password/
```

Never delete the export before verification.

---

## 41. Final Implementation Principle

Use this plan as the normalized implementation contract.

The coding agent may inspect:

```text
code.html
screen.png
```

to validate visual details.

It must use:

```text
plan.md
AGENTS.md
CLAUDE.md
existing Flutter implementation
actual repository contract
actual backend contract
```

for engineering decisions.

When Stitch conflicts with the real backend or the established Dorak architecture, the real backend and architecture win. Record the deviation instead of silently copying the Stitch behavior.
