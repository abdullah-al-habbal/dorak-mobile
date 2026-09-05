# Actionable Plan — Mobile

> Repo entry doc. Read `../AGENTS.md` → `CLAUDE.md` → `docs/index.md` first.
> Updated 2026-09-02 — Track 10 done, Discovery scoped. Branch `main`.

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

## Phase D — Discovery 016 scoping ✅ SCOPED 2026-09-02 (read-only)

- [x] D1: Read Stitch export `docs/stitch/exports/016_discovery_feed/plan.md`.
- [x] D2: Read the real backend `modules/Explore` contract: 4 routes,
      `ExploreBranchesRequest` (required lat/long/radius/universe `men|women`;
      optional `available_now`, `price_range[min,max]`, `rating_min`,
      `catalog_item_ids[]`, `face_shape_compatible`, `per_page≤100`),
      `BranchResource` fields, `ApiResponseTrait::paginated` meta shape.
- [x] D3: Verified contract alignment — mobile `getPaginated` reads
      `meta.pagination.{total,count,per_page,current_page,total_pages}`; backend
      emits exactly that → feed paginates on existing core, nothing new.
- [x] D4: Recorded gaps/decisions: **favorites don't exist in the backend at
      all** (ship without, product decision); no search `q`; BranchResource
      lacks image/rating/services/price/availability/sponsored; no location
      package → `LocationProvider` seam (Track 13/14); 4-tab shell destination
      list for Track 11 (Discover + 3 placeholders).
- [x] D5: Wrote `docs/future-features/discovery-016.md` — the spec:
      contract table, stitch↔contract coverage matrix, nav shell, location
      rule, **Track 05 feed-cache consumer envelope** (§5), Track 18 feature
      shape, acceptance list. This is the single source the next two tracks
      read.

**Next: Track 05 — Storage (cache strategy), target = discovery-016 §5.**

## Phase E — Track 05 (cache strategy) ✅ DONE 2026-09-02

- [x] E1: `FeedCache` abstract + `SharedFeedCache` in
      `packages/core/lib/src/storage/feed_cache.storage.dart` — raw-wire-payload
      feed cache (item maps + pagination meta), bounded keys (universe +
      lat/long 3-dp + 5 km radius bucket + per_page), explicit `evict`/`clear`.
- [x] E2: `FeedCacheEntry` value object + `feedCacheTtl` (30 min) — read-time
      staleness (`isStale`), store never refuses to return (consumer decides:
      offline → stale render, refresh → revalidate).
- [x] E3: Exported via `storage.barrel.dart`.
- [x] E4: 11 tests in `packages/core/test/feed_cache_test.dart` — same-
      neighbourhood keys share; universe/radius/per_page split; far coords
      differ; round-trip preserves items+meta+storedAt; evict single key;
      clear-all; staleness vs injected clock; corrupt payload → null.
- [x] E5: Docs — `core/AGENTS.md` (§1/§6/§9), `docs/core/storage.md`,
      `docs/index.md` Track 05 → DONE + §6, mobile `AGENTS.md` (§5/§6/§7/§12).
- [x] E6: `dart run melos run verify` — **exit 0, 168 tests** (core 72 → 83).

**Next: Track 11 — Navigation (four-tab `StatefulShellRoute`; destinations per
discovery-016 §3: Discover replaces Home, Bookings/Favorites/Profile =
placeholders).**

## Phase F — Track 11 UI placeholders ✅ 2026-09-02

- [x] F1: `BookingsScreen` + `_BookingsView` in
      `apps/client_app/lib/src/features/booking/bookings.screen.dart` — uses
      `StatusView` with empty state, localized strings, `Discover` action
      navigates to tab 0.
- [x] F2: `FavoritesScreen` + `_FavoritesView` in
      `apps/client_app/lib/src/features/profile/favorites.screen.dart` — same
      pattern, `favorite_border_outlined` icon.
- [x] F3: Added 6 ARB keys to `app_en.arb` + `app_ar.arb`:
      `bookingsTitle`, `bookingsSubtitle`, `bookingsActionLabel`,
      `favoritesTitle`, `favoritesSubtitle`, `favoritesActionLabel`.
- [x] F4: `dart run melos run generate` — regenerated `AppLocalizations`.
- [x] F5: `dart run melos run verify` — **exit 0, 170 tests** (core 83, client_app
      67, design_system 14, 1 each other).

## Phase G — Track 11 Navigation wiring ✅ 2026-09-02

- [x] G1: `StatefulShellRoute.indexedStack` with 4 branches (Discover,
      Bookings, Favorites, Profile) in `app.router.dart`.
- [x] G2: `_MainShell` widget with `NavigationBar` — localized labels, active
      icons, `Discover` action navigates to tab 0.
- [x] G3: `ProfileScreen` + `_ProfileView` placeholder (empty state via
      `StatusView`), 3 ARB keys (`profileTitle/Subtitle/ActionLabel`).
- [x] G4: `AppGate.resolve` routes authenticated users + guests who completed
      onboarding to `/discover` (shell entry). Legacy `/home` redirects to
      `/discover`.
- [x] G5: `SessionSignal.sessionExpired` correctly redirects to `AuthEntry`
      (not Discover) — verified by `session_expired_test.dart`.
- [x] G6: `dart run melos run verify` — **exit 0, 170 tests** (core 83, client_app
      67, design_system 14, 1×4), 114 ARB keys (EN+AR).

## Phase H — Track 18 prep (core infra) ✅ 2026-09-02

- [x] H1: `LocationProvider` + `GeolocatorLocationProvider` in
      `packages/core/lib/src/location/` — `ensurePermission()`, `getCurrentPosition()`,
      `permissionChanges()`.
- [x] H2: `LocationPermissionStatus` enum (`granted`, `denied`, `restricted`,
      `serviceDisabled`).
- [x] H3: `ExploreEndpoints` (branches, barbers, branchDetail, barberDetail).
- [x] H4: `ExploreRepository` + `DioExploreRepository` — `getBranches()` with
      all query params (lat/long/radius/universe/filters/pagination).
- [x] H5: `BranchDto` — JSON-serializable wire model matching `BranchResource`.
- [x] H6: `FeedCache`/`SharedFeedCache` (Track 05) — raw-wire-payload cache with
      bounded keys, read-time staleness, explicit eviction.
- [x] H7: `melos run verify` — **exit 0, 170 tests** (core 83, client_app 67,
      design_system 14, 1×4).

**Next: Track 18 / Discovery (CL-09) — build Discovery screen/Bloc/widgets on
completed core infra.**

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