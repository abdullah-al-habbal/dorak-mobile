# Dorak Mobile — AI Execution Index

Repository: `dorak-mobile`
Architecture contract: `/CLAUDE.md`
Visual source of truth: Stitch Project `9427872355342200736`
Documentation root: `/docs`

## 1. Purpose

This directory is the implementation contract for the Dorak Flutter monorepo.

Documentation is divided into two categories:

1. Engineering documentation — architecture, runtime behavior, state management, networking, storage, security, testing, and AI-agent execution rules.
2. Design documentation — normalized design tokens, reusable components, application states, flows, and screen specifications derived from Stitch.

Stitch defines the visual design.

The engineering documentation defines how that design must be implemented.

The two sources must remain separate and must not silently replace each other.

---

## 2. AI Agent Execution Protocol

Before modifying code, an AI agent MUST:

0. Read `/AGENTS.md` — the entry point (feature inventory, backend contract,
   non-obvious decisions, testing conventions).
1. Read `/CLAUDE.md`.
2. Read this file.
3. Identify the current Track and Task.
4. Read only the documentation required by the current Track.
5. Inspect the existing implementation before creating new files.
6. Preserve package and dependency boundaries.
7. Follow the repository file-naming taxonomy.
8. Implement only the current Task.
9. Run the required verification commands.
10. Update relevant documentation and status before advancing.

An AI agent MUST NOT:

* Skip required architectural documentation.
* Invent undocumented backend APIs or contracts.
* Duplicate existing components or infrastructure.
* Introduce a second networking architecture.
* Introduce a second state-management architecture.
* Put business logic inside design-system components.
* Import application code into shared packages.
* Implement future Tracks prematurely.
* Mark work complete without verification.

---

## 3. Repository Architecture

```text
dorak-mobile/
├── apps/
│   ├── client_app/
│   ├── business_app/
│   └── stylist_app/
│
├── packages/
│   ├── design_system/
│   ├── localization/
│   ├── core/
│   └── feature_floor_plan/
│
├── docs/
└── CLAUDE.md
```

Dependency direction:

```text
apps/*
   ↓
feature packages
   ↓
core / design_system / localization
```

Rules:

* `design_system` MUST NOT depend on `core`.
* `localization` MUST remain independently reusable.
* `core` MUST NOT depend on application-specific code.
* Feature packages may depend on `design_system`, `core`, and `localization`.
* Applications may depend on the permitted local packages.
* Shared packages MUST NOT import executable application code.

See:

* `docs/architecture/system_overview.md`
* `docs/architecture/dependency_rules.md`
* `docs/architecture/package_boundaries.md`

---

## 4. Documentation Map

### Agent

```text
docs/agent/
├── execution_protocol.md
├── context_protocol.md
├── task_protocol.md
├── verification_protocol.md
└── completion_protocol.md
```

### Architecture

```text
docs/architecture/
├── system_overview.md
├── dependency_rules.md
├── monorepo_structure.md
├── package_boundaries.md
├── feature_architecture.md
├── data_flow.md
├── error_flow.md
└── decisions/
```

### Engineering

```text
docs/engineering/
├── coding_conventions.md
├── naming_conventions.md
├── dart_conventions.md
├── flutter_conventions.md
├── dependency_injection.md
├── repository_pattern.md
├── dto_entity_mapping.md
├── immutability.md
├── nullability.md
└── security.md
```

### Runtime

```text
docs/runtime/
├── app_lifecycle.md
├── bootstrap.md
├── environment.md
├── session_lifecycle.md
├── authentication_lifecycle.md
├── offline_behavior.md
├── background_tasks.md
├── notifications.md
└── deep_linking.md
```

### State Management

```text
docs/state_management/
├── architecture.md
├── state_model.md
├── async_operations.md
├── loading_states.md
├── error_states.md
├── pagination.md
├── refresh.md
└── background_operations.md
```

### Networking

```text
docs/networking/
├── architecture.md
├── http_client.md
├── request_pipeline.md
├── interceptors.md
├── error_mapping.md
├── retry_policy.md
├── timeout_policy.md
├── serialization.md
└── environments.md
```

### Storage

```text
docs/storage/
├── architecture.md
├── secure_storage.md
├── cache.md
├── preferences.md
└── persistence_rules.md
```

### Design System

```text
docs/design_system/
├── index.md
├── tokens/
├── themes/
├── semantics/
├── components/
└── states/
```

### Authentication

```text
docs/authentication/
├── auth_flow.md
├── login.md
├── registration.md
├── verification.md
├── otp.md
├── password_recovery.md
├── session.md
└── profile_completion.md
```

### Navigation

```text
docs/navigation/
├── routes.md
├── guards.md
├── deep_links.md
└── lifecycle.md
```

### Flows

```text
docs/flows/
├── app_launch.md
├── onboarding.md
├── guest_access.md
├── authentication.md
├── file_upload.md
├── background_upload.md
└── notifications.md
```

### Screens

```text
docs/screens/
├── authentication/
├── onboarding/
├── profile/
├── discovery/
├── booking/
├── appointments/
├── services/
└── ai/
```

### Testing

```text
docs/testing/
├── strategy.md
├── unit.md
├── widget.md
├── golden.md
├── integration.md
├── architecture_tests.md
└── quality_gates.md
```

---

# 5. Implementation Tracks

Tracks MUST be executed in order unless an Architecture Decision Record explicitly changes the dependency.

## Track 00 — Repository & Architecture Audit

**Status:** `DONE`

Objectives:

* Verify the repository structure.
* Verify package dependencies.
* Verify implementation against `CLAUDE.md`.
* Identify architectural inconsistencies.
* Establish the documentation baseline.

Required documentation:

* `docs/agent/`
* `docs/architecture/`
* `docs/engineering/`

Verification:

```bash
flutter analyze
flutter test
```

---

## Track 01 — Design Tokens

**Status:** `DONE`

Objectives:

* Extract canonical visual tokens from Stitch.
* Colors.
* Typography.
* Spacing.
* Radii.
* Elevation.
* Dimensions.
* Borders.
* Opacity.
* Icons.
* Motion.
* Breakpoints.

Source pipeline:

```text
Stitch
   ↓
docs/stitch/exports/
   ↓
docs/design_system/tokens/
```

Implementation target:

```text
packages/design_system
```

Required documentation:

```text
docs/design_system/tokens/
```

---

## Track 02 — Themes & Semantics

**Status:** `DONE`

Objectives:

* Map raw tokens to semantic tokens.
* Define theme architecture.
* Integrate tokens with Flutter `ThemeData`.
* Define semantic colors and text styles.
* Preserve future RTL/theme support.

Implementation target:

```text
packages/design_system
```

---

## Track 03 — Localization Foundation

**Status:** `DONE`

Objectives:

* English-first implementation.
* Translation-key architecture.
* Arabic/RTL readiness.
* Locale switching.
* Fallback behavior.

Implementation target:

```text
packages/localization
```

---

## Track 04 — Result, Error & State Contracts

**Status:** `DONE`

Objectives:

* Define application result contracts.
* Define exception taxonomy.
* Define transport-to-application error mapping.
* Prevent raw transport exceptions from reaching UI.

Implementation target:

```text
packages/core
```

---

## Track 05 — Storage

**Status:** `IN_PROGRESS`

Objectives:

* Secure credentials/tokens. — `DONE` (`TokenStorage` / `SecureTokenStorage`)
* Local preferences. — `DONE` (`AppPreferences` / `SharedAppPreferences`)
* Onboarding persistence. — `DONE`
* `"Don't show again"` persistence. — `DONE`
* Profile-completion persistence. — `PENDING` (blocked on Track 17)
* Cache strategy. — `PENDING`

Documentation: `docs/core/storage.md`.

Implementation target:

```text
packages/core
```

---

## Track 06 — Session Management

**Status:** `DONE`

Objectives:

* Session restoration. — `DONE` (`SessionBloc` `RestoreRequested`, probed via
  `POST /client/refresh-token`; the backend has no `GET /client/me`).
  A storage read failure fails safe to `guest` and always resolves `ready`, so
  the splash cannot hang.
* Session expiration. — `DONE`. A dead token is detected on cold start;
  mid-session revocation is caught by `AuthInterceptor` and redirected to auth
  (`docs/core/session.md`, `docs/core/interceptors.md`). One 401 burst produces
  exactly one expiration and one redirect, and clears the cached client.
* Logout. — `DONE` (`SessionBloc` `LogoutRequested`; no UI affordance yet)
* Authentication state. — `DONE` (`AuthStatus` + `SessionSignal`)
* Token lifecycle. — `DONE` (issue, rotate on restore, clear on 401/logout)

**Evidence.** 63 tests in `packages/core` and 27 in `apps/client_app`;
`session_bloc_test.dart` covers the full restore matrix (no token / valid /
401 / 403 / offline / server error / unreadable storage), the expiry and burst
paths, client discard, and the anti-resurrection guard.
`session_expired_test.dart` covers the end-to-end replace-vs-push contract and
that a failed sign-in after expiry leaves the session `guest`.
`dart run melos run verify` exits 0.

Documentation: `docs/core/session.md`, `docs/navigation/guards.md`.

Implementation target:

```text
packages/core
```

---

## Track 07 — Networking

**Status:** `DONE`

Objectives:

* HTTP client.
* Environment configuration.
* Base URL configuration.
* Headers.
* Serialization.
* Timeout handling.
* Retry boundaries.

Implementation target:

```text
packages/core
```

---

## Track 08 — Interceptors & API Infrastructure

**Status:** `DONE`

Objectives:

* Authentication interceptor.
* Logging/observability interceptor.
* Error interceptor.
* Request metadata.
* Domain-split API endpoints.
* DTO mapping.

Implementation target:

```text
packages/core/network
```

---

## Track 09 — State Management

**Status:** `IN_PROGRESS`

> Locked (Phase 2): **Pure Bloc** (`flutter_bloc`) is the canonical
> state-management architecture. UI emits events; `Bloc` owns business state;
> UI renders from state. No Riverpod, Provider or GetIt. `ChangeNotifier` is
> **not** a target pattern — the session layer runs on `SessionBloc` (pure
> `bloc`) with `ApiClient.unauthorizedStream` for the 401 signal, and the
> pagination notifiers were deleted. This track still owes the async / loading /
> empty / error / refresh conventions.

Objectives:

* Establish one canonical state-management architecture. — `DONE` (Pure Bloc;
  `packages/core` uses pure `bloc` by ADR 0001, `apps/*` use `flutter_bloc`)
* Async state conventions. — `DONE` (`docs/state_management/conventions.md`,
  `async_state.md`)
* Loading. — `DONE` (`isLoading` = reading, `isSubmitting` = user-initiated
  write; initial ≠ loading ≠ empty)
* Success. — `DONE` (absence of `error` plus data; no separate flag)
* Empty. — `DONE` (`success && data.isEmpty`, never rendered as an error)
* Error. — `DONE`. Failures land in `state.error`; blocs never rethrow; the app
  localizes via `AuthError.from` — a backend `message` is never rendered.
* Refresh. — `DONE` (`docs/state_management/refresh.md`; first-load vs
  load-more vs refresh, and refresh vs filter change)
* Pagination. — `IN_PROGRESS`. The `Paged<T>` contract exists in
  `packages/core/lib/src/network/` and is covered by `paged_test.dart`, but
  **no feature consumes it yet**. It stays `IN_PROGRESS` until Discovery (016)
  validates it. If 016 finds it does not fit, change `Paged<T>` rather than
  working around it.
* Background operations. — `PENDING`, deliberately undocumented. Nothing in
  Dorak performs background work; writing a contract for it would be fiction.
  `docs/state_management/background_operations.md` stays empty until Track 13
  creates something real.

Also carried by this track:

* `ApiClient.getPaginated` now validates the envelope like every other verb — a
  `success: false` body no longer returns a successful empty page.
* `OnboardingConfigBloc` retry guard fixed: a failed config load can be retried
  for the same locale.
* `LocaleBloc` keeps `Bloc<LocaleEvent, Locale>` under the documented
  single-value-state exemption (`conventions.md` §1a), now covered by tests.
* `bloc_concurrency` is **deliberately not a dependency** — the concurrency
  convention is written down; the package arrives with its first real consumer
  (`restartable()` for Discovery's search field).

Implementation targets:

```text
apps/*
packages/feature_*
```

---

## Track 10 — Dependency Injection & Bootstrap

**Status:** `IN_PROGRESS`

Objectives:

* Application bootstrap. — `DONE` for `client_app` (`main.dart` + `app.dart`;
  see `docs/flows/app_launch.md`). `business_app` / `stylist_app` untouched.
* Dependency registration. — `PARTIAL`. Wiring is manual construction in
  `DorakApp.initState` with constructor seams for tests. No DI container.
* Environment initialization. — `DONE` (dotenv + `ConfigProvider`)
* Core service initialization. — `DONE` (storage, `ApiClient`, session,
  onboarding config)
* Application lifecycle. — `PENDING`

Implementation target:

```text
apps/*
```

---

## Track 11 — Navigation

**Status:** `IN_PROGRESS`

Objectives:

* Route definitions. — `DONE`. go_router route table in
  `app.router.dart` (`AppRouter`) + `app_routes.entity.dart`. Navigator 1.0
  and `.navigator.dart` coordinators were **removed in Phase 2**.
* Nested navigation. — `PENDING`
* Authentication guards. — `PARTIAL`. The launch gate (`AppGate.resolve`,
  installed as the router redirect) guards entry into the app; there are no
  per-route guards.
* Guest guards. — `PENDING`
* Profile-completion guards. — `PENDING` (blocked on Track 17)
* Deep links. — `PENDING`
* Notification-driven navigation. — `PENDING`

Documentation: `docs/navigation/routes.md`, `docs/navigation/guards.md`.

Implementation target:

```text
apps/*/src/core/navigation/
```

---

## Track 12 — Global UI States

**Status:** `IN_PROGRESS` — the state components exist and are tested
(`StatusView`, `AppLoader`, `ShimmerBox`, `StatusBanner`), but only
`StatusBanner` has production consumers today. The track stays `IN_PROGRESS`
until Discovery 016 consumes the other three; if 016 finds a component does
not fit, change the component, do not work around it.

Objectives:

Implement reusable:

* Full-page loading. — `DONE` (`AppLoader.page()` — `docs/design_system/components/loading/fullscreen.md`)
* Inline loading. — `DONE` (`AppLoader.inline()` — `docs/design_system/components/loading/inline.md`)
* Button loading. — `DONE` (`PrimaryButton.isLoading` — was already implemented and used by every auth form; the earlier `PENDING` status was a recording error. `SecondaryButton` deliberately has no `isLoading` — no consumer needs it)
* Shimmer. — `DONE` (`ShimmerBox`, hand-rolled, no package — `docs/design_system/components/shimmer/text.md`)
* Empty. — `DONE` (`StatusView` — `docs/design_system/states/empty.md`)
* Error. — `DONE` (`StatusView` full-page, `StatusBanner` inline; `AuthError.from` stays in the app — `docs/design_system/states/network_error.md`)
* Offline. — `DONE` (presentation variant of error; no connectivity package — `docs/design_system/states/offline.md`)
* Retry. — `DONE` (an action on `StatusView`/`StatusBanner`, not a widget — `docs/design_system/states/retry.md`)
* Session expired. — `DONE` (401/403 on an authenticated request →
  `ApiClient.unauthorizedStream` → `SessionBloc.add(UnauthorizedDetected())` →
  auth entry)
* Authentication required. — `DONE` (guest action adds `RequireAuthentication`
  → auth entry pushed on top; mechanism tested, **nothing in production
  dispatches it yet** — first producer will be Discovery 016)
* Permission required. — `PENDING` **deferred deliberately**: no permission
  mechanism exists in the workspace (no `permission_handler`, `geolocator`, or
  `connectivity_plus`) and there is no consumer. Ownership is open between
  Tracks 13/14 (see `docs/stitch/exports/016_discovery_feed/plan.md` §22);
  016's location-permission needs will trigger it. Do not build a permission
  visual without a mechanism.

Implementation targets:

```text
packages/core     # ApiClient.unauthorizedStream + SessionBloc signals
apps/*            # AppRouter listener redirects to /auth on sessionExpired
packages/design_system
```

Order change: Track 12 runs before Tracks 05 and 10 — [ADR 0003](./architecture/decisions/0003-track-12-before-05-and-10.md).

---

## Track 13 — File & Media Infrastructure

**Status:** `PENDING`

Objectives:

* Image/file selection.
* Validation.
* MIME validation.
* Size validation.
* Upload progress.
* Cancellation.
* Background upload.
* Background success/failure.
* Retry.
* Notification integration.

Implementation targets:

```text
packages/core
packages/design_system
```

---

## Track 14 — Notifications & Deep Links

**Status:** `PENDING`

Objectives:

* Notification abstraction.
* Notification permission behavior.
* Upload success/failure notifications.
* Notification actions.
* Deep-link resolution.
* In-app result reconciliation.

Implementation targets:

```text
packages/core
apps/*
```

---

## Track 15 — Shared Design-System Components

**Status:** `PENDING`

Implementation order:

```text
Buttons
↓
Inputs
↓
App Bars
↓
Navigation
↓
Tabs
↓
List Items
↓
Cards
↓
Chips
↓
Dialogs
↓
Bottom Sheets
↓
Feedback
↓
Loading
↓
Shimmer
↓
Avatars
↓
File / Media UI
↓
Global States
```

Every implemented component MUST map to its corresponding Markdown specification and Stitch source.

---

## Track 16 — Authentication

**Status:** `IN_PROGRESS`

Implementation order:

```text
Splash                      DONE  (Stitch 001)
↓
Application Initialization  DONE  (main.dart + app.dart + AppGate)
↓
Onboarding                  DONE  (Stitch 002–005; Skip ≠ Don't show again)
↓
Authentication Entry        DONE  (Stitch 006, now reachable)
↓
Login / Register            DONE  (Stitch 007–008, live backend)
↓
Verification                DONE  (Stitch 009, non-blocking)
↓
Password Recovery           PENDING  (Stitch 011–014)
↓
Session Restoration         DONE  (see Track 06)
```

Documentation: `docs/authentication/auth_flow.md`, `docs/flows/app_launch.md`,
`docs/flows/onboarding.md`, `docs/flows/guest_access.md`.

---

## Track 17 — Profile Completion

**Status:** `PENDING`

Implementation order:

```text
Complete Profile
↓
Basic Information
↓
Profile Photo
↓
Preferences
↓
Review
↓
Completion
```

The behaviors MUST distinguish:

```text
Skip
≠
Don't show again
```

---

## Track 18 — Feature Modules

**Status:** `PENDING`

Implement feature packages according to the approved product backlog and PRD.

---

## Track 19 — Business Screens

**Status:** `PENDING`

Business screens MUST consume existing:

* Design-system components.
* Core contracts.
* Navigation.
* State management.
* Repositories.
* Localization.
* Error handling.

Business screens MUST NOT recreate shared infrastructure.

---

## Track 20 — Testing & Quality Gates

**Status:** `PENDING`

Required baseline:

```bash
flutter analyze
flutter test
```

Depending on the Track:

* Unit tests.
* Widget tests.
* Golden tests.
* Integration tests.
* Architecture/dependency tests.

---

## Track 21 — Final Architecture Audit

**Status:** `PENDING`

Verify:

* `CLAUDE.md` compliance.
* Dependency boundaries.
* File naming taxonomy.
* Duplicate components.
* Error handling.
* State management.
* Security.
* Localization.
* Testing.
* Documentation consistency.
* Stitch-to-Flutter traceability.

---

# 6. Current Execution Point

**Current Track:** `Track 12 — Global UI States` — components built and tested
(`StatusView`, `AppLoader`, `ShimmerBox`, `StatusBanner`), track stays
`IN_PROGRESS` until Discovery 016 validates them. Order change vs Tracks 05/10:
[ADR 0003](./architecture/decisions/0003-track-12-before-05-and-10.md).

**Current Task:** Locale switcher standardization — complete. A shared
`LocaleSwitcher` widget now lives in `design_system` (14th widget,
string-parameterised), `OnboardingHeader` delegates to it, and the auth flow
auth entry / login / register / verify screens gained the same switcher via
`AuthHeader` (balanced 64 px slots) and a top-end overlay. Wired through the
existing `LocaleBloc`/`LocaleToggled` — no new keys, no architecture change.
4 new `client_app` tests + 2 `design_system` tests; full suite 129 green.

**Current Task:** Choose the next track. Track 12 delivered the state
components Track 09's `Paged<T>` contract needed:

* `StatusBanner` — promoted from `AuthErrorBanner` (login / sign-up / verify
  are the live consumers; string-parameterised, zero localization/core imports)
* `AppLoader.page()` / `AppLoader.inline()` — full-page and inline loading
* `StatusView` — the single empty / error / offline / retry layout
* `ShimmerBox` — hand-rolled shimmer primitive (no package)
* 5 ARB fallback keys × 2 locales (`actionRetry`, `errorTitleGeneric`,
  `errorTitleOffline`, `emptyTitleGeneric`, `emptyMessageGeneric`)
* First real `design_system` widget tests (11 new; total 12 in the package)
* Permission-required deferred with its reason recorded (owner Tracks 13/14,
  trigger 016)

**Candidates, in dependency order.** Discovery (016) needs *both* of the first
two, so neither can be skipped by starting the feature:

* `Track 05 — Storage` — cache strategy, the last unblocked objective.
* `Track 10 — Dependency Injection & Bootstrap` — application lifecycle, the
  last objective.
* `Track 16 — Authentication` — password recovery (Stitch 011–014), the only
  remaining auth work.

Track 18 / Discovery 016 additionally needs location-permission plumbing and
feed DTOs, neither of which exists.

**Just completed — post-migration hardening.** The Pure Bloc + go_router
migration was verified end to end and three defects were fixed that the green
suite did not catch:

1. **Session resurrection.** The app-layer coordinator fired on
   `authState.client != null`, and `AuthState.client` was never cleared. A
   failing sign-in *after* an expiry re-authenticated the session on its
   `isSubmitting` emission. Coordination now keys on
   `AuthSignal.loginSucceeded | registrationSucceeded` via
   `auth_coordination.entity.dart`, acknowledgement clears the client, and
   `SessionAuthenticated` is refused while `sessionExpired` is in flight.
2. **Splash hang.** A throwing `TokenStorage.read()` left the status `unknown`,
   so `ready` never completed and the splash never ended. Restore now fails safe
   to `guest`.
3. **`copyWith(client: null)` was a silent no-op** on `SessionState`,
   `AuthState` and `OnboardingConfigState`. All three now take explicit
   `clearClient` / `clearConfig` flags.

Also: a user-initiated resend now surfaces its error instead of failing
silently (registration's own dispatch stays non-blocking), the
`registrationSucceeded → resend → acknowledge` event-order race is gone, and
one 401 burst now produces exactly one expiration and one redirect.

Tracks 05, 09, 10, 11, 12 and 16 remain `IN_PROGRESS` with their remaining
objectives listed inline above. Architecture deviations are recorded as
[ADR 0001](./architecture/decisions/0001-bloc-in-core.md),
[ADR 0002](./architecture/decisions/0002-design-system-go-router.md) and
[ADR 0003](./architecture/decisions/0003-track-12-before-05-and-10.md).

The agent MUST NOT skip directly to feature implementation, and MUST NOT begin
Stitch 010–020 — those `plan.md` files stay untouched until their Track opens.

---

# 6b. Phase 2 Reconciliation Note

Post-Phase-2 the repository is aligned on the locked architecture: **Pure Bloc**
state (flutter_bloc) and **go_router** navigation (no Navigator 1.0, no
`AppNavigator`). The session/unauthorized layer is fully Bloc + Stream since
Phase 4: `SessionBloc` + `ApiClient.unauthorizedStream`; the pagination
`ChangeNotifier`s were deleted. Do not add new `ChangeNotifier` state and do not
reintroduce `.navigator.dart`.

---

# 7. Completion Rule

A Track is complete only when:

1. Required implementation exists.
2. Required documentation exists.
3. Required tests exist.
4. Required verification commands pass.
5. No known architectural violation remains.
6. The Track status is updated here.

The next Track MUST NOT begin until the current Track is complete.

---

# 8. Stitch Traceability Rule

For every Stitch-derived design:

```text
Stitch Screen
    ↓
docs/stitch/exports/<screen>/
    ↓
Normalized Markdown Specification
    ↓
Flutter Component / Screen
```

The raw Stitch export is evidence.

The Markdown specification is the implementation contract.

The Flutter code is the implementation.

Do not treat Stitch-generated HTML as production Flutter code.

---

# 9. Documentation Status Convention

Use these statuses consistently:

* `PENDING`
* `IN_PROGRESS`
* `BLOCKED`
* `REVIEW`
* `VERIFIED`
* `COMPLETE`

A task MUST NOT be marked `COMPLETE` without verification evidence.

---

# 10. Current Rule

Work on exactly one Track and one Task at a time.

Read only the context required for the current Task.

Do not load or modify unrelated business features while working on foundation infrastructure.
