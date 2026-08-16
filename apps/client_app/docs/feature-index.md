# Feature Index — Dorak Client App (`apps/client_app`)

> **Append entry after adding each feature.** Chronological map of features built in the client (end-user) app. Monorepo-wide index: [`docs/feature-index.md`](../../docs/feature-index.md).

---

### Splash — Stitch 001
- `lib/src/features/splash/splash.screen.dart` — staged fade-in, auto-advance after 2.5s via the injected `onFinished` (now `AppGate.decide`). No early-advance gesture despite earlier notes here.
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
- `lib/src/features/onboarding/widgets/skip_bottom_sheet.sheet.dart` — shared 3-option skip sheet; pops itself before Skip / Don't show again navigate.
- Flow lives in `lib/src/core/navigation/app.router.dart` (go_router, not `main.dart`). `Skip for now` leaves `dontShowOnboarding` alone; `Don't show again` and finishing the tour persist it.

### Authentication — Stitch 006–009
- `lib/src/features/auth/auth_entry.screen.dart` (006) + `widgets/auth_entry_{background,content,header}.widget.dart`, `auth_guest_button.widget.dart`.
- `lib/src/features/auth/login.screen.dart` + `widgets/login_content.widget.dart` (007). Forgot-password link is hidden (`onForgotPassword: null`) until Stitch 011–014 exist.
- `lib/src/features/auth/sign_up.screen.dart` + `widgets/sign_up_content.widget.dart` (008) — name / email / password / confirm; the confirm value is sent as `password_confirmation`.
- `lib/src/features/auth/verify_account.screen.dart` + `widgets/verify_account_content.widget.dart` + `widgets/otp_input_field.widget.dart` (009) — 6 digits, auto-advance, 60 s resend cooldown, masked destination, "Verify later" skip.
- `lib/src/features/auth/widgets/auth_text_field.widget.dart` — floating label, rounded-top/sharp-bottom underline, focus + error states, password toggle. Local to the app; promotion to `design_system` is Track 15.
- `lib/src/features/auth/widgets/auth_header.widget.dart`, `widgets/auth_error_banner.widget.dart`.
- `lib/src/features/auth/auth_validators.entity.dart` — email / min-8 / confirmation-match, mirroring the backend rules.
- `lib/src/features/auth/auth_error.entity.dart` — maps exceptions to local ARB strings. The backend's own `message` is an untranslated key and must never be rendered.

### Bootstrap & Navigation
- `lib/main.dart` — binding init, dotenv, `SharedAppPreferences.create()`, then `DorakApp`.
- `lib/app.dart` — builds secure storage → `ApiClient` (with `tokenProvider`) → `DioAuthRepository` → `SessionController` → `OnboardingConfigController`; starts `session.ready` unawaited so restore overlaps the splash. Test seams: `tokenStorage`, `authRepository`.
- `lib/src/core/navigation/app.router.dart` — `AppRouter` (go_router); `router.go(AppRoutes.home)` clears the stack.
- `lib/src/core/navigation/app_routes.entity.dart` — `AppRoutes` path constants.
- `lib/src/core/navigation/app_gate.entity.dart` — post-splash decision, wired as the router redirect (session first, onboarding flag second).

### Home
- `lib/src/features/home/home.screen.dart` — placeholder (`homeTitle`). Real dashboard TBD; no logout affordance yet.

### Tests
- `test/widget_test.dart` — real `DorakApp` bootstrap: splash → gate → auth entry.
- `test/app_gate_test.dart` — all six launch-gate branches.
- `test/auth_flow_test.dart` — login, validation, sign-up → verify, OTP success/failure, skip, resend cooldown.
- `test/onboarding_skip_test.dart` — Skip vs Don't show again vs Cancel, full four-step walk, empty back-stack.
- `test/helpers/fakes.dart` — router harness + in-memory storage/preferences/auth fakes.

### Empty Scaffolds (no files yet)
- `lib/src/features/discovery/{data,domain,presentation}/`
- `lib/src/features/booking/{data,domain,presentation}/`
- `lib/src/features/profile/`
- `lib/src/core/{di,theme}/`

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
| CL-08 | Auth flow — entry / login / register / verify | ✅ Complete | Stitch 006–009 |
| CL-08b | Password recovery | ⏳ Not started | Stitch 011–014 |
| CL-14 | Launch gate + go_router route table | ✅ Complete | Tracks 10–11 |
| CL-09 | Discovery Feed | ⏳ Not started | Stitch 016 |
| CL-10 | Branch Floor Plan & Booking | ⏳ Not started | Stitch 017 |
| CL-11 | Personalised Profile & AI Style | ⏳ Not started | Stitch 018 |
| CL-12 | Stylist Profile | ⏳ Not started | Stitch 019 |
| CL-13 | Review & Rating | ⏳ Not started | Stitch 020 |
