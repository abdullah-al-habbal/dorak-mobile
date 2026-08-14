# Integration Plan: Onboarding Discovery Overview

## 1. Objective
Generate atomic Flutter code for the discovery overview screen (step 2 of the client onboarding flow) and integrate it into the Dorak monorepo.

**Note:** The export `DESIGN.md` is the global design system (identical across exports) and is not screen-specific; the screen layout derives from `screen.png` (visual reference). `code.html` was deleted without being read, per the stitch-converter skill hard rule.

**Shared components:** Reused across onboarding screens and all three apps via packages. Design tokens and shared widgets live in `packages/design_system`; user-visible strings (EN + AR) live in `packages/localization`.

## 2. Source Files
| File | Action |
|------|--------|
| `DESIGN.md` | KEEP (global design system) |
| `code.html` | DELETED (obsolete, never read) |
| `screen.png` | KEEP (visual reference) |

## 3. Actual Placement (Monorepo, per `CLAUDE.md`)

All code was written directly at target locations (no `generated/` staging).

| # | File | Location | Description |
|---|------|----------|-------------|
| 1 | `discovery.screen.dart` | `apps/client_app/lib/src/features/onboarding/` | Main screen composing background, header, content; staggered entrance. |
| 2 | `discovery_content.widget.dart` | `apps/client_app/lib/src/features/onboarding/widgets/` | Heading, subtitle, card deck, progress dots (4, active 1), Next button. |
| 3 | `discovery_card_deck.widget.dart` | `apps/client_app/lib/src/features/onboarding/widgets/` | Three cards with staggered fade-slide-up entrance; takes `List<DiscoveryCardData>`. |
| 4 | `discovery_card_data.dart` | `apps/client_app/lib/src/features/onboarding/` | Plain data class (icon + label). |
| 5 | `onboarding_hero.dart` | `apps/client_app/lib/src/features/onboarding/` | Shared hero image URL constant (TODO: swap to local asset). |

## 4. Shared Components Extracted (used by 002 & 003)
| # | File | Location |
|---|------|----------|
| 1 | `hero_image.widget.dart` | `packages/design_system/lib/src/widgets/` |
| 2 | `gradient_overlay.widget.dart` | `packages/design_system/lib/src/widgets/` |
| 3 | `onboarding_header.widget.dart` | `packages/design_system/lib/src/widgets/` |
| 4 | `skip_bottom_sheet.sheet.dart` | `apps/client_app/lib/src/features/onboarding/widgets/` (uses l10n; shared across onboarding screens) |

All design-system widgets are string-parameterized — `design_system` never imports `localization` (CLAUDE.md layering).

## 5. Foundation (prerequisite for this screen)
- `packages/design_system/lib/src/tokens/` — `colors.token.dart` (light + dark `DorakColors` + `of(context)`), `typography.token.dart` (with font fallback), `dimensions.token.dart`.
- `packages/design_system/lib/src/theme/dorak_theme.theme.dart` — `DorakTheme.light` / `DorakTheme.dark`.
- `packages/localization/` — official **intl + ARB** workflow: `l10n/app_en.arb` + `l10n/app_ar.arb`, `l10n.yaml`, generated `AppLocalizations` via `flutter gen-l10n` (output `lib/src/generated/`). `supportedLocales = [en, ar]`; RTL auto-handled by Flutter's `Directionality` when `ar` is active.

## 6. Localization (EN / AR)
| Key | EN | AR |
|---|---|---|
| discoveryTitle | Find the perfect fit. | اعثر على الأنسب لك. |
| discoverySubtitle | Explore nearby shops, expert barbers, and premium services tailored to your needs. | استكشف المتاجر القريبة وأفضل الحلاقين والخدمات المتميزة المصممة لاحتياجاتك. |
| next | Next | التالي |
| discoveryCardShops | Shops | المتاجر |
| discoveryCardBarbers | Barbers | الحلاقون |
| discoveryCardServices | Services | الخدمات |

## 7. App Integration
- Flow: `SplashScreen` → `WelcomeScreen` → `DiscoveryScreen` → `HomeScreen` (placeholder).
- `apps/client_app/lib/main.dart` wires navigation, `ThemeMode.system` (light + dark), locale delegates, and supported locales.
- Route navigation uses `Navigator.push` / `pushReplacement` (no third-party router).

## 8. Dependencies
- `flutter/material.dart`, `flutter_localizations` (SDK).
- Workspace packages: `design_system`, `localization` (path dependencies in `apps/client_app/pubspec.yaml`).

## 9. Deferred / Follow-ups
- IBM Plex Sans `.ttf` bundling — `fontFamily` kept in tokens with `fontFamilyFallback`; renders fallback until fonts are added.
- Hero image local asset — currently `Image.network` with `cacheWidth`/`cacheHeight` (see `onboarding_hero.dart` TODO).
- `melos.yaml` / `analysis_options.yaml` taxonomy enforcement — referenced by `CLAUDE.md` but not yet present in the repo.
- `business_app` / `stylist_app` splash + onboarding — future exports; shared widgets already in packages.
- Dot-suffix naming adopted per `CLAUDE.md` taxonomy (`.token.dart`, `.widget.dart`, `.sheet.dart`, `.screen.dart`).
