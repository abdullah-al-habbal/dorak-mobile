# AGENTS.md — `packages/feature_floor_plan`

**Status: empty stub. No implementation exists.**

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)

---

## 1. Current state

```
lib/feature_floor_plan.dart        0 bytes — not even `library;`
lib/src/controller/                empty
lib/src/models/                    empty
lib/src/widgets/canvas/            empty
lib/src/widgets/chairs/            empty
lib/src/widgets/overlays/          empty
test/feature_floor_plan_test.dart  expect(true, isTrue)
```

`pubspec.yaml` declares only `flutter` — **no `core`, no `design_system`, no
`localization`**. Those path dependencies must be added when work starts.

Nothing imports this package. It is in the workspace and passes the gate purely
because it is empty.

## 2. What it is meant to become

The branch floor-plan and chair-selection experience — **Stitch 017
(`branch_floor_plan_and_booking`)**, still sitting in
`docs/stitch/exports/017_branch_floor_plan_and_booking/`.

The directory names suggest the intended shape: a canvas widget, chair widgets,
overlay widgets, a controller, and models. Treat that as a sketch, not a
commitment — nothing has been designed.

It is packaged rather than app-local because both `client_app` (booking a chair)
and `business_app` (laying a branch out) are expected to need it.

## 3. Before writing any code here

1. **Check the Track.** `docs/index.md` §6 gives the current execution point.
   Feature packages are Track 18; Stitch 017 is not started. Do not implement
   ahead of the Track order.
2. **Read the export** in `docs/stitch/exports/017_branch_floor_plan_and_booking/`
   — `code.html` is the layout source, `screen.png` the reference. `DESIGN.md`
   in that folder is the global token spec, already implemented in
   `design_system`; do not regenerate tokens from it.
3. **Read `cursor/skills/stitch-flutter-converter.md`** for the export →
   Flutter conversion protocol.
4. **Fix `analysis_options.yaml`** — it points at `package:flutter_lints/flutter.yaml`
   instead of `../../analysis_options.yaml`, so this package misses the
   workspace lint rules (`always_use_package_imports`, `prefer_single_quotes`,
   `always_declare_return_types`). Every other package and app includes the
   baseline.
5. **Add the workspace dependencies** you actually need:
   ```yaml
   dependencies:
     core: {path: ../core}
     design_system: {path: ../design_system}
     localization: {path: ../localization}
   ```

## 4. Constraints that will bite

- **No `.screen.dart` here.** The taxonomy checker allows that role only under
  `apps/*/lib`. Export widgets; let the app own the page.
- **`repository` / `dto` / `entity` / `endpoints` are also
  rejected** in feature packages by the current checker — they are restricted to
  `packages/core` and `apps/*/lib`. Either put data access in `core` or extend
  `tool/check_taxonomy.dart` deliberately first.
- **No navigation.** Expose callbacks; the host app routes.
- **Strings via `localization`**, visuals via `design_system` tokens, HTTP via
  `core`'s `ApiClient`. No second stack of anything.

## 5. Commands

```bash
cd dorak-mobile
dart run melos run analyze
dart run melos run taxonomy
dart run melos run test
```
