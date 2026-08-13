# Dorak Monorepo — AI Agent & Developer Guidelines (`CLAUDE.md`)

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

---

## 4. Development & Build Commands

When working with this monorepo via Melos or standard Flutter CLI:

```bash
# Bootstrap & link all monorepo packages
melos bootstrap

# Run code generation across all packages
melos run generate

# Run static analysis enforcing dot-suffix naming and linting
melos run analyze

# Run unit and golden tests across packages
melos run test

---

## Elicitations / Next Actions

Choose one of the following tasks to continue:

- Draft `analysis_options.yaml` to enforce file suffixes — Provide an `analysis_options.yaml` rule file that enforces the custom dot-suffix naming convention and architectural imports.
- Generate root `melos.yaml` file — Generate a complete `melos.yaml` configuration matching the workspace scripts referenced in CLAUDE.md.
- Create `.aiignore` and root `index.md` navigation template — Draft the `.aiignore` file and the initial root `index.md` navigation map for AI agents.