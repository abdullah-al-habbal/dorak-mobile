# Discovery Feed — Scope for Stitch 016

Status: `SCOPED` (2026-09-02, read-only pass). Not implemented — this is the
spec that unblocks **Track 05** (cache has a concrete consumer) and **Track 11**
(nav destinations defined), then drives **Track 18 / CL-09** (the Discovery
feature itself).

Source of truth order (from the Stitch plan §64):
`backend contract → existing architecture → product → plan.md → screen.png → code.html`.

## 1. Backend contract (authoritative — read from `dorak-backend`, not invented)

| Route | Query contract |
|---|---|
| `GET /api/v1/explore/branches` | **Required**: `latitude` (−90..90), `longitude` (−180..180), `radius` (≥0), `universe` (`men\|women`). **Optional**: `per_page` (1–100, default 20), `catalog_item_ids[]` (`exists:service_catalog_items`), `available_now`, `price_range[min,max]` (array), `rating_min` (0–5), `face_shape_compatible`. Guest-accessible (`clientId` nullable). Result **fixed-ordered by distance**, adds `compatibility_score` + `rank` per branch |
| `GET /api/v1/explore/barbers` | Same filters **minus `universe`**. No documented response shape for barber items (no Shared BarberResource found) |
| `GET /api/v1/explore/branches/{branch}` | Detail — resolver returns a plain array; resource shape must be verified at implementation time |
| `GET /api/v1/explore/barbers/{barber}` | Same |
| **Favorites** | **Does not exist.** No favorite route, no favorite module, no favorite column — `rg favorite` across `modules/` is empty |

### BranchResource item fields (the list response)

`id`, `name`, `email`, `status`, `latitude`, `longitude`, `brand_id`,
`distance`, `compatibility_score`, `rank`, `created_at`.

**What it does NOT carry:** image/logo, rating, services/tags, price,
availability (chairs/wait), sponsored flag, favorite flag. `distance` is
server-computed in km (haversine, via the resolver).  **No search `q` param.**

### Pagination envelope

`meta.pagination.{total, count, per_page, current_page, total_pages}` — **this
matches the client exactly**: `ApiClient.getPaginated` reads
`rawMeta['pagination']` (api.client.dart:142–147) and `Paged<T>.hasMore` uses
`currentPage < totalPages` (paged.entity.dart:30). Feed hits the wire
contract-first with existing core. Pagination failure mode at first page → same
contract as every other envelope endpoint.

## 2. Stitch ↔ contract coverage matrix

| Stitch element | Representable today | Decision for V1 |
|---|---|---|
| Search "salons, services" | No `q` param on either explore endpoint | **Deferred.** No fake client-side full-text search over loaded pages. Record as product/backend decision |
| Men's / Women's switcher | Yes — `universe` is **required** query param, enum `men\|women` | **Universe = a discovery filter, NOT a theme/tenant switch.** Switching re-queries. Version text + sidebar stay out (mobile-only app) |
| Card image | No field | Placeholder (shared `DorakImages`-style fallback belongs to design_system only if reused; otherwise feature-local) |
| Rating (4.9 etc.) | No field (filter exists server-side only) | Not displayed. **Backend gap:** a branch `rating` (avg) is already computed for `rating_min` — surface it in `BranchResource` (backend change, out of 016's contract) |
| Distance (1.2 km) | Yes (km, string-able) | Format device-locale; keep raw km in entity for sorting/labels |
| Favorite heart | **No route anywhere** | **Product decision: ship WITHOUT favorite.** Backend favorites module is its own work packet. Do not fake a local-only toggle the backend will contradict |
| Availability "2 Chairs / Busy" | No field; only `status` + the `available_now` filter | Render `available now` chip only when the filter is active; no fake operational text |
| Sponsored badge | No field | Not rendered. Data-driven only when backend adds it |
| Service tags | No field | Not rendered |
| Price display | No field | Price **filter** works server-side; price **display** does not (no field). Keep the filter; no display |
| "Ranked by Distance" | True — `orderBy('distance')` | Label is truthful; show it |
| Book Now | Booking feature = Stitch 017, not built | `authentication_required` for guests; destination missing for both → placeholder action, recorded dependency |
| View Map | No map infrastructure anywhere (no location pkg in workspace; `feature_floor_plan` is an empty stub) | Not rendered in V1. Recorded dependency (Track 13/14) |
| Top bar language + account | Locale-switcher exists; account/profile screen doesn't | Language → existing `LocaleSwitcher`. Account → profile destination (below) |
| 4-tab bottom nav | Nothing | See §3 |

## 3. Navigation — the four-tab shell (unblocks Track 11)

Stitch destinations: **Discover · Bookings · Favorites · Profile**. Today
`client_app` has only `/` splash, `/onboarding*`, `/auth*`, `/home`
(app_routes.entity.dart). Resolution for the shell:

- Discover = the real `HomeScreen` replacement. Discovery **is** Home — do not
  keep a second "home" concept (Stitch plan §6).
- Bookings / Favorites / Profile = **placeholder screens** in V1, same pattern
  as today's Home placeholder, until Stitch 017 (booking), the favorites work
  packet, and 010/019 (profile) land.
- Shape: `StatefulShellRoute` bottom-nav shell (Track 11's objective). This is
  precisely the destination list Track 11 needs to stop being blocked.
- Desktop sidebar: **out of scope** — client app is mobile; documented as
  future (Stitch plan §12).

## 4. Location — the hard prerequisite

`/explore/branches` **requires** `latitude`, `longitude`, `radius`. There is no
location package in the workspace and no permission plumbing.

V1 default: introduce a `LocationProvider` seam (a `geolocator` wrapper) under
the **Track 13/14** infrastructure umbrella, consumed by Discovery. Behavior:

1. Permission `granted` → read position → `ExploreBranchesQuery`.
2. Permission `denied`/`restricted`/service-off → **no silent fake coords.**
   Show a localized location-required state with "enable location" retry
   (Track 12 pattern). The feed must not request permission automatically on
   mount (Stitch plan §22) — a single "Enable location to explore" affordance
   triggers it.
3. A fixed-coordinate fallback for tests/emulators lives behind the seam, never
   in production config.

## 5. Cache — the Track 05 consumer contract

Discovery is Track 05's first concrete consumer. V1 cache scope (to be built in
Track 05, consumed here):

- Key = `explore/branches` + `universe` + rounded `lat/long` + `radius` bucket
  (+ `per_page`), so distance-ranked neighborhoods cache without unbounded
  combinatorial keys.
- Store = last loaded page set (older pages kept for back-scroll) — enough to
  render the feed from cache on a cold start / offline retry, labelled stale.
- **No fake offline expressiveness:** cached results are real results from a
  real response, not fabricated "offline data".
- Invalidation: universe switch and explicit filter change re-query and bump the
  cache; pull-to-refresh revalidates.

This gives Track 05 a real consumer and a bounded model; without it the cache
track repeats the pagination-notifiers mistake.

## 6. Feature shape (Track 18 implementation target)

```
packages/core                                    ← wire contract lives here
  endpoints/explore.endpoints.dart               ExploreEndpoints (4 route constants)
  repositories/explore.repository.dart           ExploreRepository + DioExploreRepository
  dto/branch.dto.dart                            BranchDto (snake_case, json_serializable)
  dto/explore_query.entity.dart                  typed query builder (lat/long/radius/universe/filters)
apps/client_app/lib/src/features/discovery/
  discovery.screen.dart                          Feed + top bar + universe switch (mobile)
  discovery_bloc.dart (+ event/state)            Paged<T> state machine, filters as one value object
  discovery_filter.entity.dart                   {universe, availableNow, priceRange, ratingMin}
  widgets/discovery_result_card.widget.dart      feature-local card (not design_system yet)
  widgets/discovery_filter_bar.widget.dart
```

Rules that already lock this in: `getPaginated` + `Paged<T>` for pagination
(nothing new), Bloc (no Riverpod/Provider/GetIt/ChangeNotifier), every string in
both ARBs (then `generate`), taxonomy suffixes, `design_system` only for
cross-feature reuse. `ExploreRepository` placement follows `core` rule: new
domain → new `<domain>.endpoints.dart` + `<domain>.repository.dart`.

## 7. Global UI states (Track 12 first consumer listed in AGENTS §7)

Discovery consumes `AppLoader`, `ShimmerBox`, `StatusView` (they "await
Discovery 016" today): initial loading → `AppLoader`; inline pagination →
`ShimmerBox`; empty/error/offline/retry → `StatusView`; guest protected actions
(Book Now) → `authenticationRequired` (exists in the session signal layer, no
second guest guard).

## 8. Recommended order

1. **Track 05** — cache strategy, targeting the §5 envelope. Small, now-has-a-
   consumer, and the exact "wait-for-consumer" condition that killed the
   pagination notifiers is satisfied throughout.
2. **Track 11** — the four-tab `StatefulShellRoute` with the §3 destination set.
   Placeholder screens keep it unblocked.
3. **Track 18 / CL-09** — the Discovery feature per §6, consuming both.
4. Parallel (backend, optional, product-owned): add `favorites` module; surface
   `rating` (+ possibly `image`, `services`, `price`) on the Branch/Barber
   resources; add a search-capable `q`/term param. Each is a separate packet —
   none blocks V1, which trims Stitch to what the contract honestly renders.

## 9. Acceptance (V1, trimmed honestly)

- [ ] Feed renders real `/explore/branches` data — no hardcoded Stitch demo rows
- [ ] Universe switcher, `available_now`, `price_range`, `rating_min` wired to
      the real query params; "Ranked by Distance" label shown
- [ ] `Paged<T>` infinite scroll + first-page empty/error/retry + pull-to-refresh
- [ ] Location-required state, no silent fake coords, no auto-permission on mount
- [ ] Guest browse; guest Book Now → `authenticationRequired`
- [ ] Favorites/Map/search/rating/services/sponsored explicitly absent-by-contract,
      recorded in feature-index as backend gaps — not faked
- [ ] EN + AR keys, RTL-safe cards/filter bar, a11y semantics
- [ ] Cache from Track 05: stored pages render on offline retry, labelled stale
- [ ] `dart run melos run verify` exit 0