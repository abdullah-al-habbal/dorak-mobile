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

## Phase I — Track 18 / Discovery 016 (CL-09) ✅ 2026-09-02

- [x] I1: `ApiClient.getRawPaginated` — parsed `PaginatedData<T>` plus raw wire
      items/meta for `FeedCache` writes; `getPaginated` shares the parse path.
- [x] I2: `ExploreRepository.getBranchesPayload` (parsed + raw); abstract+impl
      merged into `explore.repository.dart` per AGENTS §4; `page` param added
      for load-more.
- [x] I3: `DiscoveryBloc` + event/state/filter entity — location-gated first
      load (no auto-permission on mount), `FeedCache` read with stale label +
      revalidation, offline keeps cached items stale, universe/filter change
      evicts + reloads, load-more appends, pull-to-refresh revalidates.
- [x] I4: `DiscoveryScreen` + `DiscoveryFilterBar` (universe segmented,
      available-now switch, price range, rating slider) +
      `DiscoveryResultCard` (rank/compat/distance badges, Book Now, optional
      View Details) — all strings ARB (`discover*`, 128 keys EN+AR).
- [x] I5: Wiring — `DorakApp` builds `DiscoveryBloc`
      (`DioExploreRepository` + `GeolocatorLocationProvider` + `SharedFeedCache`
      from `main.dart`, nullable seam for tests); Discover tab renders the feed;
      guest Book Now raises `RequireAuthentication`; tab label `discoverTabLabel`.
- [x] I6: Tests — 15 `discovery_bloc_test.dart` cases +
      `FakeExploreRepository`/`FakeLocationProvider`/`FakeFeedCache`/
      `testPosition`/`testBranch`/`testBranchPage` in `fakes.dart`;
      `buildRouter` takes `discovery`; flow tests assert the feed screen.
- [x] I7: `dart run melos run verify` — **exit 0, 188 tests** (core 88,
      client_app 82, design_system 14, 1×4), 128 ARB keys (EN+AR parity).

## Phase J — Track 17 / Authenticated password change ✅ 2026-09-02

- [x] J1: `AuthRepository.changePassword` — `PATCH /client/password` with
      `current_password` + `password` + `password_confirmation` (Laravel
      `confirmed` rule, same as register); `_discardBody` parser (no `data`).
- [x] J2: `ChangePasswordBloc` + event/state (app layer, auth feature —
      same shape as `PasswordRecoveryBloc`).
- [x] J3: `ChangePasswordScreen` + `ChangePasswordContent` — `AuthShell`,
      three `AuthTextField`s, `AuthValidators`, `AuthError.from` with 422
      field errors joined in the banner, success `StatusView` with Done pop.
- [x] J4: Wiring — Profile tab entry button, `/profile/password` nested route,
      `DorakApp` builds the bloc, `buildRouter` takes `passwordChange`.
- [x] J5: Tests — 2 core repo tests (body + PATCH verb, 422 field errors),
      3 bloc tests, 3 flow tests (entry → success → Done, mismatch blocks,
      wrong-current shows server copy).
- [x] J6: ARB — 9 `changePassword*` keys EN+AR (137 keys, parity verified).
- [x] J7: `dart run melos run verify` — **exit 0, 196 tests** (core 90,
      client_app 88, design_system 14, 1×4).

## Phase K — Stitch 017a / My Bookings (CL-10) ✅ 2026-09-02

- [x] K1: `BookingEndpoints` (bookings, bookingDetail, cancelBooking) +
      `BookingRepository`/`DioBookingRepository` — status/page/per_page list,
      cancel POST, `{booking}` substitution.
- [x] K2: `BookingDto` + `BookingChairDto`/`BookingBarberDto`/
      `BookingServiceDto` (codegen, `createToJson: false`, tolerant nulls).
- [x] K3: `BookingBloc` + event/state over `Paged<BookingDto>` — upcoming/past
      filter, refresh, load-more, cancel-then-reload, per-card spinner,
      keep-items-on-refresh-failure with error banner.
- [x] K4: `BookingsScreen` (filter extracted so it renders in the empty state
      too) + `BookingCard` (intl locale-aware time, status badge, barber/
      chair/services) + cancel confirmation `AlertDialog`; `bookingsTabLabel`.
- [x] K5: Wiring — `DorakApp` builds the bloc, Bookings tab renders the list,
      `buildRouter` takes `bookings`; `intl ^0.20.0` app dep for dates.
- [x] K6: Tests — 4 core repo tests, 9 bloc tests, 5 flow tests (list, past
      filter, confirm-cancel reload, dialog dismiss, retry-after-offline).
- [x] K7: ARB — 12 `booking*` keys EN+AR (149 keys, parity verified).
- [x] K8: `dart run melos run verify` — **exit 0, 214 tests** (core 94,
      client_app 102, design_system 14, 1×4).

## Phase L — Stitch 017b / Branch floor-plan detail + booking creation (CL-10) ✅ 2026-09-02

- [x] L1: Recon — `GET /branches/{branch}/floor-plan` (shared, ChairResource
      with status available|occupied|maintenance), `GET
      /explore/branches/{branch}` (detail + barbers + services + chairs_count),
      `POST /bookings` (chair_id `required_without`/`prohibits`
      at_home_location, 201 → BookingResource, 409 on
      `chair_not_available`/`double_booking`).
- [x] L2: Core — `BranchEndpoints` + `BranchRepository.getFloorPlan`;
      `ExploreRepository.getBranchDetail`; `BookingRepository.createBooking`
      (slot `yyyy-MM-dd HH:mm:ss` UTC); DTOs `BranchDetailDto`/`FloorPlanDto`/
      `FloorChairDto` (codegen); barrel exports.
- [x] L3: ARB — 14 `branch*`/`booking*` keys EN+AR (`branchChairsCount`
      placeholder, plan labels, select chair/services/time, confirm, success,
      view-my-bookings, conflict) — **163 keys, parity verified**.
- [x] L4: `BranchDetailBloc` + event/state — parallel detail + plan load
      (plan-failure tolerated), chair/services/time selection, submit guard
      `canSubmit` (chair + time), barber from chair, 409 conflict mapping,
      retry.
- [x] L5: `BranchDetailScreen` + `FloorPlanGrid` widget — legend, tappable
      available chairs, services checklist, date + time pickers, confirm
      `PrimaryButton`, success `StatusView`; `/discover/branch/:branchId`
      nested route + View Details wiring; DorakApp DI + `buildRouter`
      `branchDetail` fakes.
- [x] L6: Tests — 4 core tests (floor plan, branch detail, createBooking
      format + 409), 8 bloc tests (load, failure tolerance, selection, submit
      guard + conflict). Client_app 110 tests.
- [x] L7: `dart run melos run verify` — **exit 0, 226 tests** (core 98,
      client_app 110, design_system 14, 1×4).

**Next: AI Style (018) / Stylist Profile (019) / Review (020) —
see `docs/index.md` §6.**

## Track 10 completion record

- No source, test, or ARB change this pass — lifecycle code + 5 tests already
  shipped (see `docs/runtime/app_lifecycle.md` evidence).
- `docs/runtime/` previously a never-existing directory per `AGENTS.md` §1; now
  holds its first content file. Update that note → done in this commit.

## Not built — do not assume these exist

Stitch 010 (Profile Completion), 018 AI Style, 019 Stylist Profile, 020 Review.
016 Discovery and 017 Booking are built.
`business_app`/`stylist_app` are skeletons.
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