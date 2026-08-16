# CLAUDE.md — `packages/core`

Scoped rules for this package. Inherits everything in
[`../../CLAUDE.md`](../../CLAUDE.md); this file adds and narrows.
Inventory and API surface: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this package is for

The single source of infrastructure for every Dorak app: HTTP, environment
config, device storage, session lifecycle, wire models, exceptions.

It is **pure Dart + Flutter foundation**. It contains no UI, no screens, no
localized strings.

## 2. Dependency ceiling

Permitted: third-party packages, and `localization` if a genuine need arises
(currently **not** depended on — keep it that way unless a task requires it).

Forbidden, without exception:

- `design_system` — core must never know about colours, typography or widgets.
- `feature_floor_plan` or any other feature package.
- **Any `apps/*` import.** If core needs something from an app, the design is
  wrong: invert it with a callback or an abstract contract.

Current third-party set: `dio`, `flutter_dotenv`, `json_annotation`,
`flutter_secure_storage`, `shared_preferences`. Adding another needs a reason
recorded in this file or in `docs/`.

## 3. Allowed file roles here

`.client.dart` · `.interceptor.dart` · `.exception.dart` · `.dto.dart` ·
`.entity.dart` · `.endpoints.dart` · `.repository.dart` · `.notifier.dart` ·
`.provider.dart` · `.storage.dart` · `.barrel.dart`

`.storage.dart` is **exclusive to this package** — the taxonomy checker rejects
it anywhere else. `.screen.dart`, `.token.dart` and `.theme.dart` are rejected
here.

## 4. Hard rules

1. **One HTTP stack.** Everything goes through `ApiClient`. Never construct a
   bare `Dio` outside `api.client.dart`, never add `http`.
2. **No transport type escapes.** A `DioException` must never reach a caller —
   `ApiClient._guard` maps it. The one deliberate leak is
   `NetworkException.type`, which is a `DioExceptionType`; do not widen that.
3. **DTOs are generated.** Every `*.dto.dart` declares
   `part '<name>.dto.g.dart'` and `@JsonSerializable`. Hand-written `fromJson`
   is forbidden for wire models. Response DTOs use `createToJson: false`;
   generics use `genericArgumentFactories: true`. Run `melos run build` after
   editing one and commit the `.g.dart`.
4. **`.entity.dart` is for value objects only** — no JSON, no codegen.
5. **Endpoints stay domain-split.** One `<domain>.endpoints.dart` per backend
   module. A monolithic route file is a violation.
6. **Never hardcode a base URL.** It comes from `.env` through
   `ConfigProvider`. Tests pass an explicit `baseUrl`.
7. **Do not invent endpoints.** Only add a route constant that exists in
   `dorak-backend`.
8. **Storage contracts stay abstract.** Every store is an abstract class plus a
   concrete implementation in the same file, so tests can substitute a fake and
   never touch a platform channel.
9. **Abstract + impl in one file.** `AuthRepository` + `DioAuthRepository`,
   `TokenStorage` + `SecureTokenStorage`. Do not split them.
10. **Export through barrels.** A new public type must be reachable from
    `lib/core.dart`, via its section barrel.

## 5. State management

The session/unauthorized state that lives in this package is **transitional**:
`SessionController`, `UnauthorizedNotifier` and `SessionNotice` are
`ChangeNotifier`-based and stay as-is until Phase 4 replaces them with
Stream/Bloc. The pagination notifiers (`page_pagination.notifier.dart`,
`scroll_pagination.notifier.dart`) are **legacy** ChangeNotifier — do not
extend them. Do not add new `ChangeNotifier` state here.

**Target state lives at the app layer as Pure Bloc** (`flutter_bloc`). Core
stays framework-agnostic: it exposes repositories and the session stream
surface; feature blocs consume them. No Riverpod, Provider or GetIt anywhere.

Convention: mutating methods **rethrow** so callers can branch on
`ValidationException`; `error` is also recorded for listeners.

## 6. Verification

```bash
cd dorak-mobile
dart run melos run build      # after any DTO change
dart run melos run analyze
dart run melos run test
```

New public behaviour needs a test in `packages/core/test/`. Use the existing
helpers (`test/helpers/fake_dio.dart`, `test/helpers/fake_auth.dart`) rather
than adding a mocking package.
