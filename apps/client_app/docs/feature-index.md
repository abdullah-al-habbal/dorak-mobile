# Feature Index — Dorak Client App (`apps/client_app`)

> **Append entry after adding each feature.** Chronological map of features built in the client (end-user) app. Monorepo-wide index: [`docs/feature-index.md`](../../docs/feature-index.md).

---

### Splash — Stitch 001
- `lib/src/features/splash/splash.screen.dart` — staged fade-in, auto-advance after 2.5s, `onFinished` callback, swipe/button to advance early.
- `lib/src/features/splash/widgets/splash_logo.widget.dart` — animated logo.
- `lib/src/features/splash/widgets/splash_background.widget.dart` — gradient + `noise_overlay.png` (converted from SVG — `Image.asset` cannot decode SVG).

### Onboarding Welcome — Stitch 002
- `lib/src/features/onboarding/welcome.screen.dart` — StatefulWidget, staggered fade, `ProgressDots(4, 0)`, Get Started CTA, skip sheet.
- `lib/src/features/onboarding/widgets/welcome_content.widget.dart` — hero image, headline, sub-text, CTA row.

### Onboarding Discovery — Stitch 003
- `lib/src/features/onboarding/discovery.screen.dart` — `ProgressDots(4, 1)`, Next CTA.
- `lib/src/features/onboarding/widgets/discovery_content.widget.dart` — headline/subtitle + card deck.
- `lib/src/features/onboarding/widgets/discovery_card_deck.widget.dart` — staggered fade-slide-up cards (`Interval` per index).
- `lib/src/features/onboarding/discovery_card.entity.dart` — pure value object (icon, title, description keys); no wire format, hand-written.
- `lib/src/features/onboarding/widgets/onboarding_hero.widget.dart` — local asset `onboarding_hero.jpg` with remote URL override + `errorBuilder`.

### Onboarding Booking — Stitch 004
- `lib/src/features/onboarding/booking.screen.dart` — `ProgressDots(4, 2)`, Back + Next, skip sheet.
- `lib/src/features/onboarding/widgets/booking_content.widget.dart`
- `lib/src/features/onboarding/widgets/booking_visual.widget.dart` — 3 tilted glass cards (service / professional / date-time), staggered fade-slide-up, Material icons in tinted containers (offline-safe, no network images).

### Onboarding AI Showcase — Stitch 005
- `lib/src/features/onboarding/ai_showcase.screen.dart` — `ProgressDots(4, 3)`, Back + Get Started.
- `lib/src/features/onboarding/widgets/ai_showcase_content.widget.dart` — avatar + face-shape chip, 2 recommendation cards with mini progress bars (`FractionallySizedBox`), decorative rings, privacy note.
- `lib/src/features/onboarding/widgets/ai_showcase_visual.widget.dart`

### Onboarding Infrastructure
- `lib/src/features/onboarding/onboarding_config.notifier.dart` — `OnboardingConfigController`: loads `/app/onboarding-config` (locale-aware), reloads on locale switch.
- `lib/src/features/onboarding/widgets/skip_bottom_sheet.sheet.dart` — shared 3-option skip sheet (Skip / Don't show again / Cancel).
- `lib/main.dart` — `_openWelcome` chain: Welcome → Discovery → Booking → AiShowcase → `_goHome`; `_switchLocale` EN/AR toggle threaded through every screen; `_replaceWith`/`_push` manual navigation; `DorakTheme.forLocale` + system dark mode.

### Home
- `lib/src/features/home/home.screen.dart` — placeholder (`homeTitle`). Real dashboard TBD.

### Empty Scaffolds (no files yet)
- `lib/src/features/discovery/{data,domain,presentation}/`
- `lib/src/features/booking/{data,domain,presentation}/`
- `lib/src/features/profile/`

### Assets
- `assets/images/noise_overlay.png` — generated noise texture (replaces SVG).
- `assets/images/onboarding_hero.jpg` — hero image, local-first.

---

## Client Feature Registry

| # | Feature | Status | Source |
|---|---------|--------|--------|
| CL-01 | Splash | ✅ Complete | Stitch 001 |
| CL-02 | Onboarding Welcome | ✅ Complete | Stitch 002 |
| CL-03 | Onboarding Discovery | ✅ Complete | Stitch 003 |
| CL-04 | Onboarding Booking | ✅ Complete | Stitch 004 |
| CL-05 | Onboarding AI Showcase | ✅ Complete | Stitch 005 |
| CL-06 | Onboarding Infrastructure (config, skip sheet, flow) | ✅ Complete | — |
| CL-07 | Home placeholder | ✅ Complete | — |
| CL-08 | Auth flow (login/register/verify/forgot password) | ⏳ Not started | Stitch 006–014 |
| CL-09 | Discovery Feed | ⏳ Not started | Stitch 016 |
| CL-10 | Branch Floor Plan & Booking | ⏳ Not started | Stitch 017 |
| CL-11 | Personalised Profile & AI Style | ⏳ Not started | Stitch 018 |
| CL-12 | Stylist Profile | ⏳ Not started | Stitch 019 |
| CL-13 | Review & Rating | ⏳ Not started | Stitch 020 |
