# Integration Plan: Onboarding Welcome & Introduction

## 1. Objective
Based on `DESIGN.md`, generate atomic Flutter code for the welcome/introduction screen of the onboarding flow.

**Note:** Global design tokens (`colors`, `typography`, `dimensions`) already exist from the `001_splash` export – they are **not regenerated** here.

**Shared Components:** All reusable UI pieces (buttons, progress indicators, modals) are extracted into `lib/widgets/` to keep DRY and SOLID.

---

## 2. Source Files
| File | Action |
|------|--------|
| `DESIGN.md` | KEEP (global design system) |
| `code.html` | DELETE (obsolete) |

---

## 3. File Manifest (All Generated Files)

All generated files will be created **temporarily** inside `generated/`.  
After generation, move each to its target location in `lib/`.

| # | Temporary Path | Target Location | Description |
|---|----------------|-----------------|-------------|
| **SHARED COMPONENTS** |
| 1 | `generated/primary_button.dart` | `lib/widgets/buttons/primary_button.dart` | Reusable pill-shaped primary action button. |
| 2 | `generated/skip_button.dart` | `lib/widgets/buttons/skip_button.dart` | Reusable ghost text button (Skip, Cancel). |
| 3 | `generated/progress_dots.dart` | `lib/widgets/progress/progress_dots.dart` | Reusable dot indicator (count, active index). |
| 4 | `generated/bottom_sheet_modal.dart` | `lib/widgets/modals/bottom_sheet_modal.dart` | Reusable bottom sheet with backdrop & handle. |
| **SCREEN-SPECIFIC WIDGETS** |
| 5 | `generated/welcome_hero_image.dart` | `lib/features/onboarding/widgets/welcome_hero_image.dart` | Hero image with zoom animation. |
| 6 | `generated/welcome_gradient_overlay.dart` | `lib/features/onboarding/widgets/welcome_gradient_overlay.dart` | Gradient overlay (matches HTML). |
| 7 | `generated/welcome_header.dart` | `lib/features/onboarding/widgets/welcome_header.dart` | Brand logo + Skip button. |
| 8 | `generated/welcome_content.dart` | `lib/features/onboarding/widgets/welcome_content.dart` | Headline, subtitle, progress dots, Get Started button. |
| 9 | `generated/skip_bottom_sheet.dart` | `lib/features/onboarding/widgets/skip_bottom_sheet.dart` | Bottom sheet with skip options (uses shared modal). |
| 10 | `generated/welcome_screen.dart` | `lib/features/onboarding/welcome_screen.dart` | Main screen composing everything with staggered animations. |

---

## 4. Execution Steps

1. **Delete** `code.html`.
2. **Create** `generated/` folder.
3. **Generate** all 10 files listed above (exact content provided in subsequent messages).
4. **Update** `lib/l10n/app_localizations.dart` with all strings (see §5).
5. **(Future)** Move each file to its `Target Location` inside `lib/`, creating subfolders as needed:
   - `lib/widgets/buttons/`
   - `lib/widgets/progress/`
   - `lib/widgets/modals/`
   - `lib/features/onboarding/`
   - `lib/features/onboarding/widgets/`
6. **Delete** the temporary `generated/` folder.
7. **Handle the hero image**:
   - Option A: Download and save as `assets/images/onboarding_hero.jpg` and use `Image.asset`.
   - Option B: Keep as `Image.network` with `cacheWidth`/`cacheHeight` and add placeholder. (Add a TODO comment for production.)
8. **Verify** `pubspec.yaml` includes `assets/images/` (already added from `001_splash`).
9. **Report completion.**

---

## 5. Localization Strings

Add the following getters to `lib/l10n/app_localizations.dart`:

```dart
// From 001_splash (already exists)
String get splashTitle => 'Dorak';

// New for 002_onboarding_welcome
String get skip => 'Skip';
String get onboardingWelcomeTitle => 'Your grooming experience, reimagined.';
String get onboardingWelcomeSubtitle => 'Discover top-tier professionals, book with ease, and personalize your style journey.';
String get onboardingGetStarted => 'Get Started';
String get skipOnboardingQuestion => 'Skip Onboarding?';
String get skipForNow => 'Skip for now';
String get dontShowAgain => 'Don\'t show again';
String get cancel => 'Cancel';
```

---

## 6. App Integration
- Route: `/onboarding/welcome` or simply `/onboarding`.
- Navigation: After "Get Started" or skip actions, navigate to next onboarding step or home.

## 7. Dependencies
- `flutter/material.dart` only.
- For production, consider `cached_network_image` but avoid additional dependencies initially.

## 8. File Dependencies (Import Map)

| File | Imports |
|------|---------|
| `primary_button.dart` | `material.dart`, `tokens.dart` |
| `skip_button.dart` | `material.dart`, `tokens.dart` |
| `progress_dots.dart` | `material.dart`, `tokens.dart` |
| `bottom_sheet_modal.dart` | `material.dart`, `tokens.dart` |
| `welcome_hero_image.dart` | `material.dart`, `tokens.dart` |
| `welcome_gradient_overlay.dart` | `material.dart`, `tokens.dart` |
| `welcome_header.dart` | `material.dart`, `tokens.dart`, `skip_button.dart`, `l10n/app_localizations.dart` |
| `welcome_content.dart` | `material.dart`, `tokens.dart`, `primary_button.dart`, `progress_dots.dart`, `l10n/app_localizations.dart` |
| `skip_bottom_sheet.dart` | `material.dart`, `tokens.dart`, `bottom_sheet_modal.dart`, `skip_button.dart`, `l10n/app_localizations.dart` |
| `welcome_screen.dart` | `material.dart`, `tokens.dart`, `welcome_hero_image.dart`, `welcome_gradient_overlay.dart`, `welcome_header.dart`, `welcome_content.dart`, `skip_bottom_sheet.dart` |
---

## 9. Integration Update (monorepo)

This export was integrated into the Dorak monorepo per `CLAUDE.md`. `generated/` deleted.

- Shared widgets extracted to `packages/design_system/lib/src/widgets/`:
  - `primary_button.widget.dart`, `skip_button.widget.dart`, `progress_dots.widget.dart`
  - `hero_image.widget.dart`, `gradient_overlay.widget.dart`, `onboarding_header.widget.dart` (string-parameterized; design_system does not import localization)
  - `bottom_sheet_modal.widget.dart` (generic modal, moved here)
- Welcome screen → `apps/client_app/lib/src/features/onboarding/welcome.screen.dart` + `widgets/welcome_content.widget.dart`.
- `skip_bottom_sheet.sheet.dart` → `apps/client_app/lib/src/features/onboarding/widgets/` (uses l10n; shared across onboarding screens).
- Strings → `packages/localization/` (official intl + ARB workflow: `l10n/*.arb` + `flutter gen-l10n`).
- Hero image URL → shared constant `onboarding_hero.dart` (TODO: local asset).
