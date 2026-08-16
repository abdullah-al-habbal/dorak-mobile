# Dorak Monorepo — AI Agent & Developer Guidelines (`CLAUDE.md`)

> **Read [`AGENTS.md`](./AGENTS.md) first.** It is the entry point: current
> feature inventory, backend contract, testing conventions, and the design
> decisions that are not visible in the source (the Dart code carries almost no
> comments). This file is the normative taxonomy and layering contract that
> `AGENTS.md` summarises.
>
> **This file is the parent rulebook.** Every app and package carries its own
> scoped `CLAUDE.md` that inherits from it and narrows further — dependency
> ceiling, permitted file roles, unit-specific prohibitions. Read the child for
> whatever you are editing:
>
> | Unit | Scoped rules | Inventory |
> |---|---|---|
> | `apps/client_app` | [`CLAUDE`](./apps/client_app/CLAUDE.md) | [`AGENTS`](./apps/client_app/AGENTS.md) |
> | `apps/business_app` | [`CLAUDE`](./apps/business_app/CLAUDE.md) | [`AGENTS`](./apps/business_app/AGENTS.md) |
> | `apps/stylist_app` | [`CLAUDE`](./apps/stylist_app/CLAUDE.md) | [`AGENTS`](./apps/stylist_app/AGENTS.md) |
> | `packages/core` | [`CLAUDE`](./packages/core/CLAUDE.md) | [`AGENTS`](./packages/core/AGENTS.md) |
> | `packages/design_system` | [`CLAUDE`](./packages/design_system/CLAUDE.md) | [`AGENTS`](./packages/design_system/AGENTS.md) |
> | `packages/localization` | [`CLAUDE`](./packages/localization/CLAUDE.md) | [`AGENTS`](./packages/localization/AGENTS.md) |
> | `packages/feature_floor_plan` | [`CLAUDE`](./packages/feature_floor_plan/CLAUDE.md) | [`AGENTS`](./packages/feature_floor_plan/AGENTS.md) |
>
> A child never relaxes a parent rule. Where it is silent, the parent applies.

This repository is a deterministic, AI-native Flutter/Dart monorepo architecture for **Dorak**. All AI assistants and human developers must strictly follow the architectural boundaries, file naming taxonomy, and dependency constraints detailed in this document.

---

## 1. File Naming Taxonomy & Architectural Roles

All Dart files in this codebase **MUST** follow the explicit dot-suffix taxonomy:

`<domain_or_subject>.<architectural_role>.dart`

### Mandatory Role Suffix Reference

| Role Suffix | Usage & Context | Permitted Locations |
| :--- | :--- | :--- |
| `.screen.dart` | Full-page scaffolds, routes, and page layouts. | `apps/*` only |
| `.widget.dart` | Reusable atomic UI components and view elements. | `packages/design_system`, `packages/feature_*`, `apps/*` |
| `.sheet.dart` | Bottom sheet overlays and modal dialogs. | `packages/feature_*`, `apps/*` |
| `.token.dart` | Design system visual tokens (colors, typography, spacing). | `packages/design_system` |
| `.theme.dart` | Theme configurations and extensions. | `packages/design_system`, `apps/*` |
| `.entity.dart` | Pure domain models and business entities. | `packages/core`, `apps/*/domain` |
| `.dto.dart` | Data Transfer Objects for network/storage serialization. | `packages/core`, `apps/*/data` |
| `.endpoints.dart` | Domain-split API route declarations. | `packages/core/network/endpoints` |
| `.repository.dart` | Repository contracts and implementations. | `packages/core`, `apps/*` |
| `.provider.dart` / `.notifier.dart` | State management and dependency injection providers. | `apps/*`, `packages/feature_*` |
| `.storage.dart` | Device persistence contracts and implementations (secure storage, preferences, cache). | `packages/core` only |
| `.navigator.dart` | **DEPRECATED** — legacy route-flow coordinators (removed from `client_app` in Phase 2) | only `business_app`/`stylist_app` stubs |
| `.router.dart` | Declarative `go_router` route table + redirects. | `apps/*` only |
| `.bloc.dart` / `.event.dart` / `.state.dart` | Pure Bloc feature state (Phase 3). | `apps/*`, `packages/feature_*` |
| `.barrel.dart` | Explicit package or feature re-exports. | Anywhere requiring grouped exports |

### Strict Rules
1. **One Class Per File:** Every `.dart` file must contain exactly **one** top-level class or widget.
2. **Screen vs. Widget Boundary:** Full-page scaffolds (`.screen.dart`) reside strictly within executable apps (`apps/`). Shared packages export visual components (`.widget.dart`) or bottom sheets (`.sheet.dart`).
3. **Domain-Split Endpoints:** Monolithic endpoint files are strictly forbidden. Split network routes into domain files inside `endpoints/` (e.g., `auth.endpoints.dart`) and export via `endpoints.barrel.dart`.

---

## 2. Package Dependency & Layering Hierarchy

The dependency graph enforces a strict **bottom-up unidirectional flow**. Higher-level layers may depend on lower-level layers, but lower-level layers **NEVER** import higher-level ones.

```text
                  ┌─────────────────┐
                  │   apps/*        │ (client_app, business_app, stylist_app)
                  └────────┬────────┘
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
  ┌──────────────────┐ ┌──────┐ ┌─────────────────┐
  │feature_floor_plan│ │ core │ │ design_system   │
  └──────────┬───────┘ └───┬──┘ └─────────────────┘
             │             │
             ▼             │
      ┌──────────────┐     │
      │ localization │◄────┘
      └──────────────┘

```

### Architectural Boundary Matrix

| Layer | Repository Path | Permitted Local Dependencies | Reusability Scope |
| --- | --- | --- | --- |
| **Global Docs & Config** | `/`, `/docs` | None | Root monorepo policy |
| **Design System** | `mobile/packages/design_system` | Third-party packages only | All mobile apps & shared packages |
| **Localization** | `mobile/packages/localization` | Third-party packages only | All mobile apps & shared packages |
| **Shared Core** | `mobile/packages/core` | `localization` | All mobile apps & feature packages |
| **Feature Packages** | `mobile/packages/feature_*` | `design_system`, `core`, `localization` | Selected mobile apps |
| **Executable Apps** | `mobile/apps/*` | All `packages/*` via path dependencies | Standalone binaries |

---

## 3. AI Governance & Navigation Rules

To maximize token efficiency and prevent auto-import collisions:

1. **Context Guardrails (`.aiignore`):** AI agents must not index build artifacts, generated code (`*.g.dart`, `*.freezed.dart`), Flutter/Dart tool caches (`.dart_tool/`), or backend builds.
2. **Navigation Map (`index.md`):** Consult the `index.md` file in subdirectories before performing recursive directory searches.
3. **No Cross-Layer Imports:** Do not import app-specific logic (`apps/*`) into packages (`packages/*`). Do not import `design_system` directly into `core`.

## 3b. State & Navigation Architecture (locked)

**State — Pure Bloc.** UI emits events; a `Bloc` owns business state; UI
renders from state. `flutter_bloc` only. No Riverpod, Provider or GetIt.
**`ChangeNotifier` is not a target pattern** — the only remaining instances are
transitional Track 12/session infrastructure (`SessionController`,
`UnauthorizedNotifier`, `SessionNotice`) and the legacy pagination notifiers
(`page_pagination.notifier.dart`, `scroll_pagination.notifier.dart`). Keep them
as-is; do not extend them; Phase 4 replaces them with Stream/Bloc. Do not add
new `ChangeNotifier` state.

**Navigation — go_router only.** Declarative route table, redirects for the
launch gate and auth guards, `context.push/go/pop` in screens. Navigator 1.0
and `AppNavigator` are removed from `client_app`; `.navigator.dart` is a
deprecated taxonomy role tolerated only in the `business_app`/`stylist_app`
stubs. Bloc never navigates — routing responds to state via redirects and the
router listener. Local modal dismissal uses `context.pop()`. Routing lives in
the router (`app.router.dart` + `app_routes.entity.dart`), never in a screen or
bloc.

---

## 4. Development & Build Commands

When working with this monorepo via Melos or standard Flutter CLI:

```bash
# Bootstrap & link all monorepo packages
melos bootstrap

# Run code generation across all packages
melos run generate      # localization (gen-l10n)
melos run build         # build_runner (DTO/model codegen)

# Run static analysis enforcing dot-suffix naming and linting
melos run analyze

# Run unit and golden tests across packages
melos run test

# Full verification gate
melos run verify        # generate → build → analyze → taxonomy → test
```

---

## 4b. Code Generation Policy (mandatory)

**All new and existing `*.dto.dart` models MUST use `build_runner` +
`json_serializable` codegen — hand-written `fromJson` is forbidden.**

1. Every DTO declares `part '<file>.g.dart';` and an
   `@JsonSerializable` annotation. `fromJson` is generated; generated files
   are committed alongside the DTO.
2. `fieldRename: FieldRename.snake` maps backend snake_case automatically;
   `@JsonKey(name: ..., defaultValue: ...)` for key overrides and defaults.
3. Response DTOs use `createToJson: false` (requests use plain maps);
   generic DTOs (`ApiResponse<T>`, `PaginatedData<T>`) use
   `genericArgumentFactories: true`.
4. After editing a DTO, regenerate:
   `melos run build` (runs build_runner only in packages that declare
   `json_serializable`). Run `melos run verify` before finishing.
5. Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from the
   analyzer (`analysis_options.yaml`), the taxonomy checker
   (`tool/check_taxonomy.dart`), and AI indexing (`.aiignore`).
6. Exception: plain value objects with no JSON serialization
   (e.g. `discovery_card.entity.dart`) may stay hand-written; they are not
   DTOs. Anything that touches a wire format must use codegen.

---

## Next Actions

All of the scaffolding this section used to request now exists:
`analysis_options.yaml`, `.aiignore`, and the root `index.md` are in place, and
the Melos configuration lives in the root `pubspec.yaml` (there is no separate
`melos.yaml`). `melos` is not on `PATH` — invoke it as `dart run melos run <script>`.

For what to work on next, see the **Current Execution Point** in
[`docs/index.md`](./docs/index.md). For everything else, see
[`AGENTS.md`](./AGENTS.md).