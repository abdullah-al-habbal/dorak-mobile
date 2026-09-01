# Actionable Plan — Mobile

> Repo entry doc. Read `../AGENTS.md` → `CLAUDE.md` → `docs/index.md` first.
> Updated 2026-09-02 — Track 10 done. Branch `main`.

## Phase C — Re-baseline + pick next work ✅ BASELINED 2026-09-02

- [x] C1: `dart run melos run verify` — **exit 0**: 7 packages analyze clean,
      taxonomy passed, **157 tests** = core 72, client_app 67, design_system 14,
      business_app/stylist_app/localization/feature_floor_plan 1 each.
- [x] C2: `AGENTS.md` updated — §5 baseline (157), §11 ARB keys (102, verified),
      §12 test table (157 with per-unit split)
- [x] C3: `docs/index.md` updated — §6 evidence ×3 (144 → 157), Track 06
      evidence (63/27 → 72/67)
- [x] C4: **Next track decided: Track 10 — Dependency Injection & Bootstrap**.
      Rationale: application lifecycle is its last objective; self-contained;
      unblocks Discovery 016. Track 05 cache deferred (no consumer). Track 11
      still blocked (3 of 4 nav destinations missing).
- [x] C5: **Track 10 done 2026-09-02.** Lifecycle objective was already
      implemented + tested (resume `RestoreRequested` probe in `_DorakAppState`);
      missing deliverable was its doc. Wrote `docs/runtime/app_lifecycle.md`
      (mechanism, guards, event-coverage table, 5-test evidence), closed
      `docs/index.md` §6 Track 10 + current-execution-point (dependency
      registration `PARTIAL`-by-design, a recorded decision not a debt item).
      `melos run verify` exit 0 before Done.

## Track 10 completion record

- No source, test, or ARB change this pass — lifecycle code + 5 tests already
  shipped (see `docs/runtime/app_lifecycle.md` evidence).
- `docs/runtime/` previously a never-existing directory per `AGENTS.md` §1; now
  holds its first content file. Update that note → done in this commit.

## Not built — do not assume these exist

Stitch 010 (Profile Completion), 016 Discovery, 017 Booking, 018 AI Style,
019 Stylist Profile, 020 Review. `business_app`/`stylist_app` are skeletons.
Design-system inputs/cards/chips/dialogs/app bars (Track 15) — only the 14
widgets in `AGENTS.md` §10 exist.

## Verification (each task)

```bash
dart run melos run verify   # generate → build → analyze → taxonomy → test
```

After ARB edit: `generate`. After DTO edit: `build`.

## Links

- `docs/index.md` — track status, current execution point
- `docs/feature-index.md` — feature registry, backend routes for unbuilt work
- `../.claude/skills/stitch-flutter-converter/SKILL.md` — Stitch→Flutter rules