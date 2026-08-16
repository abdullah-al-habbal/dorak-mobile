# CLAUDE.md — `apps/client_app`

Scoped rules for this app. Inherits [`../../CLAUDE.md`](../../CLAUDE.md).
Inventory, flows and gotchas: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this app is

The end-user (customer) app — the only one of the three with real features.
Discovery, booking, profile, and the auth + onboarding launch flow.

## 2. Dependency ceiling

Permitted: `core`, `design_system`, `localization` (all declared as workspace
path dependencies), plus third-party packages.

Forbidden: importing another app, and importing another package's `src/`
directly — always go through its barrel (`package:core/core.dart`,
`package:design_system/design_system.dart`, `package:localization/localization.dart`).

`dio` is a **test-only** dev dependency (constructing a `NetworkException` in a
fake needs `DioExceptionType`). Never import it from `lib/`.

## 3. Directory contract

```
lib/main.dart                    bootstrap only
lib/app.dart                     DorakApp — DI wiring + MaterialApp.router
lib/src/core/navigation/         app.router.dart (AppRouter) + app_routes.entity.dart + app_gate.entity.dart
lib/src/features/<feature>/      <name>.screen.dart + widgets/ + entities + <name>_bloc.dart
```

Files at `lib/` root are exempt from the taxonomy checker; everything under
`lib/src/` is not.

## 4. Hard rules

1. **Screens are dumb.** A `.screen.dart` receives callbacks and renders. It
   must not call a repository, touch storage, or decide where to navigate next.
2. **Flow logic lives in `AppRouter`** (`app.router.dart`), never inside a
   screen or a bloc. Screens receive callbacks wired by the router. The router
   owns the two stream listeners (session + auth): it re-runs the redirect on
   every state change and reacts to `SessionSignal` (auth/home/verify
   navigation), then acknowledges each signal — session signals via
   `SignalAcknowledged`, auth signals via `AuthSignalAcknowledged`.
3. **Navigation is go_router through `AppRouter`** — `router.push/go`, or
   `context.push/pop/go` inside screens. A local `context.pop()` to dismiss the
   current route or sheet is the established idiom. Bloc never navigates.
4. **No hardcoded strings.** `AppLocalizations.of(context)!` for everything
   user-visible; add keys to both ARB files first.
5. **No raw colours or text styles.** `DorakColors.of(context)`,
   `DorakTypography.*`, `DorakDimensions.*`. A `Color(0xFF…)` here is a defect.
6. **No second HTTP, state or routing stack.** `ApiClient` from `core`;
   **Bloc** state (`flutter_bloc` at the app layer, pure `bloc` in core);
   **go_router** routing. No Riverpod, Provider or GetIt. `ChangeNotifier` is
   not used — do not add it.
7. **DI is constructor wiring in `DorakApp.initState`.** There is no container.
   Add a field there and thread it down; do not introduce a service locator.
8. **Test seams stay optional.** `DorakApp`'s `tokenStorage` and
   `authRepository` parameters exist for tests and must default to null in
   production.
9. **Feature-local widgets stay local.** Promote to `design_system` only when a
   second app genuinely needs it (Track 15). Do not pre-emptively hoist
   `AuthTextField` or `OtpInputField`.
10. **Never render a backend `message`.** The API returns untranslated keys
    (`core::messages.*`). Map exceptions to local ARB strings — see
    `auth_error.entity.dart`.
11. **The code carries no comments.** Rationale goes in `AGENTS.md` §"Decisions
    that are not in the code", not inline.

## 5. Assets

`assets/images/` and `.env` are declared in `pubspec.yaml`. Local assets only —
no `Image.network` for critical UI. Never ship an SVG for `Image.asset`;
Flutter cannot decode it.

## 6. Verification

```bash
cd dorak-mobile
dart run melos run verify          # the gate — must exit 0

cd apps/client_app
flutter test                       # 26 tests
```

Widget tests must use the fakes in `test/helpers/fakes.dart` and set a phone
viewport — the 800×600 default overflows these screens.

**Construct blocs inside the `testWidgets` body, never in `setUp`** — a bloc
built in `setUp` sits outside the FakeAsync zone, so its event stream never
delivers and `await session.ready` hangs. Drive it with `pump`/`pumpAndSettle`.
