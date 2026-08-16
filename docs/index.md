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

**Status:** `IN_PROGRESS`

Objectives:

* Session restoration. — `DONE` (`SessionController.restore`, probed via
  `POST /client/refresh-token`; the backend has no `GET /client/me`)
* Session expiration. — `DONE`. A dead token is detected on cold start, and —
  since Track 12 — mid-session revocation is caught by `AuthInterceptor` and
  redirected to auth (`docs/core/session.md`, `docs/core/interceptors.md`).
* Logout. — `DONE` (`SessionController.logout`; no UI affordance yet)
* Authentication state. — `DONE` (`AuthStatus`)
* Token lifecycle. — `DONE` (issue, rotate on restore, clear on 401/logout)

Documentation: `docs/core/session.md`.

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

* Establish one canonical state-management architecture.
* Async state conventions.
* Loading.
* Success.
* Empty.
* Error.
* Refresh.
* Pagination.
* Background operations.

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
* Authentication guards. — `PARTIAL`. The launch gate (`AppGate.decide`,
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

**Status:** `IN_PROGRESS`

This track's current task — the `session_expired` and `authentication_required`
states plus the 401 wiring — is `DONE` (see `docs/core/interceptors.md`,
`docs/core/session.md`, `docs/navigation/guards.md`). The remaining states below
are still pending.

Objectives:

Implement reusable:

* Full-page loading. — `PENDING`
* Inline loading. — `PENDING`
* Button loading. — `PENDING`
* Shimmer. — `PENDING`
* Empty. — `PENDING`
* Error. — `PENDING`
* Offline. — `PENDING`
* Retry. — `PENDING`
* Session expired. — `DONE` (401/403 on an authenticated request →
  `ApiClient.unauthorizedStream` → `SessionBloc.add(UnauthorizedDetected())` →
  auth entry)
* Authentication required. — `DONE` (guest action adds `RequireAuthentication`
  → auth entry pushed on top)
* Permission required. — `PENDING`

Implementation targets:

```text
packages/core     # ApiClient.unauthorizedStream + SessionBloc notices
apps/*            # AppRouter listener redirects to /auth on sessionExpired
packages/design_system
```

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

**Current Track:** `Track 12 — Global UI States`

**Current Task:** Done. The `session_expired` and `authentication_required`
global states are implemented and the 401 interceptor wiring redirects a
revoked token to auth instead of throwing at the call site — closing the open
item on Track 06. See `docs/core/interceptors.md`, `docs/core/session.md`,
`docs/navigation/guards.md`, and `app.router.dart`.

Tracks 05, 06, 10, 11 and 16 are `IN_PROGRESS` with their remaining objectives
listed inline above. The auth + onboarding launch flow is delivered end to end:
see `docs/flows/app_launch.md`.

The agent MUST NOT skip directly to feature implementation.

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
