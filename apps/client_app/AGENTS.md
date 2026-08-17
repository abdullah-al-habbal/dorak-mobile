# AGENTS.md — `apps/client_app`

The end-user app. Splash → launch gate → auth or onboarding → Home.

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)
· Files: [`docs/feature-index.md`](./docs/feature-index.md)

**This app's Dart source has zero comments.** Every non-obvious decision is in
§7. Read it before "simplifying" anything.

---

## 1. Layout

```
lib/main.dart                     binding init, dotenv, prefs, runApp
lib/app.dart                      DorakApp — all DI wiring lives here
lib/src/core/navigation/
  app.router.dart              AppRouter — go_router table, redirects, flow wiring
  app_routes.entity.dart       AppRoutes — path constants
  app_gate.entity.dart         AppGate.resolve — the post-splash branch
lib/src/features/
  splash/                         splash.screen.dart + 2 widgets
  auth/                           4 screens + 8 widgets + 2 entities
  onboarding/                     4 screens + 9 widgets + config bloc
  home/                           home.screen.dart (placeholder)
  discovery/ booking/ profile/    empty scaffolding directories
lib/src/core/di/ theme/           empty
assets/images/                    noise_overlay.png, onboarding_hero.jpg
```

## 2. Bootstrap

```dart
// main.dart
WidgetsFlutterBinding.ensureInitialized();
await dotenv.load();
final preferences = await SharedAppPreferences.create();
runApp(DorakApp(preferences: preferences));
```

`DorakApp.initState` builds, in order: `SecureTokenStorage` → `ApiClient`
(with `tokenProvider`) → `DioAuthRepository` → `AuthBloc` →
`SessionBloc(repository, storage)` → `OnboardingConfigBloc` →
`LocaleBloc`, then starts `session.ready` **unawaited**
and constructs `AppRouter` (go_router, handed to `MaterialApp.router`). The app
layer coordinates the two session blocs: it forwards every `AuthBloc` success
(`state.client != null`) into `SessionBloc.add(SessionAuthenticated(...))`,
alongside the `unauthorizedStream` → `UnauthorizedDetected` forward and the
locale → config reload. The router (two stream listeners) and the api client
subscribe to their streams; all are closed in `dispose()`.

The splash is the router's initial route — it renders from the first frame.
No post-frame push.

Test seams: `DorakApp(tokenStorage:, authRepository:)`. Null in production.

## 3. The launch gate

`AppGate.resolve` — two independent checks, strict order, called from the
router's redirect:

```
await session.ready
A. session.isAuthenticated        -> /home
B. preferences.dontShowOnboarding -> /home
   otherwise                      -> /auth (entry)
```

| Scenario | authenticated | dontShowOnboarding | Lands on |
|---|---|---|---|
| New device | false | false | Auth Entry |
| Guest who saw the tour | false | true | Home |
| Returning logged-in user | true | ignored | Home |
| Just signed up | true | ignored | Home |
| Token revoked server-side | false (cleared) | as stored | B decides |
| Offline start with token | true (kept) | ignored | Home |

Authentication always outranks the onboarding flag.

## 4. Auth flow (Stitch 006–009)

```
Auth Entry (006)
├── Log In         -> Login (007)   --success--> Home
├── Create Account -> Sign Up (008) --success--> Verify (009) --+-> Home
└── Continue as Guest -> onboarding tour        (Verify later)--+
```

Wiring: `app.router.dart`. Every success ends in `router.go(AppRoutes.home)`,
which clears the stack. Logging in **bypasses the tour**; "Continue as Guest" is
its only entry point.

**Verification is non-blocking** — `POST /client/register` already returns a
valid token, so the account is authenticated before verifying. The screen offers
"Verify later". This is also the only workable behaviour while the backend runs
`MAIL_MAILER=log` and codes never leave `storage/logs/laravel.log`.

Files: `login.screen.dart`, `sign_up.screen.dart`, `verify_account.screen.dart`,
plus `widgets/{auth_header, auth_text_field, otp_input_field, login_content,
sign_up_content, verify_account_content}.widget.dart` and
`auth_validators.entity.dart` / `auth_error.entity.dart`. The inline error row
is `design_system`'s `StatusBanner` (promoted from `AuthErrorBanner`, Track 12).

**Error messages are resolved locally.** The backend's `message` field is an
untranslated key; `AuthError.from` maps status + exception type to an ARB
string. A 422's `errors` map *is* real Laravel copy and is shown per-field.

## 5. Onboarding flow (Stitch 002–005)

`Welcome (replace) → Discovery → Booking → AI Showcase → Home`, progress dots
`count: 4`, `activeIndex` 0–3.

| Action | `dontShowOnboarding` | Goes to | Next cold start |
|---|---|---|---|
| Skip for now | untouched | Home | tour again |
| Don't show again | `true` | Home | straight to Home |
| Cancel | untouched | stays | — |
| Finish the tour | `true` | Home | straight to Home |

## 6. Feature status

**Built:** splash, onboarding tour + skip sheet, auth entry / login / sign-up /
verify, launch gate + go_router route table, Home placeholder, session-expired
redirect (401 → auth).

**Not built:** password recovery (Stitch 011–014 — repository methods exist, no
UI calls them), profile completion (010), discovery feed (016), booking (017),
AI style (018), stylist profile (019), review (020), logout UI, per-route
guards, deep links, locale persistence, session-expired redirect.

`features/{discovery,booking,profile}` and `core/{di,theme}` are empty
directories.

## 7. Decisions that are not in the code

| Code | Why |
|---|---|
| `ApiClient(tokenProvider: _tokenStorage.read)` | Reads storage, not `SessionBloc` — the bloc depends on the client, so the reverse would be a cycle. Also the only thing that installs `AuthInterceptor`. |
| `unawaited(_session.ready)` in `initState` | Restore overlaps the 2500 ms splash, so the gate adds no wait. |
| `AppGate` awaits `session.ready`, not `restore()` | `ready` memoises; calling `restore()` would fire a second pass. |
| `router.go(AppRoutes.home)` on auth/onboarding success | go_router's declarative `go` clears the stack by construction — no `pushAndRemoveUntil` bookkeeping. (Pre-Phase 2, `AppNavigator.goHome` used `pushAndRemoveUntil` because `pushReplacement` swapped only the top route and could replace a sheet.) |
| `SkipBottomSheet` pops itself before invoking callbacks | Otherwise navigation fires with the modal route still on top. Pops with `context.pop()`. |
| `_dismissForever` writes in `try`, navigates in `finally` | A failed preference write must not strand the user on the tour. |
| `onSkipForNow: () => router.go(AppRoutes.home)` with no flag write | Deliberate: `Skip for now` ≠ `Don't show again`. |
| `catch (_) {}` after `sendVerificationCode()` | Registration already succeeded and the token is stored; a failed dispatch must not block the verify screen, which has Resend. |
| `onForgotPassword: null` | Nullable hides the link. Stitch 011–014 do not exist; a dead button is worse. |
| "Email", not the design's "Email or Phone" | The backend accepts email only — the design label would guarantee a 422. |
| `AuthEntryBackground` reused by login and sign-up | Deliberately not duplicated into a second blobs widget. |
| `AuthTextField` / `OtpInputField` are app-local | Promotion to `design_system` is Track 15. |
| `AuthErrorBanner` promoted to `StatusBanner` (design_system) | Track 12 made the inline error row a global state component; the auth screens are its first consumers, Discovery's footer will be the next. Rule 9 amendment: promotion covers Track 12 global UI states, not just cross-app reuse. |
| `Wrap` not `Row` in the auth footers | Prompt + link overflow a narrow screen once Arabic or a large text scale widens them. |
| `SizedBox(height: 24)` around the verify error banner | Reserved height stops the button jumping. |
| `OtpInputField` drives focus from `onChanged`, `onKeyEvent` only as a bonus | Soft-keyboard deletions arrive on the text-input channel, not the key channel. |
| `AuthHeader`'s trailing `SizedBox(width: 64)` + `FittedBox` | Balances the leading `IconButton` so the brand stays centred; the right slot hosts the shared `LocaleSwitcher` (scale-down) and still mirrors the back button's 64 px width. |
| `AuthShell` wraps every auth screen | One outer geometry — `SafeArea → LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight: viewport) → Center → maxWidth 480` — so Auth Entry / Login / Register / Verify (and future Forgot-Password screens) center in the viewport when there is room and scroll when there is not (keyboard-open included). The transactional `AuthHeader` is an optional child of the centered column, so header + content scroll and center as one unit, exactly like Auth Entry. Fixes the old split: Login/Register/Verify used a fixed top header + center-in-leftover, which read as a different layout system. `AuthShell` is auth-local — promote to `design_system` only if a second app needs it. |
| `dio` as a dev dependency | `NetworkException` carries a `DioExceptionType`; test fakes need it. |

## 8. Tests — 39, in `test/`

| File | Covers |
|---|---|
| `widget_test.dart` | real `DorakApp` bootstrap: splash → gate → auth entry |
| `app_gate_test.dart` | all six gate branches |
| `auth_flow_test.dart` | login, validation, sign-up → verify, OTP pass/fail, skip, resend cooldown |
| `locale_switcher_flow_test.dart` | shared `LocaleSwitcher` on auth entry / login / sign-up / verify: visible, EN↔AR round trip, RTL flip |
| `onboarding_skip_test.dart` | Skip vs Don't show again vs Cancel, full four-step walk, empty back-stack |
| `session_expired_test.dart` | 401 mid-session → session-expired signal → auth redirect |
| `helpers/fakes.dart` | `routerHarness()`, `buildRouter()` (takes `session` + `auth`), `sessionPair()` (builds a matched `AuthBloc`+`SessionBloc` **plus the app-layer coordinator forward**), `InMemoryTokenStorage`, `InMemoryAppPreferences`, `FakeAuthRepository`, `FakeOnboardingConfigRepository`, `unauthorized()`, `offline()` |

Conventions:

- **Set a phone viewport** for onboarding/auth tests:
  `tester.view.physicalSize = const Size(1290, 2796)`,
  `devicePixelRatio = 3.0`, `addTearDown(tester.view.reset)`. The 800×600
  default overflows these screens.
- `routerHarness(AppRouter)` drives flows through a real go_router
  `MaterialApp.router` without booting `DorakApp` or its network calls.
- `dotenv.loadFromString(...)` in `setUpAll` for anything that constructs
  `ApiClient`.
- **The test fallback font is not IBM Plex** — it renders every glyph at full em
  width, roughly double. A `RenderFlex overflowed` in a test is not proof of a
  device bug.

## 9. Known limitations

- Onboarding screens 002–005 lay out in a non-scrolling `Column` and clip on
  short viewports.
- `HomeScreen` is a single `Text` — no app bar, no navigation, no account or
  logout affordance.
- `README.md` is untouched Flutter template boilerplate.
- Locale toggle is in-memory and resets on restart.

## 10. Commands

```bash
cd apps/client_app
flutter run
flutter test

cd dorak-mobile && dart run melos run verify
```

Base URL comes from `.env` (gitignored, `.env.example` committed) and points at
`https://dev-dorak-backend.io/api/v1`. There is no local-dev profile.
