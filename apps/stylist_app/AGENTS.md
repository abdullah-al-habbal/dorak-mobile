# AGENTS.md — `apps/stylist_app`

**Status: `flutter create` counter stub. No Dorak features exist.**

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)
· Files: [`docs/feature-index.md`](./docs/feature-index.md)

---

## 1. What is actually here

```
lib/main.dart                 73 lines — MyApp + MyHomePage + _counter
test/widget_test.dart         the default counter test
.env / .env.example           present, and dotenv IS loaded
docs/feature-index.md         records "App is a skeleton"
```

That is the entire app. `main.dart` is the stock Flutter demo with one edit —
`main()` is `Future<void>` and awaits `dotenv.load()` — plus a few stray empty
`//` lines left from the template.

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

The stylist/barber app: offered services, availability, schedule, reviews, job
applications (per its own feature index). None of it is specced — there are no
Stitch exports for stylist-facing screens.

Note the distinction: `docs/stitch/exports/019_stylist_profile/` is the
**customer's view of a stylist**, and belongs to `client_app`. It is not a
screen for this app.

`dorak-backend` has a `/barber` route group with its own guard and a
`GET /profile`, but nothing has been mapped for this app.

## 3. Bringing it into the monorepo

Do this before any feature work, and copy `client_app` rather than improvising:

1. **Add the workspace dependencies** (`core`, `design_system`, `localization`,
   `flutter_localizations`) — see [`CLAUDE.md`](./CLAUDE.md) §2.
2. **Replace the scaffolding.** Delete `MyApp` / `MyHomePage` / `_counter` and
   the stray comment lines. Split bootstrap into `lib/main.dart` +
   `lib/app.dart` exactly as `client_app` does: binding init → dotenv →
   `SharedAppPreferences.create()` → root widget.
3. **Wire `ApiClient` with `tokenProvider`**, or `AuthInterceptor` never
   installs and every request goes out unauthenticated with no error.
4. **Set up localization** — `localizationsDelegates`, `supportedLocales`, and
   `DorakTheme.forLocale(locale, brightness)`. All three apps share one ARB
   pair; add stylist keys there.
5. **Rewrite `test/widget_test.dart`.** It still asserts the counter increments
   and will fail the moment the scaffolding goes.
6. **Decide the auth story.** `SessionBloc` and the `/client/*` routes are
   customer-specific. A barber authenticates against a different guard — do not
   reuse the client session layer without checking the contract.

## 4. Constraints

- Everything under `lib/src/` must carry a valid role suffix — `.screen.dart`,
  `.widget.dart`, `.navigator.dart` and so on. Files at `lib/` root are exempt,
  which is why the current `main.dart` passes.
- `.screen.dart` is permitted here (apps only). `.navigator.dart` is still
  accepted for this stub but is **deprecated** — when work starts, mirror
  `client_app`'s go_router layout (`app.router.dart`), and use `.router.dart`,
  `.bloc.dart`, `.event.dart`, `.state.dart` roles. `.token.dart`, `.theme.dart`
  and `.storage.dart` are not.
- Check the current execution point in `docs/index.md` before starting. No Track
  is dedicated to this app yet.

## 5. Commands

```bash
cd apps/stylist_app
flutter run
flutter test

cd dorak-mobile && dart run melos run verify
```
