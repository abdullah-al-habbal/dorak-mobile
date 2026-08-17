# ADR 0003 — Track 12 runs before Tracks 05 and 10

Status: `ACCEPTED`

## Context

`docs/index.md` mandates: *"Tracks MUST be executed in order unless an
Architecture Decision Record explicitly changes the dependency."*

Track 12 (Global UI States) is currently blocked by that rule: Tracks 05
(Storage) and 10 (Dependency Injection & Bootstrap) are lower-numbered and
still `IN_PROGRESS`. Track 12 renders the `Paged<T>` state contract Track 09
specified, and Stitch 016 §39 names it as the binding prerequisite of the
Discovery feed ("This screen depends on the Track 12 implementation").

What remains open in the two deferred tracks:

- **Track 05** — only one objective left unblocked: the cache strategy, with
  no consumer. The other four objectives are `DONE`.
- **Track 10** — the application-lifecycle objective is real but small and
  independent: it touches `DorakApp`, which Track 12 does not.

Neither track's remaining work interacts with Track 12's widgets, localization
keys, or tests.

## Decision

**Execute Track 12 before Tracks 05 and 10.** Both deferred tracks stay
`IN_PROGRESS`; neither is cancelled. The next execution point records this
change.

## Consequences

- Discovery (016) is unblocked on its UI-state prerequisite without waiting for
  the storage cache or lifecycle work.
- Track 05 and Track 10 resume later with their remaining objectives intact and
  no rework expected: Track 12 does not touch storage, DI, or bootstrap.
- The order rule in `docs/index.md` remains in force for subsequent tracks —
  this ADR changes the dependency for Track 12 only.

## Related

- `docs/index.md` — track order rule and Track 05 / 10 / 12 statuses
- Stitch 016 §39 — "This screen depends on the Track 12 implementation"