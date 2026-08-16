# AGENTS.md — `apps/business_app`

**Status: `flutter create` counter stub. No Dorak features exist.**

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)
· Files: [`docs/feature-index.md`](./docs/feature-index.md)

---

## 1. What is actually here

```
lib/main.dart                 67 lines — MyApp + MyHomePage + _counter
test/widget_test.dart         the default counter test
.env / .env.example           present, and dotenv IS loaded
docs/feature-index.md         records "App is a skeleton"
```

That is the entire app. `main.dart` is the stock Flutter demo with exactly one
edit — `main()` is `Future<void>` and awaits `dotenv.load()`:

```dart
Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}
```

`.env` carries the same backend URLs as the other apps:

```
API_BASE_URL=https://dev-dorak-backend.io/api
API_BASE_URL_V1=https://dev-dorak-backend.io/api/v1
```

...but nothing reads them — `ConfigProvider` lives in `core`, and this app does
not depend on `core`.

**Its `pubspec.yaml` declares no workspace packages**: no `core`, no
`design_system`, no `localization`. It is in the Melos workspace and passes the
gate only because it is untouched.

> `docs/feature-index.md` claims `main.dart` boots `DorakApp`. It does not — it
> boots `MyApp`. The doc is wrong.

## 2. What it is meant to become

The business-owner app: branch and brand management, staff, bookings, reports
(per its own feature index). None of it is specced — there are no Stitch
exports for business screens, and no mobile-reviewed backend contract.

`dorak-backend` has `/barber` and `/branch` route groups, both with a
`GET /profile` that the client module lacks, but nothing has been mapped for
this app.

## 3. Bringing it into the monorepo

Do this before any feature work, and copy `client_app` rather than improvising:

1. **Add the workspace dependencies** (`core`, `design_system`, `localization`,
   `flutter_localizations`) — see [`CLAUDE.md`](./CLAUDE.md) §2.
2. **Replace the scaffolding.** Delete `MyApp` / `MyHomePage` / `_counter`.
   Split bootstrap into `lib/main.dart` + `lib/app.dart` exactly as `client_app`
   does: binding init → dotenv → `SharedAppPreferences.create()` → root widget.
3. **Wire `ApiClient` with `tokenProvider`**, or `AuthInterceptor` never
   installs and every request goes out unauthenticated with no error.
4. **Set up localization** — `localizationsDelegates`, `supportedLocales`, and
   `DorakTheme.forLocale(locale, brightness)`. All three apps share one ARB
   pair; add business keys there.
5. **Rewrite `test/widget_test.dart`.** It still asserts the counter increments
   and will fail the moment the scaffolding goes.
6. **Decide the auth story.** The backend's client session layer
   (`SessionBloc`, `/client/*` routes) is customer-specific. A business
   user is a different guard (`barber` / `branch_api`) — do not reuse
   `SessionBloc` without checking the contract.

## 4. Constraints

- Everything under `lib/src/` must carry a valid role suffix — `.screen.dart`,
  `.widget.dart`, `.navigator.dart` and so on. Files at `lib/` root are exempt,
  which is why the current `main.dart` passes.
- `.screen.dart` is permitted here (apps only). `.navigator.dart` is still
  accepted for this stub but is **deprecated** — when work starts, mirror
  `client_app`'s go_router layout (`app.router.dart`), and use `.router.dart`,
  `.bloc.dart`, `.event.dart`, `.state.dart` roles. `.token.dart`, `.theme.dart`
  and `.storage.dart` are not.
- Track 19 (`docs/index.md`) governs business screens and is `PENDING` behind
  several foundation tracks. Check the current execution point before starting.

## 5. Commands

```bash
cd apps/business_app
flutter run
flutter test

cd dorak-mobile && dart run melos run verify
```
