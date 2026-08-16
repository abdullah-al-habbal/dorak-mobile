# Stitch 011 — Forgot Password Initial Screen

## 1. Screen Identity

* Stitch export: `011_forgot_password_initial_screen`
* Screen: Forgot Password — Initial Step
* Feature: Authentication / Password Recovery
* Client app: `apps/client_app`
* Track: `Track 16 — Authentication`
* Feature registry: `CL-08b`
* Previous screen: Login (`Stitch 007`)
* Next screen: Forgot Password OTP Verification (`Stitch 012`)

This screen is the first screen in the password-recovery flow.

---

## 2. Source of Truth

### Visual source

```text
docs/stitch/exports/011_forgot_password_initial_screen/screen.png
```

Use the screenshot for visual comparison.

### Layout source

```text
docs/stitch/exports/011_forgot_password_initial_screen/code.html
```

Read the HTML for structure and interaction intent only.

Do not copy HTML or Tailwind classes into Flutter.

### Global design source

```text
packages/design_system
```

The export `DESIGN.md` is the global Dorak design specification already represented by the existing design system.

Do not regenerate or duplicate:

* colors
* typography
* spacing
* radii
* theme
* global design tokens

Use the existing:

* `DorakColors`
* `DorakTypography`
* `DorakDimensions`
* `DorakTheme`

---

## 3. Product / Engineering Context

Password recovery infrastructure already exists in `packages/core`.

The existing authentication repository already exposes password-recovery methods.

Do not invent a new API endpoint.

Inspect the existing `AuthRepository` / `DioAuthRepository` implementation and use its existing `forgotPassword` contract.

The backend contract is authoritative over the Stitch mockup.

### Important Stitch/backend discrepancy

Stitch displays:

```text
Email or Phone
```

and describes the input as:

```text
Enter the email or phone number associated with your account...
```

The real backend currently supports email-based authentication/recovery only.

Therefore Flutter MUST NOT implement phone recovery.

The implementation must use email.

The final localized UI copy must therefore be adjusted to communicate email-based recovery rather than pretending that phone recovery is supported.

Document this as an intentional Stitch-to-product deviation.

---

## 4. Architecture Rules

Follow:

```text
Screen
  ↓
AppRouter (go_router)
  ↓
Repository
  ↓
ApiClient
  ↓
Backend
```

The screen is dumb.

The screen must:

* render UI
* validate local input
* expose callbacks
* display loading/error state

The screen must NOT:

* call `AuthRepository` directly
* call `ApiClient`
* access storage
* perform navigation decisions
* own application-wide session logic

Flow logic belongs in the router (go_router).

Use the existing:

```text
apps/client_app/lib/src/core/navigation/app.router.dart
apps/client_app/lib/src/core/navigation/app_routes.entity.dart
```

Do not introduce another routing mechanism.

---

## 5. Expected Flutter Files

Preferred structure:

```text
apps/client_app/lib/src/features/auth/
├── forgot_password.screen.dart
└── widgets/
    └── forgot_password_content.widget.dart
```

Do not create unnecessary files.

A separate widget/file should only be created when it improves reuse or keeps the screen atomic.

Use existing shared components whenever they already represent the design correctly.

Potentially reusable existing components:

```text
PrimaryButton
SecondaryButton
```

Inspect their actual appearance before using them.

Do not duplicate them.

Do not prematurely move feature-local authentication widgets into `design_system`.

---

## 6. Screen Layout

Overall structure:

```text
Scaffold
└── SafeArea
    ├── Top App Bar
    │   ├── Back button
    │   └── Centered "Dorak" brand
    │
    └── Main content
        └── Constrained authentication form
            ├── Title
            ├── Supporting text
            ├── Email field
            ├── Reserved validation/error area
            ├── Send Code button
            └── Return to Log In button
```

Authentication content should remain constrained to the existing narrow-form width used by the design system.

The layout should follow the existing mobile authentication patterns rather than creating a new page shell.

---

## 7. Top App Bar

Implement:

* full-width background matching the screen background
* mobile horizontal margin using design-system dimensions
* approximately 64px height
* circular back control
* centered `Dorak` brand text
* visual balance between back button and centered brand

Back button:

* approximately 40x40
* circular interaction target
* ghost/icon style
* arrow direction must respect RTL

Use Flutter's directional layout behavior.

Do not hardcode left/right positioning.

The screen must use the existing application navigation abstraction.

Back action should return to Login.

---

## 8. Main Content

Use:

* centered content
* horizontal mobile margin
* narrow maximum content width
* top spacing consistent with authentication screens
* vertically stacked layout

The Stitch screen uses:

* title
* 8/16-ish vertical grouping rhythm
* approximately 24px form spacing
* larger spacing before the main form
* bottom action grouping

Do not copy literal HTML pixel values blindly.

Map layout values to existing Dorak dimensions where equivalents exist.

---

## 9. Heading

Visual intent:

```text
Forgot Password?
```

Use:

```text
DorakTypography.headlineLgMobile
```

on mobile.

Use the existing responsive typography conventions if desktop behavior is implemented.

The heading is centered.

Use localization.

Do not hardcode the string.

Suggested localization key:

```text
forgotPasswordTitle
```

---

## 10. Supporting Text

Stitch intent:

```text
Enter the email ... and we'll help you reset your password.
```

Because phone recovery is not supported by the backend, do NOT copy the Stitch wording literally.

The implementation should communicate email-based recovery.

Suggested localization key:

```text
forgotPasswordSubtitle
```

The string must exist in:

```text
app_en.arb
app_ar.arb
```

Arabic must be a real translation.

---

## 11. Email Input

The backend requires email recovery.

Use an email input, not generic phone/email text.

Recommended semantic behavior:

* `TextFormField`
* `keyboardType: TextInputType.emailAddress`
* appropriate email autofill configuration
* text input action suitable for form submission
* required validation
* controller managed by the relevant screen/content state
* error state displayed below the field
* focus state follows Dorak design tokens

Stitch structure:

```text
Label
Input
Error / reserved validation area
```

The field visually uses:

* light surface/container background
* outline border
* primary focus border
* rounded corners
* Dorak body typography

Use the existing design-system tokens.

Do not use raw colors.

Suggested localization:

```text
forgotPasswordEmailLabel
forgotPasswordEmailHint
forgotPasswordEmailValidation
```

Reuse an existing email validation message/key if one already exists.

Do not create a duplicate localization key when an equivalent existing key is available.

---

## 12. Validation

Local validation should happen before the repository call.

Required cases:

```text
empty email
invalid email
valid email
```

Use the existing authentication validation conventions.

Do not invent a different email-validation rule without checking the existing auth validators.

The submit button must remain disabled until the required input is usable, matching the Stitch interaction.

Validation errors must be localized.

---

## 13. Send Code Button

Primary CTA:

```text
Send Code
```

Suggested localization key:

```text
forgotPasswordSendCode
```

Use the existing `PrimaryButton` if its current API and appearance match the design.

Required states:

```text
idle
loading
success
validation/error
```

During loading:

* disable repeated submission
* show the existing loading treatment supported by `PrimaryButton`
* do not allow duplicate requests

Never manually create another loading architecture.

---

## 14. Forgot Password Request

On valid submission:

```text
ForgotPasswordScreen
        ↓
AppRouter / auth flow
        ↓
AuthRepository.forgotPassword(...)
        ↓
ApiClient
        ↓
POST password-recovery endpoint
```

Use the existing repository method.

Do not call Dio directly.

Do not create a new repository.

Do not invent request fields.

Inspect the existing repository method signature and send exactly what it expects.

---

## 15. Success Behavior

When `forgotPassword` succeeds:

```text
011 Forgot Password
        ↓
012 Forgot Password OTP Verification
```

Navigate through the existing authentication flow (go_router routes in
`app.router.dart`).

Do not navigate directly from the screen using a new routing mechanism.

The router owns the transition.

The destination must receive whatever recovery context is required by the existing backend/repository contract, such as the email address, without leaking unnecessary state globally.

---

## 16. Error Behavior

### Validation error

A backend `422` must use the existing `ValidationException`.

Where possible:

* map the field-specific error to the email field
* preserve the existing error taxonomy
* use local UI strings when backend copy is not trusted

### Network error

Show a retryable user-facing error.

Do not render raw backend messages.

### Generic API error

Use the existing authentication error mapping conventions.

Never render:

```text
ApiException.message
```

because the backend may return untranslated message keys.

Follow the same pattern already used by:

```text
auth_error.entity.dart
```

---

## 17. Reserved Error Area

The HTML explicitly reserves vertical space below the input for errors.

Preserve this behavior.

Reason:

An error appearing/disappearing should not cause the CTA to jump dramatically.

Use the existing spacing conventions rather than reproducing Tailwind's exact `min-h`.

---

## 18. Return to Login

Secondary action:

```text
Return to Log In
```

Behavior:

```text
011
 ↓
Login
```

Use the existing authentication flow (go_router).

The action should be visually secondary:

* transparent background
* primary text
* rounded interaction area
* hover/pressed feedback where relevant

Use an existing shared component only if it actually matches.

Do not create a generic design-system component only for this one screen.

Suggested localization key:

```text
forgotPasswordReturnToLogin
```

---

## 19. Back Button

The top-left/top-leading back button and the "Return to Log In" action both return to Login.

The back icon must be directional.

Do not hardcode:

```text
Icons.arrow_back
```

for RTL without checking the existing project convention.

Follow the established auth/header directional-icon pattern.

---

## 20. Animation

Stitch includes:

```text
fadeIn
slideUp
```

Use the existing Dorak motion convention.

The project convention already prefers:

```text
fade + slide-up
```

with staggered timing.

Do not introduce a separate animation library.

A simple screen-entry animation is sufficient.

Prefer existing animation patterns already used by auth/onboarding screens.

---

## 21. Responsive Behavior

Mobile is the primary target.

Respect:

```text
20px mobile horizontal margin
64px desktop margin
max-width ~448px authentication form
```

Use existing design-system dimensions/constants where available.

Avoid hardcoded left/right coordinates.

The screen must remain usable with larger text sizes.

Do not introduce fixed heights that can cause text clipping.

---

## 22. RTL

Arabic must work correctly.

Use:

* directional alignment
* `AlignmentDirectional`
* `EdgeInsetsDirectional` where appropriate
* `TextAlign.start`
* directional icons

Do not hardcode left/right placement.

The centered title/brand should remain centered in RTL.

The back control must point in the correct visual direction.

---

## 23. Accessibility

Provide:

* semantic label for back control
* semantic button names
* appropriate text field label
* keyboard navigation
* sensible autofill behavior
* visible focus state
* sufficient touch targets

The input must be discoverable by screen readers with a meaningful semantic label.

---

## 24. State Ownership

Do not create a global auth-recovery state manager yet unless the existing architecture requires it.

For this initial implementation, keep screen/form interaction state local where appropriate.

Repository interaction must remain behind `AuthRepository`.

Use the project's canonical **Bloc + repository** approach if async state needs
to be shared across screen transitions (flutter_bloc; no new `ChangeNotifier`).

Do not introduce:

* Riverpod
* Bloc
* Provider
* GetIt

---

## 25. Localization

Before implementation:

1. Inspect existing localization keys.
2. Reuse existing keys whenever possible.
3. Add only missing keys.
4. Add every new key to both:

   * `app_en.arb`
   * `app_ar.arb`
5. Run localization generation.

Expected concepts:

```text
Forgot password title
Forgot password explanatory text
Email label
Email hint
Validation error
Send Code
Return to Log In
Loading/error/retry text where required
```

Do not add keys mechanically if equivalent auth keys already exist.

---

## 26. Expected Navigation Flow

```text
Login Screen
     │
     │ Forgot Password
     ▼
011 Forgot Password
     │
     │ valid email + Send Code
     ▼
AuthRepository.forgotPassword()
     │
     │ success
     ▼
012 Forgot Password OTP
```

Back:

```text
011
 ↓
Login
```

Return to Login:

```text
011
 ↓
Login
```

---

## 27. Existing Components to Reuse

Before creating anything, inspect and reuse:

```text
PrimaryButton
SecondaryButton
AuthHeader
AuthTextField
AuthErrorBanner
```

However, reuse only when visual/behavioral semantics actually match this Stitch screen.

Do not force the screen into an existing widget that has a materially different design.

In particular, the Stitch input is not automatically equivalent to the existing `AuthTextField`. Compare its actual implementation before deciding.

---

## 28. Expected File Structure

Preferred result:

```text
apps/client_app/lib/src/features/auth/
├── forgot_password.screen.dart
└── widgets/
    └── forgot_password_content.widget.dart
```

Additional files should only be introduced when justified by architecture.

If a reusable widget is truly needed by multiple authentication screens, document why.

Do not move reusable candidates into `design_system` prematurely.

---

## 29. Tests

Add/update widget and unit tests covering:

### Initial state

* title rendered
* subtitle rendered
* email field rendered
* Send Code disabled when email is empty
* Return to Log In visible

### Validation

* empty email rejected
* invalid email rejected
* valid email accepted

### Loading

* submitting valid email enters loading
* duplicate submission is prevented

### Success

* repository succeeds
* navigation proceeds to 012
* submitted email/recovery context is preserved as required

### Validation API error

* 422 is mapped correctly
* email field displays the appropriate error

### Network/API failure

* network error is user-visible
* retry remains possible
* raw backend message is never rendered

### Navigation

* top back returns to Login
* Return to Log In returns to Login

### Localization / RTL

At minimum verify the screen does not use hardcoded directional layout assumptions.

Use existing project test fakes.

Do not hit a real network.

Use the project's phone viewport test setup.

---

## 30. Stitch-to-Flutter Deviations

Record these explicitly:

### Deviation 1 — Email only

Stitch says:

```text
Email or Phone
```

Actual backend supports email-based recovery.

Flutter must implement:

```text
Email
```

This is deliberate and required.

### Deviation 2 — Design tokens

Do not reproduce Stitch's raw Tailwind colors/fonts in Flutter.

Use the existing Dorak design system.

### Deviation 3 — Button behavior

The global Stitch prose describes a trailing icon on primary buttons, but the existing Dorak `PrimaryButton` is intentionally label-based and validated against the current app architecture.

Do not add a new trailing icon just because the HTML/design prose mentions it unless the current screen-specific visual reference clearly requires it and the shared button API is intentionally changed.

### Deviation 4 — HTML-only behaviors

Do not copy JavaScript or Tailwind implementation.

Translate behavior into Flutter state/navigation patterns.

---

## 31. Acceptance Criteria

The screen is acceptable only when:

```text
[ ] Screen matches Stitch visual hierarchy closely.
[ ] Uses existing Dorak design tokens.
[ ] No raw color literals in app code.
[ ] No hardcoded user-visible strings.
[ ] English + Arabic localization exists.
[ ] Email-only behavior matches backend reality.
[ ] Existing AuthRepository is used.
[ ] No new HTTP stack is introduced.
[ ] No new state-management library is introduced.
[ ] Navigation stays in the go_router flow (app.router.dart).
[ ] Screen remains dumb.
[ ] Loading state works.
[ ] Validation state works.
[ ] API error state works.
[ ] Success navigates to 012.
[ ] Back/Return to Login works.
[ ] RTL works.
[ ] Tests pass.
[ ] Analyze passes.
[ ] Taxonomy passes.
[ ] Full melos verify passes.
```

---

## 32. Verification

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

The final authoritative gate is:

```bash
dart run melos run verify
```

Do not mark the export migrated unless the gate passes.

---

## 33. Export Cleanup

After implementation is fully verified:

```text
Verify
  ↓
Confirm plan/code alignment
  ↓
Delete:
docs/stitch/exports/011_forgot_password_initial_screen/
```

Do not delete the export before verification.

The plan should be retained in git history through the implementation diff, not treated as a permanent runtime dependency.

---

## 34. Final Implementation Principle

The agent must implement this plan, not reinterpret the Stitch HTML from scratch.

The agent may inspect:

```text
code.html
screen.png
```

to validate visual details.

The agent must rely on:

```text
plan.md
+
AGENTS.md
+
CLAUDE.md
+
existing Flutter code
+
existing backend contract
```

for implementation decisions.

When Stitch conflicts with the real backend or repository architecture, the real backend/architecture wins and the deviation must be documented.
