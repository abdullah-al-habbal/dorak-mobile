# Integration Plan: Splash Screen

## 1. Objective
Based on the specifications in `DESIGN.md`, generate fully atomic, production‑ready Dart files for the Flutter codebase.

All design tokens (colors, typography, dimensions) and the splash screen UI must be implemented as small, focused, single‑responsibility files.

---

## 2. Source Files
| File | Action |
|------|--------|
| `DESIGN.md` | **KEEP** – human‑readable source of truth for all design tokens (colors, typography, spacing). |
| `code.html` | **DELETE** – the Dart implementation replaces this entirely. |
| `screen.png` | **KEEP** – visual reference (optional). |
| `plan.md` | **KEEP** – this instruction file. |

---

## 3. File Manifest (Generation & Placement)

All generated files will be created **temporarily inside** `generated/`.  
After generation, move each file to its **Target Location** in the Flutter project.

| # | Generated File (Temp Path) | Target Location (Flutter Project) | Description |
|---|----------------------------|-----------------------------------|-------------|
| 1 | `generated/colors.dart` | `lib/design_tokens/colors.dart` | All `Color` hex constants from DESIGN.md. |
| 2 | `generated/typography.dart` | `lib/design_tokens/typography.dart` | All `TextStyle` definitions (IBM Plex Sans). |
| 3 | `generated/dimensions.dart` | `lib/design_tokens/dimensions.dart` | Spacing units, `BorderRadius`, container max‑width. |
| 4 | `generated/tokens.dart` | `lib/design_tokens/tokens.dart` | Barrel export for colors, typography, dimensions. |
| 5 | `generated/splash_background.dart` | `lib/features/splash/widgets/splash_background.dart` | `StatelessWidget` – gradient background + noise texture (asset). |
| 6 | `generated/splash_logo.dart` | `lib/features/splash/widgets/splash_logo.dart` | `StatelessWidget` – animated logo (icon + brand name). |
| 7 | `generated/splash_screen.dart` | `lib/features/splash/splash_screen.dart` | `StatefulWidget` – manages animation and triggers navigation. |

---

## 4. Execution Steps (AI Agent)

1. **Create** the temporary folder: `generated/`.

2. **Generate** all 7 files listed above inside `generated/` (exact content provided in the preceding messages).

3. **Move** each generated file to its `Target Location` inside `lib/`, creating missing subfolders (`design_tokens/`, `features/splash/widgets/`) as needed.

4. **Delete** the temporary `generated/` folder after moving.

5. **Copy the Noise SVG Asset**:
   - Create the folder `assets/images/` if it doesn't exist.
   - Save the following SVG as `assets/images/noise_overlay.svg`:
   ```svg
   <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
     <filter id="noiseFilter">
       <feTurbulence type="fractalNoise" baseFrequency="0.65" numOctaves="3" stitchTiles="stitch"/>
     </filter>
     <rect width="100%" height="100%" filter="url(#noiseFilter)"/>
   </svg>
   ```

6. **Update `pubspec.yaml`**:
   - Add the asset folder under `flutter: assets:`:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
   - Ensure the `IBM Plex Sans` font is declared (see §7 below).

7. **Delete** `code.html` (it is obsolete).

8. **Update** `lib/l10n/app_localizations.dart` by adding this getter:
   ```dart
   String get splashTitle => 'Dorak';
   ```

9. **Verify** that `pubspec.yaml` includes the `IBM Plex Sans` font declaration. If missing, add:
   ```yaml
   flutter:
     fonts:
       - family: IBM Plex Sans
         fonts:
           - asset: assets/fonts/IBMPlexSans-Regular.ttf
           - asset: assets/fonts/IBMPlexSans-Medium.ttf
             weight: 500
           - asset: assets/fonts/IBMPlexSans-SemiBold.ttf
             weight: 600
           - asset: assets/fonts/IBMPlexSans-Bold.ttf
             weight: 700
   ```

10. **Report completion** to the developer.

---

## 5. App Integration
- Register the splash screen in the app router (e.g., `go_router` or `MaterialApp.routes`).
- Use the `onFinished` callback (passed to `SplashScreen`) to navigate to the next screen (e.g., `/onboarding` or `/home`) after the 2.5 s delay.

## 6. Dependencies
- `flutter/material.dart` only.
- No third‑party packages required.

## 7. Best Practices Applied
- **Asset loading** – the noise texture uses `Image.asset` with `cacheWidth`/`cacheHeight` for memory efficiency instead of a network URL.
- **Localization** – the brand name `"Dorak"` is extracted into `app_localizations.dart` for easy internationalization.
- **Animation** – uses a `SingleTickerProviderStateMixin` and a `Cubic` curve that matches the original design's easing.
- **Atomic files** – each file has exactly one responsibility, making the codebase easy to test and maintain.
---

## 8. Integration Update (monorepo)

This export was integrated into the Dorak monorepo per `CLAUDE.md`. `generated/` deleted.

- Tokens → `packages/design_system/lib/src/tokens/` (`colors.token.dart`, `typography.token.dart`, `dimensions.token.dart`, `tokens.barrel.dart`). Colors gained a dark variant + `DorakColors.of(context)`.
- Theme → `packages/design_system/lib/src/theme/dorak_theme.theme.dart` (`DorakTheme.light`/`dark`).
- Splash → `apps/client_app/lib/src/features/splash/` (`splash.screen.dart`, `widgets/splash_background.widget.dart`, `widgets/splash_logo.widget.dart`).
- Strings → `packages/localization/` (official intl + ARB workflow: `l10n/*.arb` + `flutter gen-l10n`).
- `assets/images/noise_overlay.svg` → `apps/client_app/assets/images/`.
- Font bundling deferred (no `.ttf` in repo; tokens use `fontFamilyFallback`).
