# ADR 0002 — `design_system` may depend on `go_router`

Status: `ACCEPTED`
Supersedes: the Phase-2 migration plan, which kept `Navigator.pop(context)` in
`BottomSheetModal` specifically so the design system stayed router-agnostic.

## Context

`packages/design_system/lib/src/widgets/bottom_sheet_modal.widget.dart` needs to
dismiss itself when the scrim is tapped, unless the caller supplies `onDismiss`.

Root `CLAUDE.md` §2 lists the design system's permitted local dependencies as
"third-party packages only". `go_router` is literally a third-party package, so
the matrix does not forbid it — but the rule was written to mean
presentation-only, with no coupling to application concerns such as routing.

The migration adopted `context.pop()` there. The alternative was
`Navigator.pop(context)`, which is behaviourally identical because go_router
drives the same underlying `Navigator`.

## Decision

**`packages/design_system` declares `go_router` and `BottomSheetModal` calls
`context.pop()`.** This is an explicit, named exception to the
presentation-only reading of §2 — not a general licence for the design system
to take on application dependencies.

## Consequences

- **Any consumer of `BottomSheetModal` must provide a `GoRouter` ancestor.**
  `context.pop()` resolves through go_router's inherited scope; without it the
  widget throws at dismiss time. This includes widget tests — pumping
  `BottomSheetModal` under a bare `MaterialApp` is not sufficient.
- `apps/business_app` and `apps/stylist_app` do not currently depend on
  `design_system`, so nothing is broken today. When either adopts it, **it must
  adopt `go_router` at the same time** or pass an explicit `onDismiss` to every
  `BottomSheetModal`.
- The escape hatch is already in the API: `onDismiss` short-circuits
  `context.pop()`. A consumer without a router can always supply it.
- Adding any *further* application-layer dependency to `design_system` requires
  a new ADR. This one covers `go_router` and nothing else.

## Related

- Root `CLAUDE.md` §2 — Architectural Boundary Matrix
- `packages/design_system/CLAUDE.md`
- Only consumer today: `apps/client_app/.../widgets/skip_bottom_sheet.sheet.dart`
