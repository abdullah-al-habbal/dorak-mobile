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
  auth/                           9 screens + 12 widgets + 3 entities
                                  + password_recovery bloc/event/state (011–014)
                                  + change_password bloc/event/state + screen (Track 17)
  onboarding/                     4 screens + 9 widgets + config bloc
  home/                           home.screen.dart (superseded placeholder, unused)
  discovery/                      discovery.{bloc,event,state}.dart + filter entity + screen + 2 widgets (016 feed)
  booking/                        booking.{bloc,event,state}.dart + screen + card (017a list/cancel)
                                  branch_detail.{bloc,event,state}.dart + screen + FloorPlanGrid widget (017b detail/create)
  profile/                        profile.screen.dart (018a: header card + change-password entry + Service History; 018b: avatar header + Face Analysis card + Curated For You)
                                  history.{bloc,event,state}.dart (018a: paged feed + rebook)
                                  face_analysis.{bloc,event,state}.dart (018b: upload → pending → re-check, curated via catalog paging)
                                  avatar.{bloc,event,state}.dart (018b: upload → avatarUrl)
                                  photo_picker.provider.dart + image_picker_photo_picker.provider.dart (018b: PhotoPicker seam + image_picker impl)
  stylist/                         stylist_profile.{bloc,event,state}.dart + screen (019: profile from branch-detail barbers entry, `/discover/barber/:barberId`)
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

## 4. Auth flow (Stitch 006–009, 011–014)

```
Auth Entry (006)
├── Log In         -> Login (007)   --success--> Home
│                        └── Forgot Password? -> 011 -> 012 -> 013 -> 014 -> Login
├── Create Account -> Sign Up (008) --success--> Verify (009) --+-> Home
└── Continue as Guest -> onboarding tour        (Verify later)--+
```

Recovery is the only branch that ends at **Login**, not Home — the user signs in
with the new password. It has three backend-imposed quirks (no verify-reset-code
endpoint, so a bad code surfaces on 013; a 10-minute code TTL; and an enumeration
oracle the client refuses to surface). All three are in
`docs/authentication/password_recovery.md` — read it before touching the flow.

Wiring: `app.router.dart`. Every success ends in `router.go(AppRoutes.home)`,
which clears the stack. Logging in **bypasses the tour**; "Continue as Guest" is
its only entry point.

**Verification is non-blocking and backend-owned** — `POST /client/register`
already returns a valid token, so the account is authenticated before
verifying, and the backend dispatches the OTP itself
(`SendEmailVerificationCodeJob`, after commit). The client never calls
`/email/verify/send` on registration — the Resend button is the only
client-side retry. The screen offers "Verify later". This is also the only
workable behaviour while the backend runs `MAIL_MAILER=log` and codes never
leave `storage/logs/laravel.log`.

Files: `login.screen.dart`, `sign_up.screen.dart`, `verify_account.screen.dart`,
plus `widgets/{auth_header, auth_text_field, otp_input_field, login_content,
sign_up_content, verify_account_content}.widget.dart` and
`auth_validators.entity.dart` / `auth_error.entity.dart`. The inline error row
is `design_system`'s `StatusBanner` (promoted from `AuthErrorBanner`, Track 12).
All four auth screens share `widgets/auth_shell.widget.dart` for responsive
layout.

Recovery adds `forgot_password.screen.dart`, `recovery_otp.screen.dart`,
`create_new_password.screen.dart`, `password_reset_success.screen.dart` (a thin
`StatusView` wrapper — its first production consumer), their three content
widgets, and `password_recovery.{bloc,event,state}.dart` +
`recovery_signal.entity.dart`.

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
verify, **password recovery (011–014)**, launch gate + go_router route table,
Home placeholder, session-expired redirect (401 → auth).

**Built:** discovery feed (016) — `DiscoveryBloc` over `Paged<BranchDto>` +
`FeedCache`, universe/filter bar, result cards, Discover tab; guest Book Now
raises `RequireAuthentication`.

**Built:** booking (017a + 017b) — `BookingBloc` list/filter/cancel on the
Bookings tab; `BranchDetailBloc` + `BranchDetailScreen` + `FloorPlanGrid`
(chair/services/time selection, `createBooking`, 409 conflict → message,
success → My Bookings) on `/discover/branch/:branchId`.

**Built:** service history + rebook (018a) — `HistoryBloc` over
`Paged<ServiceHistoryDto>` (start/refresh/load-more/retry + rebook submit →
`rebooked` flag, ack reset); `ProfileScreen` rebuilt into the 018 profile tab:
client-name header card (fallback `profileMemberLabel` when the name is unknown
after a token-login restore), Change Password entry kept, localized Service
History feed with per-entry rebook (Material date + time pickers, per-card
`rebookingId` loader, 409 → `bookingConflictMessage`, success `StatusView` →
My Bookings).

**Built:** face analysis + AI style (018b) — `FaceAnalysisBloc` (start loads
recommendations; scan uploads the photo and lands on a pending state because
the backend job runs async; Check again re-polls; `recommended_catalog_item_ids`
resolved by paging the catalog, catalog failure tolerated) + `AvatarBloc`
(upload → `avatarUrl`) over a `PhotoPicker` seam (`ImagePickerPhotoPicker`,
`image_picker` hidden behind it). `ProfileScreen` gained an avatar header
(tap to upload, in-flight loader, fallback initial), a Face Analysis card
(empty / pending / result shape+confidence+photo / error-with-retry) and a
Curated For You section (item name `[localeCode] ?? ['en'] ?? ''`, price
range, style period).

**Built:** stylist profile (019) — `StylistProfileBloc` (parallel detail +
currencies via public `GET /currencies`, currency failure tolerated, retry),
`StylistProfileScreen` (avatar header, stats row mapping `rank`/`compatibility_score`
onto `discoverRankBadge`/`discoverCompatibilityBadge`, services list with
price/currency/duration/at-home), branch-detail barbers → tappable rows,
route `/discover/barber/:barberId`.

**Not built:** profile completion (010), review (020),
logout UI, per-route guards, deep links, locale persistence.

`core/{di,theme}` are empty directories.

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
| Register never calls `sendEmailVerification()` | The backend owns the OTP lifecycle — registration dispatches `SendEmailVerificationCodeJob` (after commit, async), so the client has no post-register call to guard. Resend on the verify screen is the only client-side retry. |
| `onForgotPassword` opens 011 and dispatches `RecoveryRestarted()` first | The parameter is still nullable so the link *can* be hidden, but 011–014 now exist. Restarting clears any email/code left from an abandoned attempt. |
| A 422 from forgot-password advances anyway | `exists:clients,email` would otherwise leak which addresses have accounts. Neutral copy; only transport failures block. |
| "Email", not the design's "Email or Phone" | The backend accepts email only — the design label would guarantee a 422. |
| `AuthEntryBackground` reused by login and sign-up | Deliberately not duplicated into a second blobs widget. |
| `AuthTextField` / `OtpInputField` are app-local | Promotion to `design_system` is Track 15. |
| `AuthErrorBanner` promoted to `StatusBanner` (design_system) | Track 12 made the inline error row a global state component; the auth screens are its first consumers, Discovery's footer will be the next. Rule 9 amendment: promotion covers Track 12 global UI states, not just cross-app reuse. |
| `Wrap` not `Row` in the auth footers | Prompt + link overflow a narrow screen once Arabic or a large text scale widens them. |
| `SizedBox(height: 24)` around the verify error banner | Reserved height stops the button jumping. |
| `OtpInputField` drives focus from `onChanged`, `onKeyEvent` only as a bonus | Soft-keyboard deletions arrive on the text-input channel, not the key channel. |
| `AuthHeader`'s trailing `SizedBox(width: 64)` + `FittedBox` | Balances the leading `IconButton` so the brand stays centred; the right slot hosts the shared `LocaleSwitcher` (scale-down) and still mirrors the back button's 64 px width. |
| `AuthShell` wraps every auth screen | One outer geometry — `SafeArea → LayoutBuilder → SingleChildScrollView → maxWidth 480, margin 20` — shared by Auth Entry / Login / Register / Verify (and future Forgot-Password screens). Two modes: **composed** (default; header is part of the centered scrollable group — used by Auth Entry, which has no transactional needs) and **pinned header** (`pinnedHeader: true`; header sits above an `Expanded` content area — used by Login/Register/Verify so back button + locale switcher never scroll away under viewport pressure). Two-mode **height policy**: when the available height (from `LayoutBuilder`, not MediaQuery) is ≥ 840 the content centers vertically (`ConstrainedBox(minHeight) + Center`); below it the content top-anchors and scrolls naturally — no dead bands, keyboard-open lands in the anchored mode, CTA stays reachable. 840 is derived, not arbitrary: the tallest composition (Register, ≈680 px natural height) + 2×24 margins + ≥56 px intentional centering band each side. Result: centering only on tablet-portrait/desktop/tall windows; every phone portrait is top-anchored. Update the constant in one place if the composition grows. |
| `dio` as a dev dependency | `NetworkException` carries a `DioExceptionType`; test fakes need it. |
| `geolocator` as a dev dependency | `LocationProvider` returns a geolocator `Position`; `FakeLocationProvider` + `testPosition` need the type. Same precedent as `dio`. |
| `DiscoveryBloc` reads `position.latitude/longitude` via inference | Naming the `Position` type would import `geolocator` into app `lib/` — inferred `final position = await …` keeps the dependency in core. |
| Guest Book Now raises `RequireAuthentication` | The router pushes Auth Entry; authenticated booking is Track 017, so the callback is a no-op for signed-in users. |
| Profile tab hosts the change-password entry | Profile completion (010) owns the real profile UI; Track 17 adds one `SecondaryButton` below the placeholder `StatusView` pushing `/profile/password` (nested shell route). |
| Bookings filter renders in the empty state too | The filter was unreachable on an empty list (it lived in the feed header) — `_BookingsFilter` is shared between the empty `Column` and the feed. |
| Booking times use `intl` directly | Locale-aware `DateFormat.yMMMd(locale).add_Hm()`; `intl: ^0.20.0` pinned same as `localization`. |
| Cancel is a Material `AlertDialog`, not a sheet | No dialog exists in `design_system` (Track 15); a two-action confirm dialog is the responsible minimum for a destructive action. |
| Segmented universe control, not chips | `design_system` has no chip (Track 15) — Material `SegmentedButton` covers men/women without inventing one. |
| Branch detail loads detail + floor plan in parallel, plan failure tolerated | A dead floor-plan endpoint must not blank the whole branch page — `planFailed` renders an inline retry `StatusBanner` under the loaded detail. |
| Booking submit requires chair + time; services optional | `canSubmit = chair && time && !isSubmitting`; `service_ids` is nullable on the wire and sent as `null` when empty (backend `required_without`/lists are optional). |
| Barber silently resolved from the selected chair | The plan's `ChairResource` carries `barber`; the user picks a chair, not a barber — the submit payload fills `barber_id` from the chair to keep the booking consistent. |
| 409 mapping lives in the screen, not the bloc | The bloc stores the raw `ApiException` in `submitError`; `_submitMessage` maps `statusCode == 409` → `bookingConflictMessage`, 422 `errors` → field copy, `NetworkException` → `errorNetwork`. Keeps a pure core exception in state. |
| Time picked with Material date + time pickers | Design has no custom time selector (Track 15); `showDatePicker` + `showTimePicker` give localised pickers for free. Slot stored as local `DateTime`, wire-formatted to UTC by core. |
| `buildRouter` takes `bookings` + `branchDetail` fakes | Matched-param seams keep constructors honest; defaults per feature keep unrelated router tests untouched. |
| History rebook success renders a `StatusView`, navigation via `onViewBookings` callback | Bloc never navigates; the screen surface + callback (`router.go(AppRoutes.bookings)`) keeps routing in the router wiring. |
| Rebook error mapping lives in the screen, not the bloc | Same rule as booking submit: bloc stores the raw `ApiException` in `rebookError`; the screen maps 409 → `bookingConflictMessage`, `NetworkException` → `errorNetwork`, else `errorGeneric`. |
| History item name resolved from the translations map | `catalog_item.name[localeCode] ?? ['en'] ?? ''` — object keys are locale codes, value is the localized display name. |
| Profile header name falls back to `profileMemberLabel` | `RefreshTokenAction` returns only `{token}` — no profile data survives a restore, so a restored logged-in user has no known name. Avatar initial falls back to `'?'`. |
| Rebook slot formatted like `createBooking` | UTC `yyyy-MM-dd HH:mm:ss`, shared convention with 017b booking creation. |
| Rebook pickers are Material date + time pickers | Same precedent as 017b — no custom time selector (Track 15). |
| `image_picker` is a runtime dep behind a `PhotoPicker` seam | The scan + avatar uploads live behind the app-local abstract `PhotoPicker`; `ImagePickerPhotoPicker` is the only consumer of the platform plugin, so widget tests inject `FakePhotoPicker` and never hit the gallery. |
| Avatar camera badge uploads by tapping the avatar (or badge) | The whole `InkWell` circle is the target — a 56 px hit area instead of a 24 px one. While uploading the badge swaps to `AppLoader.inline()`. |
| Avatar fallback initial + `Image.network` `errorBuilder` | A stored `avatar_url` can 400 outside the test binder; the initial renders instead of a broken image. |
| Pending analysis is `awaitingAnalysis`, not a separate screen | The backend dispatches `AnalyzeFacePhotoJob` async (never on upload), so `recommendations` stays empty right after a scan. `FaceAnalysisState.awaitingAnalysis` turns the ready-empty state into a pending card with a "Check again" poll; a second empty poll keeps it pending until a result exists. |
| `recommended_catalog_item_ids` resolved by paging the catalog | `/service-catalog/items` has no ids filter and no face-shape filter — the bloc pages `per_page: 100` up to 5 pages; a catalog failure is tolerated (`curated` stays empty) so the analysis card still renders. |
| Curated card price + style period share one `Text` (`join('\n')`) | Same idiom as the history meta lines; keeps a single tappable surface and no new card layout. |
| Face shape labels come from `faceShape*` ARB keys via a private `_shapeLabel` switch | Seven enum values (`oval|round|square|heart|diamond|oblong|triangle`) map to localized strings; unknown values fall through as the raw string. |
| `FacePhotoDto.isPrimary` defaults false | The `face_profile` embed inside a recommendation omits `is_primary` — a required wire field would 400 the parse. Confirm left default, matching the upload default. |
| Price formatted client-side with `NumberFormat.decimalPattern(localeCode)` | ARB `servicePrice` takes the pre-formatted string + currency code; the bloc formats the number, the screen passes it to the localization |
| Currencies fetched via public `GET /currencies` | Mapped by id→code in the screen; failure tolerated — prices render without a currency suffix |
| `buildRouter` fakes `stylistProfile` + `onBarberSelected` | Defaulted per feature so unrelated router tests stay untouched |

## 8. Tests — 145, in `test/`

| File | Covers |
|---|---|
| `widget_test.dart` | real `DorakApp` bootstrap: splash → gate → auth entry |
| `app_gate_test.dart` | all six gate branches |
| `auth_flow_test.dart` | login, validation, sign-up → verify, OTP pass/fail, skip, resend cooldown |
| `locale_switcher_flow_test.dart` | shared `LocaleSwitcher` on auth entry / login / sign-up / verify: visible, EN↔AR round trip, RTL flip |
| `onboarding_skip_test.dart` | Skip vs Don't show again vs Cancel, full four-step walk, empty back-stack |
| `password_recovery_bloc_test.dart` | the recovery transitions, the enumeration mitigation, the carried code, the rejected code |
| `password_recovery_flow_test.dart` | 011→014 route walk; unregistered email still advances; rejected code routes back to 012; 014 drops the stack |
| `onboarding_config_bloc_test.dart` | config load, retry after failure, locale refetch |
| `session_expired_test.dart` | 401 mid-session → session-expired signal → auth redirect |
| `helpers/fakes.dart` | `routerHarness()`, `buildRouter()` (takes `session` + `auth` + `passwordChange` + `discovery` + `bookings` + `branchDetail` + `history` + `stylistProfile` + `onBarberSelected`), `sessionPair()` (builds a matched `AuthBloc`+`SessionBloc` **plus the app-layer coordinator forward**), `InMemoryTokenStorage`, `InMemoryAppPreferences`, `FakeAuthRepository`, `FakeOnboardingConfigRepository`, `FakeExploreRepository` (+ `testBranchDetail` + `testBarberProfile` + `getBarberDetail`), `FakeCurrencyRepository` (+ `testCurrency`), `FakeBranchRepository` (+ `testFloorPlan`), `FakeBookingRepository` (cancel + `createBooking`), `FakeHistoryRepository` (+ `testServiceHistory`/`testHistoryPage`), `FakeLocationProvider`, `FakeFeedCache`, `testPosition`/`testBranch`/`testBranchPage`, `fakeDiscoveryBloc()`/`fakeBookingBloc()`/`fakeBranchDetailBloc()`/`fakeHistoryBloc()`/`fakeStylistProfileBloc`, `unauthorized()`, `offline()` |
| `discovery_bloc_test.dart` | location gating, cache fresh/stale/offline, universe/filter reload + evict, load-more append + failure, refresh, retry |
| `change_password_bloc_test.dart` | submit success + payload, 422 wrong-current, transport failure |
| `change_password_flow_test.dart` | profile entry → success → Done pop, mismatch blocks, server field error |
| `booking_bloc_test.dart` | start/filter/cancel/load-more/retry over `Paged<BookingDto>` |
| `booking_flow_test.dart` | tab list, past filter, confirm-cancel reload, dialog dismiss, retry-after-offline |
| `branch_detail_bloc_test.dart` | detail + plan parallel load, plan-failure tolerance, chair/services/time selection, submit guard, 409 conflict, submit no-op without chair |
| `history_bloc_test.dart` | history start/fail/load-more append/retry, rebook success (slot + id) + failure + ack reset |
| `history_flow_test.dart` | profile header + history list, empty state, picker-cancel no-op, rebook success → Bookings + reset |
| `face_analysis_bloc_test.dart` | start empty/curated/failed, catalog-failure tolerance, scan → pending, upload failure, check-again load / stay-pending / retry |
| `avatar_bloc_test.dart` | upload publishes the returned url, upload failure keeps the previous avatar + error |
| `face_analysis_flow_test.dart` | empty card + scan action, scan → pending → analysis result + curated card, picker-cancel no-op, avatar upload |
| `stylist_profile_bloc_test.dart` | detail + currencies parallel load, currency failure tolerated, retry |
| `stylist_profile_flow_test.dart` | avatar header, stats row, services list, branch-detail barbers → tappable rows |

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
- `HomeScreen` is a single `Text`, superseded by the Discovery feed on the
  Discover tab — no app bar, no navigation, no account or logout affordance.
  The file is unused.
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
