# CLAUDE.md — `packages/feature_floor_plan`

Scoped rules for this package. Inherits [`../../CLAUDE.md`](../../CLAUDE.md).
Current state: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this package is for

The branch floor-plan and chair-selection feature (Stitch 017), packaged so
more than one app can mount it.

**It is an empty stub.** Nothing is implemented. Treat everything below as the
contract for when work starts, not a description of what exists.

## 2. Dependency ceiling

This is a **feature package** — one layer above the shared packages.

Permitted: `design_system`, `core`, `localization`, and third-party packages.
Currently it declares only `flutter`; add the workspace path dependencies when
implementation begins.

Forbidden: any `apps/*` import, and any other `feature_*` package.

## 3. Allowed file roles here

What `tool/check_taxonomy.dart` actually permits here today:

`.widget.dart` · `.sheet.dart` · `.provider.dart` · `.barrel.dart` ·
`.client.dart` · `.interceptor.dart` · `.exception.dart`

**Rejected here:**

- `.screen.dart` — apps only. Full-page scaffolds live in `apps/*`; this package
  exports composable widgets that an app hosts inside its own screen.
- `.navigator.dart` — **deprecated** role, apps only; do not use here.
- `.router.dart` — go_router route tables are app-owned; do not use here.
- `.token.dart` / `.theme.dart` — `design_system` only.
- `.storage.dart` — `core` only.
- **`.repository.dart` · `.dto.dart` · `.entity.dart` · `.notifier.dart` ·
  `.endpoints.dart`** — the checker restricts these to `packages/core` and
  `apps/*/lib`, and a feature package is **not** in that allow-list.

That last group is the one that will bite: a feature package with its own data
layer or `ChangeNotifier` cannot currently express it. Either put the data
access in `core`, or extend `tool/check_taxonomy.dart` deliberately — as was
done for `.storage.dart` and `.navigator.dart` — and record the change in the
root `CLAUDE.md` §1 table. Do not work around it with a misleading suffix.
`.bloc.dart` / `.event.dart` / `.state.dart` **are** permitted here — build
feature state as Blocs, not notifiers.

## 4. Hard rules

1. **No second architecture.** Network calls go through `core`'s `ApiClient`;
   state is **Pure Bloc** (`flutter_bloc`); strings come from `localization`;
   visuals come from `design_system` tokens.
2. **No navigation.** This package must not push routes or reference an app's
   router. Expose callbacks; the hosting app decides where they go.
3. **One public entry point:** `lib/feature_floor_plan.dart` re-exports
   whatever the package offers. Consumers import only that.
4. **Fix `analysis_options.yaml` before writing code.** It currently includes
   `package:flutter_lints/flutter.yaml` directly instead of the workspace
   baseline, so this package is analysed under weaker rules than the rest of the
   monorepo. Change it to `include: ../../analysis_options.yaml`.
5. **Do not start early.** Track 18 in `docs/index.md` governs feature packages;
   Stitch 017 is unimplemented. Confirm the current Track before building here.

## 5. Verification

```bash
cd dorak-mobile
dart run melos run analyze
dart run melos run taxonomy
dart run melos run test
```
