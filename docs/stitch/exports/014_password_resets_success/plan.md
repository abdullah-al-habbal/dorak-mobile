# Stitch 014 — Password Reset Success

## 1. Screen Identity

* Stitch export: `014_password_resets_success`
* Screen: Password Reset Success
* Feature: Authentication / Password Recovery
* Client app: `apps/client_app`
* Track: `Track 16 — Authentication`
* Feature registry: `CL-08b`
* Previous screen: `013 Create New Password`
* Next destination: Login

This screen is the terminal success state of the password-recovery flow.

---

## 2. Source of Truth

### Visual source

```text
docs/stitch/exports/014_password_resets_success/screen.png
```

Use the screenshot for visual verification.

### Layout source

```text
docs/stitch/exports/014_password_resets_success/code.html
```

Read the HTML for:

* layout
* visual hierarchy
* interaction intent
* success-state presentation
* animation intent

Do not copy HTML or Tailwind classes into Flutter.

### Global design source

This export's `DESIGN.md` is the canonical Dorak global design specification already represented by:

```text
packages/design_system
```

Do not regenerate or duplicate:

* colors
* typography
* spacing
* radii
* theme

Use the existing:

* `DorakColors`
* `DorakTypography`
* `DorakDimensions`
* `DorakTheme`

---

## 3. Product / Flow Context

Complete password-recovery flow:

```text
011 Forgot Password
        ↓
012 OTP Verification
        ↓
013 Create New Password
        ↓
014 Password Reset Success
        ↓
Login
```

This screen is shown only after the backend confirms that the password reset succeeded.

It must not:

* call the reset-password API
* retry the reset operation
* perform repository work
* simulate success
* use random success/failure behavior

The actual success decision happens in 013.

---

## 4. Architecture Rules

This is a presentation-only terminal screen.

The screen should:

* render success state
* expose a Login action callback

The screen must NOT:

* call `AuthRepository`
* call `ApiClient`
* access storage
* make API calls
* decide authentication routing
* import routing code

Navigation remains owned by:

```text
apps/client_app/lib/src/core/navigation/app.router.dart
apps/client_app/lib/src/core/navigation/app_routes.entity.dart
```

---

## 5. Expected Flutter Files

Preferred structure:

```text
apps/client_app/lib/src/features/auth/
├── password_reset_success.screen.dart
└── widgets/
    └── password_reset_success_content.widget.dart
```

Keep the implementation small.

Do not create unnecessary abstractions for a single terminal screen.

Reuse existing shared components where they genuinely fit.

---

## 6. Screen Layout

Overall structure:

```text
Scaffold
├── Background decorative layers
│
└── Centered content
    ├── Dorak brand
    └── Success card
        ├── Success icon
        ├── Title
        ├── Supporting text
        └── Log In button
```

The screen is centered vertically and horizontally.

The content should remain constrained to the existing authentication max-width.

---

## 7. Background

Stitch uses two large atmospheric blurred circles:

```text
top-right
    secondary-fixed

bottom-left
    primary-fixed-dim
```

Translate this into the existing Dorak Flutter visual language.

Prefer inexpensive decorative elements such as:

* circular containers
* radial gradients
* low-alpha semantic colors

Avoid adding a custom painter.

Avoid expensive blur unless there is an established reusable implementation.

The background is decorative only and must not affect layout or interaction.

---

## 8. Brand

Stitch displays:

```text
Dorak
```

above the success card.

Use the same branding treatment already used by the authentication flow.

Do not introduce a second brand widget if an existing authentication/header implementation can be reused.

The brand should be localized only if the existing brand implementation treats it as localizable; otherwise keep the established brand treatment.

Do not hardcode arbitrary typography values from Stitch.

Use the existing Dorak typography system.

---

## 9. Success Card

The main content is a soft glass-like panel.

Visual characteristics:

* light translucent surface
* rounded corners
* subtle border
* very light elevation/shadow
* centered contents

Translate the HTML `glass-panel` into the project's existing Flutter design approach.

Do not copy:

```text
rgba(...)
backdrop-filter
box-shadow(...)
```

literally.

Do not create a new global `GlassPanel` component solely for this screen.

Use existing Dorak semantic surface tokens.

---

## 10. Success Icon

Use:

```text
check_circle
```

from Flutter Material icons.

Visual intent:

```text
large circular container
    ↓
tertiary-fixed background
    ↓
primary-colored check icon
```

Use semantic design-system colors.

Do not use raw hex values.

The icon is decorative confirmation.

The text must still communicate the success state clearly.

---

## 11. Success Icon Sizing

Stitch uses a large circular icon container approximately:

```text
80 × 80
```

with an icon around:

```text
40
```

Use existing dimension conventions where possible rather than introducing arbitrary values.

The icon should remain visually centered.

---

## 12. Success Title

Stitch:

```text
Password Updated
```

Use a localized string.

Suggested key:

```text
passwordResetSuccessTitle
```

Reuse an equivalent existing localization key if one already exists.

Typography should use the existing Dorak heading token rather than copying the screen's Tailwind typography class directly.

---

## 13. Supporting Text

Stitch:

```text
Your password has been successfully changed. You can now log in with your new password.
```

Use localization.

Suggested key:

```text
passwordResetSuccessSubtitle
```

The text should remain constrained to a readable width.

Preserve centered alignment.

Do not hardcode a fixed width that breaks Arabic or larger text scales.

---

## 14. Login Button

Primary CTA:

```text
Log In
```

Suggested localization key:

```text
passwordResetSuccessLogin
```

Reuse the existing `PrimaryButton` if its current API/visual semantics match.

The button must be:

* full width within the success card
* primary-styled
* pill-shaped
* accessible
* responsive

Do not recreate a custom primary button.

---

## 15. Login Navigation

The Stitch HTML contains:

```text
href="{{DATA:SCREEN:SCREEN_18}}"
```

This is a Stitch placeholder.

It is NOT a Flutter route and must not be copied.

Flutter behavior:

```text
014
 ↓
Log In
 ↓
Login screen
```

Navigation must go through the existing authentication navigation architecture (go_router).

The screen receives a callback such as:

```text
onLogin
```

and does not know the route implementation.

The router owns the actual transition.

---

## 16. Stack Behavior

Because password recovery is complete, the user should not be able to press Back repeatedly and return through:

```text
014
↓
013
↓
012
↓
011
```

after choosing Login, unless that behavior is explicitly desired by the existing auth navigation architecture.

Prefer the existing authentication-flow stack management so that the final Login state is the sensible destination.

Inspect `app.router.dart` before deciding whether to:

* replace the current route
* clear the recovery flow
* push Login

Do not invent a new stack behavior.

The expected user outcome is:

```text
Password reset completed
        ↓
Login
```

without leaving stale password-recovery screens underneath the final login route.

---

## 17. No Repository / API Work

014 must not call:

```text
AuthRepository
ApiClient
Dio
SessionController
```

The reset has already succeeded.

This screen is purely the confirmation UI and navigation handoff.

---

## 18. Animation

Stitch uses:

```text
fade + slide up
duration ≈ 800ms
curve ≈ Cubic(0.16, 1.0, 0.3, 1.0)
```

and staggered delays:

```text
100ms
200ms
300ms
```

Follow the existing Dorak motion convention.

Do not introduce an animation library.

Keep the animation deterministic.

At minimum:

* brand fades/slides in
* card fades/slides in
* Login button can appear with a slight stagger

Do not over-animate the success icon.

---

## 19. Responsive Behavior

Primary target: mobile.

Use:

```text
20px mobile horizontal margins
existing authentication max-width
```

The card should remain readable on narrow screens.

Do not use fixed heights that can cause clipping.

Support:

* large text scale
* Arabic
* smaller phone widths

The supporting text must wrap naturally.

---

## 20. RTL

The success screen must support Arabic.

Use:

* `TextAlign.center`
* directional-safe layout
* semantic alignment APIs

The success icon remains centered.

The button remains centered/full-width within its parent.

There should be no hardcoded left/right positioning.

---

## 21. Accessibility

Provide:

* meaningful heading
* readable success message
* semantic Login button
* sufficient button touch target
* visible focus state

Do not rely only on the check icon to communicate success.

---

## 22. Localization

Inspect the existing ARB files before creating keys.

Likely concepts:

```text
passwordResetSuccessTitle
passwordResetSuccessSubtitle
passwordResetSuccessLogin
```

Reuse existing generic strings when semantically appropriate.

Every new visible string must exist in:

```text
packages/localization/l10n/app_en.arb
packages/localization/l10n/app_ar.arb
```

Arabic must be a real translation.

Run localization generation after changes.

---

## 23. Existing Components to Inspect

Before implementation inspect:

```text
apps/client_app/lib/src/features/auth/widgets/auth_header.widget.dart
apps/client_app/lib/src/features/auth/widgets/auth_error_banner.widget.dart
apps/client_app/lib/src/features/auth/login.screen.dart
apps/client_app/lib/src/core/navigation/app.router.dart
packages/design_system/lib/src/widgets/primary_button.widget.dart
```

Reuse only when appropriate.

Do not introduce another primary button or authentication header architecture.

---

## 24. Expected File Structure

Preferred:

```text
apps/client_app/lib/src/features/auth/
├── password_reset_success.screen.dart
└── widgets/
    └── password_reset_success_content.widget.dart
```

If the screen is small enough, the content widget may be unnecessary.

Do not create extra files merely to satisfy a template.

Maintain the repository's atomic-file convention while avoiding artificial abstraction.

---

## 25. Tests

Add/update tests covering:

### Rendering

* Dorak brand
* success icon
* Password Updated title
* supporting text
* Log In button

### Navigation

* tapping Log In calls the correct navigation callback
* navigation goes to Login
* password-recovery flow does not remain incorrectly stacked underneath Login

### Presentation

* success state is rendered without repository/API calls
* no loading state is required
* no error state is presented for the already-completed reset

### Localization / RTL

* English rendering
* Arabic rendering
* centered layout remains correct

### Regression

Existing authentication navigation tests must remain green.

Use existing test harnesses/fakes.

Do not hit the real network.

Use the project's phone viewport setup where widget testing is required.

---

## 26. Stitch-to-Flutter Deviations

### Deviation 1 — Stitch route placeholder

The HTML contains:

```text
{{DATA:SCREEN:SCREEN_18}}
```

This is Stitch-generated placeholder data.

Do not implement this as a URL or named route.

Use the existing `app.router.dart` (go_router) flow.

### Deviation 2 — Glass panel

The HTML uses CSS blur and translucent styling.

Flutter should approximate the visual using the established Dorak design system and inexpensive decoration.

Do not introduce an unrelated global glass component.

### Deviation 3 — Raw success color

The HTML uses raw purple values for the button/shadow.

Flutter must use existing Dorak semantic tokens.

No raw colors in app code.

### Deviation 4 — Success is backend-driven

014 is only reachable after the real reset-password operation succeeds.

Do not simulate or independently determine success in 014.

---

## 27. Acceptance Criteria

```text
[ ] Screen visually matches Stitch 014.
[ ] Uses existing Dorak design system.
[ ] No global design tokens are regenerated.
[ ] No raw color literals in app code.
[ ] No hardcoded user-visible strings.
[ ] EN + AR localization exists.
[ ] Success icon and messaging are present.
[ ] Log In button works.
[ ] Navigation is owned by app.router.dart (go_router).
[ ] Stitch route placeholder is not copied.
[ ] Password reset flow does not perform another API call.
[ ] Recovery screens do not remain incorrectly stacked under Login.
[ ] Animation follows existing Dorak motion conventions.
[ ] RTL works.
[ ] Accessibility semantics exist.
[ ] Existing authentication navigation does not regress.
[ ] Tests pass.
[ ] Analyze passes.
[ ] Taxonomy passes.
[ ] Full melos verify passes.
```

---

## 28. Verification

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

Do not mark Stitch 014 as migrated unless the gate passes.

---

## 29. Export Cleanup

Only after implementation and verification:

```text
Verify
  ↓
Confirm plan/code alignment
  ↓
Delete:
docs/stitch/exports/014_password_resets_success/
```

Do not delete the export before verification.

---

## 30. Final Implementation Principle

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
actual authentication navigation
```

for engineering decisions.

When Stitch conflicts with the actual Dorak architecture, the architecture wins. The Stitch export is a visual/interaction reference, not a replacement for the application's engineering contracts.
