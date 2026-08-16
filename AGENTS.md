# AGENTS.md — Dorak Mobile

**Read this file before touching anything in `dorak-mobile/`.** It is the single
entry point: architecture, hard rules, what already exists, what does not, and
the decisions that are *not* visible in the code.

The Dart source carries almost no comments by design. Rationale lives here. If
you are about to "clean up" something that looks odd, check §9 first — most of
it is deliberate.

---

## 1. Read order

| Order | File | Why |
|---|---|---|
| 1 | **`AGENTS.md`** (this file) | the monorepo-wide picture |
| 2 | `CLAUDE.md` | the normative taxonomy + layering contract |
| 3 | **the `AGENTS.md` + `CLAUDE.md` of the unit you are editing** | see §1.1 |
| 4 | `docs/index.md` | Track status and the current execution point |
| 5 | `docs/feature-index.md` | monorepo feature registry |
| 6 | topic docs under `docs/` | only what the current task needs |

### 1.1 Per-unit docs

Every app and package carries its own pair. **This file and the root
`CLAUDE.md` are the parents** — they hold the rules and facts that apply
everywhere. Each child holds only what is specific to that unit: its dependency
ceiling, the file roles it may use, its public API, and its own gotchas. Where a
child contradicts nothing, the parent still applies.

| Unit | Docs | State |
|---|---|---|
| `apps/client_app` | [`AGENTS`](./apps/client_app/AGENTS.md) · [`CLAUDE`](./apps/client_app/CLAUDE.md) | real features; the reference implementation |
| `apps/business_app` | [`AGENTS`](./apps/business_app/AGENTS.md) · [`CLAUDE`](./apps/business_app/CLAUDE.md) | `flutter create` stub |
| `apps/stylist_app` | [`AGENTS`](./apps/stylist_app/AGENTS.md) · [`CLAUDE`](./apps/stylist_app/CLAUDE.md) | `flutter create` stub |
| `packages/core` | [`AGENTS`](./packages/core/AGENTS.md) · [`CLAUDE`](./packages/core/CLAUDE.md) | HTTP, config, storage, session, DTOs |
| `packages/design_system` | [`AGENTS`](./packages/design_system/AGENTS.md) · [`CLAUDE`](./packages/design_system/CLAUDE.md) | tokens, theme, fonts, 9 widgets |
| `packages/localization` | [`AGENTS`](./packages/localization/AGENTS.md) · [`CLAUDE`](./packages/localization/CLAUDE.md) | 75 keys, EN + AR |
| `packages/feature_floor_plan` | [`AGENTS`](./packages/feature_floor_plan/AGENTS.md) · [`CLAUDE`](./packages/feature_floor_plan/CLAUDE.md) | empty stub |

Read the child for the unit you are touching **before** editing it. If you touch
two units, read both.

**Most files under `docs/` are 0-byte stubs**, and `docs/index.md` names several
directories that do not exist at all (`docs/agent/`, `docs/engineering/`,
`docs/runtime/`, `docs/networking/`, `docs/storage/`). Never assume a doc exists
because it is referenced.

These are the only docs with content:

```
docs/index.md                            docs/feature-index.md
docs/architecture/coding_conventions.md  docs/state_management/pagination.md
docs/core/networking.md                  docs/core/interceptors.md
docs/core/exceptions.md                  docs/core/result_state.md
docs/core/storage.md                     docs/core/session.md
docs/authentication/auth_flow.md         docs/flows/app_launch.md
docs/flows/onboarding.md                 docs/flows/guest_access.md
docs/navigation/routes.md                docs/navigation/guards.md
docs/future-features/perPage/perPage.md
apps/{client,business,stylist}_app/docs/feature-index.md
```

`docs/core/background_tasks.md` is whitespace only — treat it as empty.

`docs/stitch/exports/` holds the remaining unimplemented screen designs
(010–020): `code.html` is the layout source, `screen.png` the reference, and
`DESIGN.md` is the same global token spec in every folder (already implemented —
do not regenerate tokens from it). Delete an export folder once its screen is
built and the gate is green.

---

## 2. Repository shape

Dart pub workspace + Melos. Everything lives under `dorak-mobile/`.

```
apps/
  client_app/      end-user app — the only one with real features
  business_app/    `flutter create` counter stub, no workspace deps
  stylist_app/     `flutter create` counter stub, no workspace deps
packages/
  core/            networking, storage, session, DTOs, config
  design_system/   tokens, theme, shared widgets
  localization/    ARB + generated AppLocalizations (en, ar)
  feature_floor_plan/  empty stub
docs/              specs, flows, tracks, Stitch exports
tool/              check_taxonomy.dart
```

Dependency direction is strictly bottom-up:

```
apps/*  ->  feature_*  ->  core | design_system | localization
```

- `design_system` MUST NOT depend on `core` or `localization`. Shared widgets
  take strings as constructor parameters.
- `core` MUST NOT import `design_system` or any app code.
- Packages MUST NOT import `apps/*`.

The sibling `../dorak-backend/` is a **Laravel 13** service, out of scope for
mobile changes. Its contract is summarised in §8.

---

## 3. Non-negotiable rules

1. **One HTTP stack.** Everything goes through `ApiClient` in `packages/core`.
   Never add `http`, never construct a bare `Dio` outside core.
2. **One state-management approach.** **Pure Bloc** (`flutter_bloc`). UI emits
   events, a `Bloc` owns business state, UI renders from state. No Riverpod,
   Provider or GetIt — prohibited. **`ChangeNotifier` is not a target pattern.**
   The remaining instances are transitional: Track 12/session infrastructure
   (`SessionController`, `UnauthorizedNotifier`, `SessionNotice`) and the
   legacy pagination notifiers (`page_pagination.notifier.dart`,
   `scroll_pagination.notifier.dart`). They are kept as-is and must not be
   extended; Phase 4 replaces them with Stream/Bloc. Do not add new
   `ChangeNotifier` state.
3. **One navigation approach.** **`go_router` only** — declarative route table,
   redirects for the launch gate and auth guards, `context.push/go/pop` in
   screens. **Navigator 1.0 and `AppNavigator` are gone from `client_app`**
   (removed in Phase 2); `*.navigator.dart` is a deprecated taxonomy role,
   tolerated only in the untouched `business_app`/`stylist_app` stubs. Bloc
   never navigates — routing responds to state via the router's redirect and
   listener. Local modal-route dismissal uses `context.pop()`.
4. **No hardcoded user-visible strings.** Every string goes in **both**
   `app_en.arb` and `app_ar.arb`, then `flutter gen-l10n`. Arabic must be a real
   translation.
5. **No raw colours or text styles in app code.** Use
   `DorakColors.of(context)`, `DorakTypography.*`, `DorakDimensions.*`. Hex
   literals belong only in `packages/design_system/lib/src/tokens/`.
6. **DTOs are generated.** Every `*.dto.dart` uses `json_serializable`;
   hand-written `fromJson` is forbidden for anything that touches the wire.
   `.entity.dart` value objects may stay hand-written.
7. **One top-level public class per file.** Private helper classes in the same
   file are acceptable and used (see `skip_bottom_sheet.sheet.dart`).
8. **Do not invent backend endpoints.** The full surface is in
   `packages/core/lib/src/network/endpoints/`.
9. **Do not implement future Tracks early.** Check `docs/index.md` first.
10. **Never mark work done without running the gate** (§5).

---

## 4. File taxonomy

Filenames are `<subject>.<role>.dart`. Enforced by `tool/check_taxonomy.dart`
— a file under any `lib/` subdirectory with no valid role suffix fails the gate.

| Role | Purpose | Allowed in |
|---|---|---|
| `.screen.dart` | full-page scaffolds | `apps/*` only |
| `.widget.dart` | reusable UI components | anywhere |
| `.sheet.dart` | bottom sheets / modals | anywhere |
| `.token.dart` | colour/type/dimension tokens | `design_system` only |
| `.theme.dart` | ThemeData construction | `design_system` only |
| `.entity.dart` | domain value objects (no JSON) | `core`, `apps/*` |
| `.dto.dart` | wire models (codegen) | `core`, `apps/*` |
| `.endpoints.dart` | route constants, domain-split | `core`, `apps/*` |
| `.repository.dart` | data-source contract + impl | `core`, `apps/*` |
| `.provider.dart` / `.notifier.dart` | state / DI | `core`, `apps/*` |
| `.storage.dart` | device persistence | **`core` only** |
| `.navigator.dart` | **DEPRECATED** — legacy route-flow coordinators (removed from `client_app` in Phase 2) | only `business_app`/`stylist_app` stubs |
| `.router.dart` | declarative `go_router` route table | `apps/*` only |
| `.bloc.dart` / `.event.dart` / `.state.dart` | Pure Bloc feature state (Phase 3) | `apps/*`, `packages/feature_*` |
| `.client.dart` `.interceptor.dart` `.exception.dart` `.barrel.dart` | as named | anywhere |

Files directly at `lib/` root (`main.dart`, `app.dart`, `core.dart`) are exempt.
Generated files, `build/`, `.dart_tool/`, and desktop `.plugin_symlinks/` are
skipped.

Abstract contract + concrete implementation live in the **same** file
(`AuthRepository` + `DioAuthRepository`, `TokenStorage` + `SecureTokenStorage`).
Follow that pattern; do not split them.

---

## 5. Commands

`melos` is **not** on PATH — always invoke it through `dart run`.

```bash
cd dorak-mobile

dart run melos run generate    # flutter gen-l10n in packages/localization
dart run melos run build       # build_runner where json_serializable is declared
dart run melos run analyze     # flutter analyze, every package
dart run melos run taxonomy    # dart run tool/check_taxonomy.dart
dart run melos run test        # flutter test, every package

dart run melos run verify      # all five, in order — the gate
```

`verify` must exit 0 before any work is called done. Current baseline: 7
packages analyze clean, taxonomy passes, 90 tests pass.

After editing an ARB file run `generate`. After editing a DTO run `build`.

---

## 6. Core architecture

### Networking — `packages/core/lib/src/network/`

`ApiClient` wraps Dio. Verbs: `get`, `post`, `put`, `patch`, `delete`,
`getPaginated`. Interceptor order: `Locale → [Auth] → [Logging] → Retry`.
Connect timeout 15 s, receive 30 s. `POST` is never retried.

Base URL comes from `.env` via `ConfigProvider` — never hardcode it:

```
API_BASE_URL=https://dev-dorak-backend.io/api
API_BASE_URL_V1=https://dev-dorak-backend.io/api/v1
```

`.env` is gitignored; `.env.example` is committed.

**Response envelope** (every enveloped endpoint):

```json
{"success": bool, "statusCode": int, "code": "SUCCESS", "message": "...",
 "timestamp": "...", "data": ..., "meta": {...}, "errors": {...}}
```

`ApiClient` unwraps `data` and throws on failure. `data`/`meta`/`errors` keys
are **omitted entirely** when empty, not present-as-null.

**Exceptions** — a raw `DioException` never escapes `ApiClient`:

| Type | When |
|---|---|
| `ValidationException` | 422 `VALIDATION_FAILED`; `errors` is `Map<String, List<String>>` |
| `NetworkException` | transport failure; `statusCode` 0, `retryable` flag |
| `ApiException` | everything else; `isUnauthorized`/`isForbidden`/`isNotFound`/… |

### Storage — `packages/core/lib/src/storage/`

| Contract | Impl | Holds |
|---|---|---|
| `TokenStorage` | `SecureTokenStorage` (flutter_secure_storage) | Sanctum bearer token |
| `AppPreferences` | `SharedAppPreferences` (shared_preferences) | `dontShowOnboarding` |

Both are abstract so tests never touch a platform channel.
`AppPreferences.dontShowOnboarding` is a **synchronous** getter — the launch
gate branches on it without an await. Construct with
`await SharedAppPreferences.create()` once during bootstrap; apps must not
declare `shared_preferences` themselves.

### Session — `packages/core/lib/src/session/`

`SessionController extends ChangeNotifier`. `AuthStatus` is
`unknown | authenticated | guest`; `unknown` is pre-restore and must never be
branched on — `await session.ready` first.

`restore()`:

```
no stored token          -> guest
refreshToken() succeeds  -> persist rotated token, authenticated
  401 / 403              -> clear token, guest
  NetworkException       -> authenticated, token kept
  other ApiException     -> authenticated, token kept
```

Mutating calls (`login`, `register`, `verifyEmail`, `sendVerificationCode`)
**rethrow** so screens can branch on `ValidationException`. `logout()` is the
exception — it swallows the network failure and always clears local state.

### Navigation — `apps/client_app/lib/src/core/navigation/`

| File | Owns |
|---|---|
| `app.router.dart` | `AppRouter` — the `go_router` route table + redirects |
| `app_routes.entity.dart` | route path constants (`/`, `/auth`, `/onboarding`, `/home`) |
| `app_gate.entity.dart` | `AppGate.decide` — the post-splash branch, exposed as a router redirect |

Screens receive callbacks only. They never know their neighbours. Bloc never
navigates: navigation happens through the router, driven by state via
redirects. **Routing lives in the router, never in a screen or a bloc.**

### The launch gate

```
Splash (2500 ms) -> AppGate.decide (installed as a router redirect)
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

---

## 7. Feature inventory

### Built

| Area | Where |
|---|---|
| Design tokens, theme, 9 shared widgets | `packages/design_system` |
| Localization EN + AR, 75 keys, RTL | `packages/localization` |
| Networking, interceptors, exceptions, pagination | `packages/core/lib/src/network` |
| Storage (secure token + preferences) | `packages/core/lib/src/storage` |
| Session lifecycle | `packages/core/lib/src/session` |
| Auth repository (8 methods over 10 route constants) | `packages/core/.../repositories/auth.repository.dart` |
| Splash | `client_app/.../features/splash` (Stitch 001) |
| Onboarding tour, 4 steps + skip sheet | `client_app/.../features/onboarding` (002–005) |
| Auth entry / login / sign-up / verify | `client_app/.../features/auth` (006–009) |
| Launch gate + go_router route table | `client_app/.../core/navigation` |
| Home placeholder | `client_app/.../features/home` |

### Not built — do not assume these exist

- Password recovery (Stitch 011–014). Repository methods `forgotPassword` /
  `resetPassword` exist; **no UI calls them**.
- Profile completion (Stitch 010), Discovery Feed (016), Booking (017),
  AI Style (018), Stylist Profile (019), Review (020).
- Social login. The endpoint constant exists; the backend has no configured
  Socialite drivers, so it always 401s.
- Per-route auth guards (beyond the launch gate + 401 redirect), guest guards,
  deep links, notifications.
- Logout UI. `SessionController.logout()` exists with no affordance.
- DI container. Wiring is manual construction in `DorakApp.initState`.
- Locale persistence. The toggle is in-memory and resets on restart.
- `business_app` / `stylist_app` features. Both are untouched counter stubs
  with no workspace package dependencies.
- Design-system inputs, cards, chips, dialogs, app bars, shimmer, empty/error
  states. Track 15 — **only the 9 widgets in §10 exist**.

---

## 8. Backend contract and its known defects

Laravel 13 + **Sanctum opaque bearer tokens** (not JWT). Base `/api/v1`.
Client routes are under `/client`.

| Call | Route | Notes |
|---|---|---|
| Register | `POST /client/register` | 201. **Requires `password_confirmation`.** Returns `{token, client}` — authenticated *before* verification |
| Login | `POST /client/login` | `{email, password}`. Email only — **there is no phone login** |
| Refresh | `POST /client/refresh-token` | `auth:client`. Revokes and reissues. Used as the session-validity probe |
| Send code | `POST /client/email/verify/send` | `auth:client`. 6 digits, 10-minute TTL |
| Verify | `POST /client/email/verify` | `auth:client`, `{code}`, `size:6`. 422 on wrong code |
| Logout | `POST /client/logout` | `auth:client`. 200 with **no `data` key** |

Also declared and unused: `forgot-password`, `reset-password`, `password`,
`social/{provider}`.

### Defects to work around, not "fix" from the client

1. **`message` is an untranslated key.** The backend defines 4 translation keys
   and references ~21, falling back to the key itself. A rejected login returns
   the literal `core::messages.invalid_credentials`. **Never render
   `ApiException.message`.** Map status + type to a local ARB string via
   `AuthError.from`. The `errors` map on a 422 *is* real Laravel copy and is
   safe to show per-field.
2. **No `GET /client/me`.** There is no way to fetch the current user. This is
   why session restore probes with `refresh-token`.
3. **`MAIL_MAILER=log`.** Verification and reset codes are written to
   `storage/logs/laravel.log` and never delivered. Verification is therefore
   non-blocking by design.
4. **`SANCTUM_EXPIRATION` is unset** — tokens never expire server-side. This is
   why an offline restore keeps the session.
5. **Guard 401s bypass the envelope.** An expired token returns a bare
   `{"message":"Unauthenticated."}`, mapped to `ApiException(401, 'UNKNOWN')`.
   Branch on `isUnauthorized`, **never** on `code`.
6. No rate limiting on any auth route; `forgot-password` leaks account
   existence; disabled/banned clients can still log in. Server-side issues,
   logged, not client-fixable.

---

## 9. Decisions that are not in the code

The app layer has no comments. These are the non-obvious choices — **check here
before "simplifying" any of them.**

| Code | Why it is that way |
|---|---|
| `ApiClient(tokenProvider: _tokenStorage.read)` | Reads storage directly, not `SessionController`. `SessionController` depends on `ApiClient`; going the other way would be a construction cycle. Also the only thing that activates `AuthInterceptor`. |
| `unawaited(_session.ready)` in `initState` | Restore runs concurrently with the 2500 ms splash so the gate adds no wait of its own. |
| `AppGate` awaits `session.ready`, not `restore()` | `ready` memoises; `restore()` called directly would fire a second pass. |
| `goHome()` uses `pushAndRemoveUntil` | `pushReplacement` swaps only the top route — onboarding and auth screens stayed alive underneath Home and were reachable by back gesture, and from inside a bottom sheet it replaced the *sheet*. **Gone in Phase 2**: auth/onboarding success uses `context.go('/home')` (declarative `go_router`), which clears the stack by construction. |
| `SkipBottomSheet` pops itself before invoking callbacks | Otherwise navigation fires while the modal route is still on top. It now pops with `context.pop()`. |
| `_dismissForever` writes in `try`, navigates in `finally` | A failed preference write must not strand the user on the tour. |
| `onSkipForNow: () => context.go('/home')` — no flag write | Deliberate: `Skip for now` ≠ `Don't show again`. The tour must reappear next cold start. |
| `catch (_) {}` after `sendVerificationCode()` | Registration already succeeded and the token is stored. A failed dispatch must not block reaching the verify screen, which has Resend. |
| `onForgotPassword: null` | Nullable hides the link. Stitch 011–014 do not exist; a visible dead button is worse than none. |
| `AppNavigator`/`.navigator.dart` removed in Phase 2 | Navigators were imperative and un-testable; go_router's declarative table + redirects replaced the whole `core/navigation/` layer. Legacy claim: `SessionRedirect` (401 → auth) used to live in a navigator; it now hooks the router's listener. |
| Login/sign-up say **"Email"**, not the design's "Email or Phone" | The backend accepts email only; the design label would guarantee a 422. |
| `AuthEntryBackground` reused by login and sign-up | Deliberately not duplicated into a second blobs widget. |
| `AuthTextField` / `OtpInputField` live in the app, not `design_system` | Promotion is Track 15. Do not move them early. |
| `Wrap` instead of `Row` in the auth footers | The prompt + link overflow a narrow screen once Arabic or a large text scale widens them. |
| `SizedBox(height: 24)` around the verify error banner | Reserved height stops the button jumping when an error appears. |
| `OtpInputField` drives focus from `onChanged`, with `onKeyEvent` as an extra | Soft-keyboard deletions arrive on the text-input channel, not the key channel, so backspace-on-empty cannot be observed there. |
| `AuthHeader`'s trailing `SizedBox(width: 48)` | Balances the leading `IconButton` so the brand stays optically centred. |
| `_discardBody` parser on logout/verify | Those endpoints answer 200 with no `data` key; there is nothing to decode. |
| `restore()` keeps the session on `NetworkException` | Sanctum tokens have no server-side expiry, so an unreachable server is no evidence the session died. |
| `NetworkException` carries `DioExceptionType` | Which is why `client_app` has a **test-only** `dio` dev dependency. |

---

## 10. Design system — reuse, do not recreate

`packages/design_system/lib/src/widgets/` — all string-parameterised:

`primary_button` (has `isLoading`) · `secondary_button` · `skip_button` ·
`progress_dots` · `onboarding_header` · `bottom_sheet_modal` ·
`gradient_overlay` · `hero_image` · `swipe_navigation`

Tokens: `DorakColors` (49 semantic fields incl. `inputBgSoft` / `inputBgFocus`
for field states), `DorakTypography` (10 styles), `DorakDimensions`,
`DorakTheme.forLocale(locale, brightness)` (swaps to the Arabic font family).

`DorakTheme` has **no** `inputDecorationTheme` — fields build their own
decoration.

Extract a widget into `design_system` only when it is genuinely reused across
apps. Otherwise keep it in `apps/*/lib/src/features/<feature>/widgets/`.

---

## 11. Localization

- Source of truth: `packages/localization/l10n/app_en.arb` (template) +
  `app_ar.arb`. 75 keys, identical sets.
- camelCase, feature-prefixed (`loginTitle`, `verifyResend`,
  `signUpPasswordHint`). Reuse existing keys before adding new ones.
- Generated output `lib/src/generated/` is committed and excluded from the
  analyzer and taxonomy checker.
- Two keys take ICU placeholders and generate functions, not getters:
  `verifySubtitle(String email)`, `verifyResendDisabled(int seconds)`.
- RTL is automatic from the locale. Use `Align` / `TextAlign.start` /
  `AlignmentDirectional`; never hardcode left/right. For directional icons
  follow the existing idiom:
  `isRtl ? Icons.arrow_forward : Icons.arrow_back`.

---

## 12. Testing conventions

19 test files; 90 tests pass (59 in `core`, 26 in `client_app`, 5 placeholders).

| File | Covers |
|---|---|
| `core/test/api_client_test.dart` | envelope parse, verbs, pagination, exception mapping |
| `core/test/session_controller_test.dart` | all four `restore()` branches, login, register, verify, logout |
| `core/test/auth_repository_test.dart` | request bodies incl. `password_confirmation`, 401/422 mapping |
| `core/test/unauthorized_notifier_test.dart` | Track 12 401/403 emission |
| `core/test/storage_test.dart` | preference round-trip + defaults |
| `client_app/test/widget_test.dart` | real `DorakApp` bootstrap: splash → gate → auth entry |
| `client_app/test/app_gate_test.dart` | all six gate branches |
| `client_app/test/auth_flow_test.dart` | login, validation, sign-up → verify, OTP, skip, resend cooldown |
| `client_app/test/onboarding_skip_test.dart` | Skip vs Don't show again vs Cancel, full walk, empty back-stack |
| `client_app/test/session_expired_test.dart` | 401 mid-session → session-expired notice → auth redirect |

Rules:

- Use the fakes in `client_app/test/helpers/fakes.dart` and
  `core/test/helpers/{fake_dio,fake_auth}.dart`. Never hit a real plugin or a
  real network.
- `DorakApp` takes optional `tokenStorage` and `authRepository` **purely as
  test seams**. Leave them null in production.
- `routerHarness(AppRouter)` builds a real `go_router`-driven
  `MaterialApp.router` so flows can be driven without booting `DorakApp`.
- **Set a phone viewport** for onboarding/auth widget tests:
  `tester.view.physicalSize = const Size(1290, 2796)` with
  `devicePixelRatio = 3.0` and `addTearDown(tester.view.reset)`. The 800×600
  default overflows these screens.
- The test fallback font renders every glyph at full em width, roughly **twice**
  IBM Plex. A `RenderFlex overflowed` in a test is not proof of a device bug —
  measure before "fixing" layout.

---

## 13. Known limitations in shipped UI

- Onboarding screens 002–005 lay out in a non-scrolling `Column` and clip on
  short viewports. Making them scroll is unowned work.
- `HomeScreen` is a single `Text`. No app bar, no navigation, no account
  affordance.
- `apps/client_app/README.md` is untouched Flutter template boilerplate.

---

## 14. Where does new code go?

| You are adding | Put it in |
|---|---|
| a full page | `apps/<app>/lib/src/features/<feature>/<name>.screen.dart` |
| a widget used by one feature | `.../features/<feature>/widgets/<name>.widget.dart` |
| a widget reused across apps | `packages/design_system/lib/src/widgets/` |
| a user-visible string | both ARB files, then `generate` |
| an API call | a `.repository.dart` in `packages/core`, route constant in the matching `.endpoints.dart` |
| a wire model | `packages/core/.../dto/<name>.dto.dart` + `build` |
| device persistence | `packages/core/lib/src/storage/<name>.storage.dart` |
| app routing | `apps/<app>/lib/src/core/navigation/app.router.dart` + `app_routes.entity.dart` (go_router) |
| feature state | a `<name>_bloc.dart` (`Bloc`) under `apps/<app>/lib/src/features/<feature>/` |

Then: `dart run melos run verify`, and update `docs/feature-index.md`,
`apps/<app>/docs/feature-index.md`, and the relevant Track in `docs/index.md`.
