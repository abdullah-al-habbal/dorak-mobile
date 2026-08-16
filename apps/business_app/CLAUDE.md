# CLAUDE.md — `apps/business_app`

Scoped rules for this app. Inherits [`../../CLAUDE.md`](../../CLAUDE.md).
Current state: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this app is

The business-owner app: branch and brand management, staff, bookings, reports.

**It is an untouched `flutter create` counter stub.** Nothing below describes
existing code — it is the contract for when work starts.

## 2. Dependency ceiling

Permitted: `core`, `design_system`, `localization` as workspace path
dependencies, plus third-party packages.

**It currently declares none of them** — only `flutter`, `cupertino_icons` and
`flutter_dotenv`. Add them when implementation begins:

```yaml
dependencies:
  core: {path: ../../packages/core}
  design_system: {path: ../../packages/design_system}
  localization: {path: ../../packages/localization}
  flutter_localizations: {sdk: flutter}
```

Forbidden: importing `client_app` or `stylist_app`, and importing any package's
`src/` directly — go through its barrel.

## 3. Directory contract — mirror `client_app`

```
lib/main.dart                    bootstrap only
lib/app.dart                     the root widget + DI wiring
lib/src/core/navigation/         app.router.dart + app_routes.entity.dart (go_router, mirror client_app)
lib/src/features/<feature>/      <name>.screen.dart + widgets/ + <name>_bloc.dart
```

Do not invent a different structure. `client_app` is the reference
implementation for bootstrap, the launch gate, navigation and testing.

## 4. Hard rules

Identical to `client_app` — they are monorepo rules, not app rules:

1. Screens are dumb; flow logic lives in `app.router.dart` (go_router).
2. Navigation through go_router (`AppRouter`), not scattered `Navigator.of(context)`.
3. No hardcoded strings — keys go in **both** ARB files in `localization`.
4. No raw colours or text styles — `design_system` tokens only.
5. One HTTP stack (`core`'s `ApiClient`), one state approach (**Pure Bloc**),
   one routing approach (**go_router**).
6. DI is constructor wiring in the root widget's `initState`. No service locator.
7. Never render a backend `message` field — it is an untranslated key.
8. Rationale goes in `AGENTS.md`, not in code comments.

## 5. Before writing features

1. Check the Track in `docs/index.md`. Business screens are **Track 19**, and it
   is `PENDING` behind several foundation tracks.
2. Track 19 states plainly: business screens MUST consume the existing design
   system, core contracts, navigation, state management, repositories,
   localization and error handling — and **MUST NOT recreate shared
   infrastructure**.
3. Replace the `flutter create` scaffolding (`MyApp`, `MyHomePage`, `_counter`)
   rather than building around it. Update `test/widget_test.dart` at the same
   time — it still asserts the counter behaviour.
4. There is no backend module mapped to this app yet. Do not invent endpoints;
   `dorak-backend` exposes `/barber` and `/branch` route groups whose contracts
   have not been reviewed for mobile.

## 6. Verification

```bash
cd dorak-mobile
dart run melos run verify
```
