# Feature Index — Dorak Mobile (Flutter Monorepo)

> **Append entry after adding each feature.** This is the chronological map of every feature built across the monorepo. Per-app indexes: [`apps/client_app/docs/feature-index.md`](../apps/client_app/docs/feature-index.md), [`apps/business_app/docs/feature-index.md`](../apps/business_app/docs/feature-index.md), [`apps/stylist_app/docs/feature-index.md`](../apps/stylist_app/docs/feature-index.md).

---

## Shared Packages

### design_system
- `DorakColors` — `colors.token.dart`, light + dark palettes, accessed via `DorakColors.of(context)` (theme aware). All raw hex lives here, nowhere else.
- `DorakTypography` — `typography.token.dart` (IBM Plex Sans, deferred fonts via `fontFamilyFallback`).
- `DorakDimensions` — `dimensions.token.dart` (spacing, radii, max-widths).
- `tokens.barrel.dart` — barrel export of all token files.
- `DorakTheme` — `dorak_theme.theme.dart`, `DorakTheme.forLocale(locale, brightness)`.
- Shared widgets (each its own file, one class each, string-parameterized — design_system never imports localization):
  - `primary_button.widget.dart` — full-width pill, `radiusFull`, `primaryContainer`, optional `isLoading`/`isDisabled`
  - `secondary_button.widget.dart` — outlined pill for Back/secondary actions
  - `skip_button.widget.dart` — borderless shrink-wrap `TextButton`
  - `progress_dots.widget.dart` — `count` + `activeIndex`
  - `onboarding_header.widget.dart` — brand icon + label, locale toggle, Skip (all strings injected)
  - `bottom_sheet_modal.widget.dart` — modal wrapper
  - `gradient_overlay.widget.dart`
  - `hero_image.widget.dart` — local-asset-first image with remote override + `errorBuilder`
  - `swipe_navigation.widget.dart` — swipe-left/right gesture routing

### localization
- Source of truth: `l10n/app_en.arb` (template) + `app_ar.arb` (Arabic). Every key exists in BOTH locales.
- Generated output `lib/src/generated/` via `flutter gen-l10n` (committed, excluded from analyzer/taxonomy).
- RTL handled by Flutter locale resolution automatically.

### core
- `ConfigProvider` — `.env` via dotenv (`app_config.entity.dart`, `config.provider.dart`).
- `ApiClient` — Dio-based (`api.client.dart`).
- Interceptors: `auth.interceptor.dart`, `locale.interceptor.dart`, `logging.interceptor.dart`, `retry.interceptor.dart`.
- Contracts: `ApiResponse<T>` / `api_response.dto.dart`, `PaginatedData<T>`, `PaginationMeta`, exceptions (`ApiException`, `NetworkException`, `ValidationException`).
- Pagination notifiers: `page_pagination.notifier.dart`, `scroll_pagination.notifier.dart`.
- `endpoints/app.endpoints.dart` — domain-split endpoint declarations.
- `onboarding_config.repository.dart` — `OnboardingConfigRepository` + `OnboardingConfigDto` (GET /api/v1/app/onboarding-config).

### feature_floor_plan
- Stub only — `feature_floor_plan.dart` barrel, no implementation yet.

---

## Client App (`apps/client_app`)

### Splash — Stitch 001
- `splash.screen.dart` — StatefulWidget, staged fade-in (logo, tagline, foreground), 2.5s auto-advance via `onFinished`, swipe/button to advance early.
- `splash_logo.widget.dart`, `splash_background.widget.dart` — gradient + PNG noise texture.
- **Asset fix:** `noise_overlay.svg` → generated `noise_overlay.png` (Flutter `Image.asset` cannot decode SVG).

### Onboarding Welcome — Stitch 002
- `welcome.screen.dart` + `welcome_content.widget.dart` — hero image, headline, sub-text, CTA, `ProgressDots(4, 0)`, Get Started.

### Onboarding Discovery — Stitch 003
- `discovery.screen.dart`, `discovery_content.widget.dart`, `discovery_card_deck.widget.dart` (staggered fade-slide cards), `discovery_card.entity.dart` (pure value object, hand-written — no JSON wire format), `onboarding_hero.widget.dart` (local asset + remote override).
- CTA `next`, `ProgressDots(4, 1)`.

### Onboarding Booking — Stitch 004
- `booking.screen.dart`, `booking_content.widget.dart`, `booking_visual.widget.dart` — 3 tilted glass cards (service / professional / date-time), staggered fade-slide-up, `ProgressDots(4, 2)`, Back + Next.

### Onboarding AI Showcase — Stitch 005
- `ai_showcase.screen.dart`, `ai_showcase_content.widget.dart`, `ai_showcase_visual.widget.dart` — avatar + face-shape chip, two recommendation cards with mini progress bars, decorative rings, privacy note, `ProgressDots(4, 3)`, Back + Get Started.

### Onboarding Infrastructure
- `onboarding_config.notifier.dart` — `OnboardingConfigController`, loads `/app/onboarding-config` per locale, reloads on locale switch.
- `skip_bottom_sheet.sheet.dart` — shared 3-option skip sheet (Skip / Don't show again / Cancel).
- Flow wiring in `main.dart`: Splash → Welcome → Discovery → Booking → AiShowcase → Home (manual `Navigator.push`/`pushReplacement`, callback-driven; locale toggle threaded through every screen; EN/AR + RTL).

### Home
- `home.screen.dart` — placeholder landing (`homeTitle`), real dashboard TBD.

### Empty Scaffolds (not implemented)
- `features/discovery/{data,domain,presentation}`, `features/booking/{data,domain,presentation}`, `features/profile/` — directories only, no files.

---

## Business App (`apps/business_app`)

- Skeleton only — `main.dart` boots `DorakApp`, no features yet.

---

## Stylist App (`apps/stylist_app`)

- Skeleton only — `main.dart` boots `DorakApp`, no features yet.

---

## Stitch Migration Status

Each export is flagged ✅ **Migrated** (implemented in Flutter, verified by `flutter analyze` + `flutter test` + `tool/check_taxonomy.dart`, export folder deleted) or ⏳ **Pending** (folder still in `docs/stitch/exports/`).

| Export | Screen | Feature | Status |
|--------|--------|---------|--------|
| 001 | Splash | CL-01 | ✅ Migrated |
| 002 | Onboarding Welcome | CL-02 | ✅ Migrated |
| 003 | Onboarding Discovery | CL-03 | ✅ Migrated |
| 004 | Onboarding Booking | CL-04 | ✅ Migrated |
| 005 | Onboarding AI Showcase | CL-05 | ✅ Migrated |
| 006 | Authentication Entry | CL-08 | ⏳ Pending |
| 007 | Login | CL-08 | ⏳ Pending |
| 008 | Create Your Account | CL-08 | ⏳ Pending |
| 009 | Verify Your Account | CL-08 | ⏳ Pending |
| 010 | Complete Your Profile | CL-08 | ⏳ Pending |
| 011 | Forgot Password | CL-08 | ⏳ Pending |
| 012 | Forgot Password OTP | CL-08 | ⏳ Pending |
| 013 | Create New Password | CL-08 | ⏳ Pending |
| 014 | Password Reset Success | CL-08 | ⏳ Pending |
| 016 | Discovery Feed | CL-09 | ⏳ Pending |
| 017 | Branch Floor Plan & Booking | CL-10 | ⏳ Pending |
| 018 | Personalised Profile & AI Style | CL-11 | ⏳ Pending |
| 019 | Stylist Profile | CL-12 | ⏳ Pending |
| 020 | Review & Rating | CL-13 | ⏳ Pending |

> Note: `015_design.md` is a standalone design doc (not a screen export).

---

## Feature Registry

All Flutter features built, verified, and passing the gate (`melos run verify`: generate → build → analyze → taxonomy → test).

| # | Feature | App / Pkg | Status | Source |
|---|---------|-----------|--------|--------|
| FE-01 | Design Tokens (colors/typography/dimensions) | design_system | ✅ Complete | Track 01 |
| FE-02 | Themes & Semantics | design_system | ✅ Complete | Track 02 |
| FE-03 | Localization Foundation (EN + AR) | localization | ✅ Complete | Track 03 |
| FE-04 | Networking + Interceptors + DTO contracts | core | ✅ Complete | Tracks 07–08 |
| FE-05 | Splash Screen | client_app | ✅ Complete | Stitch 001 |
| FE-06 | Onboarding — Welcome | client_app | ✅ Complete | Stitch 002 |
| FE-07 | Onboarding — Discovery | client_app | ✅ Complete | Stitch 003 |
| FE-08 | Onboarding — Booking | client_app | ✅ Complete | Stitch 004 |
| FE-09 | Onboarding — AI Showcase | client_app | ✅ Complete | Stitch 005 |
| FE-10 | Onboarding Infrastructure (config fetch, skip sheet, flow) | client_app | ✅ Complete | — |
| FE-11 | Home placeholder | client_app | ✅ Complete | — |
| FE-12 | Floor Plan package | feature_floor_plan | ⏸ Stub | Track pending |

### Not Started
- Auth flow (Stitch 006–014), Discovery Feed (016), Branch Floor Plan & Booking (017), Personalised Profile & AI Style (018), Stylist Profile (019), Review & Rating (020).
- `business_app` and `stylist_app` features — both apps are skeletons.
