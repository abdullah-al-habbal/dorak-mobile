# CLAUDE.md — `packages/design_system`

Scoped rules for this package. Inherits [`../../CLAUDE.md`](../../CLAUDE.md).
Inventory and API surface: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this package is for

Visual foundation shared by all three apps: design tokens, `ThemeData`
construction, bundled fonts, and cross-app widgets.

It is the **only** place raw colour, type and dimension values may exist.

## 2. Dependency ceiling

Permitted: `flutter` and third-party packages only. Currently: `go_router`
(routing-only — used solely for `context.pop()` in `BottomSheetModal`).

Forbidden, without exception:

- **`localization`.** This is the load-bearing constraint of the package. A
  shared widget must never resolve a string; it receives every user-visible
  string as a constructor parameter. `OnboardingHeader(brandLabel:, skipLabel:,
  localeLabel:)` is the pattern.
- **`core`.** No networking, no DTOs, no session, no storage.
- **Any `apps/*` import.**

## 3. Allowed file roles here

`.token.dart` · `.theme.dart` · `.widget.dart` · `.barrel.dart`

`.token.dart` and `.theme.dart` are **exclusive to this package** — the
taxonomy checker rejects them anywhere else. `.screen.dart`, `.dto.dart`,
`.entity.dart`, `.repository.dart`, `.notifier.dart` and `.endpoints.dart` are
all rejected here.

## 4. Hard rules

1. **No business logic.** Widgets take data and callbacks and render. No
   network calls, no persistence, no application navigation. The **only**
   navigation call in the package is `BottomSheetModal`'s `context.pop()` —
   local modal-route dismissal, never app routing.
2. **No strings.** Every label is a parameter. No hardcoded English, no
   `AppLocalizations`.
3. **Hex literals live only in `src/tokens/`.** Everything else reads
   `DorakColors.of(context)`. A `Color(0xFF…)` in a widget file is a defect.
4. **Widgets consume tokens, not `Theme.of`.** Use `DorakColors.of(context)`,
   `DorakTypography.*`, `DorakDimensions.*`.
5. **One widget per file**, named `<subject>.widget.dart`, exported from
   `lib/design_system.dart`.
6. **RTL-safe by construction.** Use `AlignmentDirectional`, `EdgeInsetsDirectional`
   and `TextAlign.start`. Never hardcode left/right. Directional icons follow
   `isRtl ? Icons.arrow_forward : Icons.arrow_back`.
7. **No unbounded text in a `Row`.** Wrap in `Flexible` or use `Wrap`. Arabic
   and large text scales are wider than the English mock.
8. **Promotion is deliberate.** A widget belongs here only when it is genuinely
   used by more than one app, or is specified by Track 15. Feature-local
   widgets stay in `apps/*/lib/src/features/<feature>/widgets/`. Do not
   pre-emptively hoist.
9. **Fonts are bundled here.** `IBM Plex Sans` and `IBM Plex Sans Arabic` ship
   in `fonts/` and are declared in this package's `pubspec.yaml`. Apps must not
   re-declare them.

## 5. Verification

```bash
cd dorak-mobile
dart run melos run analyze
dart run melos run test
```

Rendering changes should be checked in `client_app` — this package has no
example app and its test file is a placeholder.
