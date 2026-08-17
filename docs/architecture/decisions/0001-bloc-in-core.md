# ADR 0001 — Blocs are allowed in `packages/core`

Status: `ACCEPTED`
Supersedes: the Phase-1 migration plan, which placed all blocs in the app layer.

## Context

The Bloc migration had to decide where `SessionBloc` and `AuthBloc` live.

The original migration plan put them in `apps/client_app`, on the reasoning that
`packages/core` is pure infrastructure and a state-management dependency there
forces the choice on every future consumer. `tool/check_taxonomy.dart` initially
enforced this: `.bloc.dart` / `.event.dart` / `.state.dart` were permitted only
in `apps/*` and `packages/feature_*`.

During implementation the blocs were placed in `packages/core` instead, and both
the checker and `packages/core/CLAUDE.md` were widened to match.

## Decision

**Session state stays in `packages/core`.** The taxonomy roles `.bloc.dart`,
`.event.dart` and `.state.dart` are permitted in `packages/core`, `apps/*` and
`packages/feature_*`.

`packages/core` declares **`bloc`** (pure Dart). It does **not** declare
`flutter_bloc` — the Flutter bindings (`BlocBuilder`, `BlocProvider`) belong to
the app layer, and `go_router` is never a core dependency.

## Rationale

- `bloc` is pure Dart. It carries no Flutter routing or widget dependency, so it
  does not compromise core's "no UI, no screens, no localized strings" rule.
- Core already depends on the Flutter SDK (`flutter/foundation` in
  `logging.interceptor.dart`), so this is not the first Flutter-adjacent
  dependency.
- `SessionBloc` is genuinely shared infrastructure. It composes `AuthRepository`
  and `TokenStorage`, which both already live in core. Placing the bloc one
  layer up would mean the app owns session truth while core owns the token — a
  worse split than the one being avoided.
- All three apps will eventually need session restore, expiry and logout.
  Duplicating that per app is the outcome the monorepo exists to prevent.

## Consequences

- **Core is no longer state-framework-neutral.** A future consumer that wanted a
  different state library would have to wrap `SessionBloc` rather than replace
  it. Accepted deliberately.
- `bloc_test` is a dev dependency of `packages/core`. Hand-written fakes in
  `test/helpers/` remain the rule for repositories and storage — `bloc_test`
  pulls `mocktail` transitively but it must not be used to mock those.
- The app layer keeps everything Flutter-bound: `flutter_bloc`, `go_router`,
  `LocaleBloc`, `OnboardingConfigBloc`, and the `coordinateAuthSuccess` glue.
- `apps/client_app` also pulls `provider` **transitively** through
  `flutter_bloc` (its `InheritedWidget` plumbing). This is not a direct
  dependency and does not relax the "no Provider" rule — do not import it.

## Related

- `packages/core/CLAUDE.md` §2, §3, §5
- `tool/check_taxonomy.dart` — `blocRoles`
- `docs/core/session.md`
