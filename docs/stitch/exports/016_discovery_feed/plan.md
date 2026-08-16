# Stitch 016 — Discovery Feed

## 1. Screen Identity

* Stitch export: `016_discovery_feed`
* Screen: Discovery Home Feed
* Feature: Client Discovery
* Client app: `apps/client_app`
* Track: `Track 18 — Feature Modules`
* Feature registry: `CL-09`
* Current repository state: not implemented
* Previous product destination: Home placeholder
* Primary purpose: discover salons/services/stylists and enter booking/discovery flows

This is the first major post-authenticated product feature.

This screen is NOT a static UI-only migration.

It requires real application state, backend data, navigation, localization, loading, empty, error, pagination/refresh behavior, and likely location-aware ranking.

---

## 2. Source of Truth

### Visual source

```text
docs/stitch/exports/016_discovery_feed/screen.png
```

Use the screenshot for visual comparison.

The screenshot should be treated as the final visual reference for:

* spacing
* proportions
* card dimensions
* mobile layout
* desktop layout
* icon positioning
* typography hierarchy
* image treatment

### Layout source

```text
docs/stitch/exports/016_discovery_feed/code.html
```

Read the HTML for:

* layout hierarchy
* responsive behavior
* interactions
* visible states
* navigation intent
* demo content structure

Do not copy HTML or Tailwind classes into Flutter.

### Global design source

```text
packages/design_system
```

The export `DESIGN.md` is the global Dorak design reference.

Do not regenerate the design system from this export.

Use:

* `DorakColors`
* `DorakTypography`
* `DorakDimensions`
* `DorakTheme`
* existing shared widgets

---

## 3. Product Context

The discovery feed is the main client-facing browsing surface after authentication/guest access.

Conceptual flow:

```text
Home / Discovery
    ↓
Search / Filters
    ↓
Discovery results
    ↓
Salon / Branch / Stylist details
    ↓
Booking
```

Potential secondary flows:

```text
Discovery
   ├── View Map
   ├── Favorite
   ├── Profile
   ├── Booking
   └── Authentication Required
```

The exact destinations must be reconciled with the existing navigation architecture and current product backlog before implementation.

Do not invent routes simply because the Stitch HTML contains `<a href="#">`.

---

## 4. Major Stitch-to-Product Warning

The Stitch HTML contains demo data:

```text id="0kqg5v"
The Royal Barber
Elite Men's Salon
Damascus
Aleppo
4.9
4.7
1.2 km
2.5 km
2 Chairs Available
Busy - 15m wait
Sponsored
Haircut
Beard Trim
Hot Towel
Styling
Facial
```

These are illustrative data.

Do NOT hardcode them into production code as real entities.

The Flutter implementation must use real backend/domain models.

Demo content may only appear in:

* tests
* controlled fixtures
* development mocks

and must never become production static data.

---

## 5. Backend Contract Is Authoritative

Before implementation, inspect the real backend surface for discovery.

Inspect:

```text id="a6d0ey"
dorak-backend/
dorak-mobile/packages/core/lib/src/network/endpoints/
dorak-mobile/packages/core/lib/src/network/repositories/
dorak-mobile/packages/core/lib/src/network/dto/
```

Determine the existing API surface for:

* discovery
* salons/businesses
* branches
* stylists
* services
* ratings
* favorites
* distance
* availability
* promoted/sponsored results
* search
* filters
* pagination

Do not invent endpoints.

The repository rule remains:

```text id="6xj8qj"
No undocumented backend API
```

If the backend currently lacks an endpoint required by the design, document that as a blocker instead of inventing a client-side contract.

---

## 6. Current Home State

The current client app has:

```text
features/home/home.screen.dart
```

as a placeholder.

Before creating a completely separate top-level destination, inspect whether Discovery should:

* replace Home
* become the real Home screen
* become a dedicated Discovery route
* sit behind an authenticated/guest shell

The Stitch design clearly treats Discovery as a main navigation destination, but the existing app architecture currently has only a Home placeholder.

Resolve this deliberately before implementation.

Do not maintain two competing “home” concepts accidentally.

---

## 7. Guest Access

The product documentation says some discovery-related actions may be available to guests while booking/profile actions require authentication.

Therefore classify each interaction:

```text id="9w9t8j"
Public/Guest:
- browse discovery
- search
- filters
- view details
```

Potentially authenticated:

```text id="l4z6s5"
- favorite
- booking
- profile/account actions
```

The exact guest restrictions must come from:

```text id="2baj0b"
docs/flows/guest_access.md
```

and the current navigation/guard architecture.

Do not make every discovery interaction require authentication merely because the user is a guest.

Do not allow protected actions to fail with an arbitrary API 401 when the guard can handle the requirement earlier.

Use the Track 12 `authentication_required` behavior when appropriate.

---

## 8. Screen Architecture

Preferred structure:

```text id="m9dlk9"
DiscoveryScreen
    ↓
DiscoveryBloc / discovery_bloc.dart (Pure Bloc)
    ↓
DiscoveryRepository
    ↓
ApiClient
    ↓
Discovery DTOs
    ↓
backend
```

The exact bloc/repository structure must follow the project's canonical:

```text id="fxwf31"
Bloc + repository (flutter_bloc)
```

Do not introduce:

* Riverpod
* Provider
* GetIt
* `ChangeNotifier` state
* another state library

---

## 9. Expected Flutter Structure

Initial target:

```text id="3dls5r"
apps/client_app/lib/src/features/discovery/
├── discovery.screen.dart
├── discovery_bloc.dart        (+ discovery_event.dart / discovery_state.dart)
├── discovery.repository.dart
├── discovery.entity.dart
├── widgets/
│   ├── discovery_header.widget.dart
│   ├── discovery_search.widget.dart
│   ├── discovery_filter_bar.widget.dart
│   ├── discovery_result_card.widget.dart
│   ├── discovery_result_list.widget.dart
│   ├── discovery_universe_switcher.widget.dart
│   └── discovery_bottom_navigation.widget.dart
└── ...
```

This is a proposed structure, not a command to create every file.

The agent must inspect actual data requirements and create only the necessary files.

Respect the current taxonomy.

---

## 10. Repository / DTO Placement

Use the repository rules from the monorepo.

If the discovery API is client-specific and fits current package conventions, the contract/implementation should remain in the appropriate permitted location.

Do not add invalid feature-package repository/DTO files if `tool/check_taxonomy.dart` rejects them.

The current repository documentation explicitly says that feature packages have stricter taxonomy constraints.

Therefore verify the real permitted location before creating:

```text id="xnj8ap"
.discovery.repository.dart
.discovery.dto.dart
.discovery.entity.dart
.discovery_bloc.dart / .discovery_event.dart / .discovery_state.dart
```

`.notifier.dart` is not a target role — use Bloc roles.

Do not guess package placement.

---

## 11. Top App Bar

Stitch:

```text id="2k1gpm"
sticky top header
├── language button
├── centered Dorak brand
└── account/profile button
```

Mobile/desktop behavior must be reconciled with the actual app shell.

Language control should connect to the existing locale mechanism.

Important current limitation:

The repository documentation says locale persistence is not yet implemented.

Therefore:

* do not create a new persistence mechanism here
* use the existing locale architecture
* document any persistence limitation
* do not duplicate locale state locally inside Discovery

Profile/account action must use existing navigation and session rules.

If the user is a guest, follow guest-access behavior.

---

## 12. Desktop Sidebar

Stitch includes a desktop-only left sidebar with:

* profile image
* welcome text
* current universe
* version text
* Men's Grooming
* Women's Beauty

This is responsive UI, not a separate business application.

Do not interpret this as requiring the business_app.

The sidebar belongs to the client discovery experience if desktop/tablet support is actually in scope.

Before implementing it, inspect the actual supported Flutter platforms and current app responsiveness.

If the client app is mobile-only in the current release, document the desktop design as future/not active rather than adding unused desktop complexity.

---

## 13. Dual Universe Switcher

The Stitch screen contains:

```text
Men's
Women's
```

and the 015 design reference describes the Dual-Universe concept.

This is a design/product decision, not merely a visual toggle.

Before implementing, determine:

1. Is the universe stored as client state?
2. Does the backend expose universe/category filtering?
3. Does switching universe change API queries?
4. Does switching universe change theme colors?
5. Is this a true tenant/theme switch or merely a discovery category?

Do not automatically implement tenant-wide theming.

For the initial discovery implementation, the safest interpretation is:

```text id="3w1qz3"
Universe selector = discovery/category filter
```

unless the backend/product contract explicitly says it is a theme/tenant switch.

If the backend already defines a canonical universe enum, reuse it.

Do not create duplicate string values such as:

```text
"Men's"
"Women's"
```

throughout the code.

Use an enum/value object when appropriate.

---

## 14. Search

Stitch provides:

```text id="58peyk"
Search salons, services...
```

with a search icon and tuning/filter icon.

Required behavior should include:

* search input
* query state
* submit/search action
* clearing
* loading
* result refresh
* empty state
* error state

Do not assume every keystroke should call the backend.

Prefer deliberate debouncing or submit-based search according to the backend capabilities and product requirements.

Do not implement arbitrary client-side filtering over a small hardcoded list.

---

## 15. Search Input

The search field must:

* be accessible
* have localized placeholder
* use semantic colors
* support Arabic
* handle keyboard input properly
* preserve state across refresh where appropriate

Stitch placeholder:

```text
Search salons, services... / ابحث عن الصالونات، الخدمات...
```

Do not hardcode bilingual strings into one Flutter string.

The English and Arabic versions must come through localization.

The search icon and filter/tune action should have semantic labels.

---

## 16. Search Domain

The search may potentially search:

* salons
* branches
* services
* stylists

Do not assume the backend's search semantics.

Inspect the backend first.

If the backend exposes a single discovery search endpoint, use its contract.

If it exposes separate search domains, model the client accordingly.

Do not perform multiple unrelated API requests simply because the Stitch placeholder says "salons, services."

---

## 17. Filter Bar

Stitch filters:

```text id="ymr804"
Available Now
Price
Rating
Distance
```

The filter bar is horizontal and scrollable.

Each filter needs a real state.

Do not hardcode “selected” styling without corresponding filter state.

Potential filter model:

```text id="ebby4x"
DiscoveryFilters
├── availability
├── price
├── rating
├── distance
└── query
```

Use a value object/entity where appropriate.

Filter updates should trigger the repository/bloc appropriately.

---

## 18. Available Now

The Stitch design uses:

```text id="92l84d"
Available Now
```

This is likely a real availability filter.

Do not fake it based only on card status.

Inspect backend support.

If the backend cannot filter by current availability, document the limitation.

---

## 19. Price Filter

The Stitch filter opens a price interaction.

The current code only displays the trigger.

Do not assume the exact UI.

Before implementation determine:

* price range
* price tier
* minimum/maximum
* currency
* backend representation

If a bottom sheet/dialog is required, use an existing or properly scoped `.sheet.dart`.

Do not create a generic global filter architecture prematurely.

---

## 20. Rating Filter

Determine the actual backend representation.

Possible concepts:

* minimum rating
* rating bucket
* exact threshold

Use the backend contract.

Do not hardcode an arbitrary threshold.

---

## 21. Distance Filter

Determine:

* unit
* maximum radius
* whether user location is required
* whether location permission is required
* whether distance is computed client-side or backend-side

The Stitch design displays values such as:

```text
1.2 km
2.5 km
```

These are demonstration values.

Do not hardcode them.

---

## 22. Location / Permission

Discovery is distance-ranked and contains “View Map”.

This strongly suggests location may eventually be involved.

Do not automatically request location permission at screen launch.

First determine:

* whether backend supports a location query
* whether the app already has location infrastructure
* whether permission handling belongs to Track 13/14 or another foundation task
* whether discovery can operate without location

If location is unavailable:

```text id="qvq8qh"
fallback to non-location discovery
```

or another product-approved fallback.

Do not create an unplanned permission architecture inside Discovery.

---

## 23. Content Header

Stitch:

```text id="r6m4vb"
Ranked by Distance
View Map
```

The exact ranking text must reflect the actual query state.

If sorting is not distance-based because location is unavailable, the label should not falsely say “Ranked by Distance”.

Possible future modes:

* Ranked by Distance
* Recommended for You
* Highest Rated
* Nearest
* Available Now

Use backend/product state to determine the actual label.

Do not hardcode the Stitch label if it would lie about the current result ordering.

---

## 24. View Map

Stitch includes:

```text
View Map
```

This is a navigation/action, not decorative text.

The eventual implementation should connect to the approved map experience.

Do not invent a map implementation during this task if the app has no existing map infrastructure.

Inspect:

```text id="t56rwp"
feature_floor_plan
location-related packages
navigation architecture
```

and the product backlog.

If map infrastructure is not ready, document the dependency instead of pretending the action works.

---

## 25. Result Cards

Each discovery result card contains:

```text id="9hrv4u"
image
rating
name
favorite
location/distance
services/tags
availability status
primary action
optional sponsored badge
```

This must become a reusable feature-local card:

```text id="g8i1zr"
discovery_result_card.widget.dart
```

unless the card is proven reusable across multiple unrelated features.

Do not immediately move it to `design_system`.

---

## 26. Result Image

Stitch uses remote image URLs.

Production rule:

```text id="kjc9o3"
local asset / backend URL
        +
safe fallback
        +
errorBuilder
```

Do not hardcode the Stitch Google-hosted demo URLs.

Do not rely on them in production.

Use the existing asset/image conventions.

If the backend returns an image URL, the implementation must support it safely.

Avoid loading huge images without cache sizing.

---

## 27. Rating

Cards display:

```text
4.9
4.7
```

These values must come from the backend.

Display rating using:

* semantic star icon
* accessible text
* localized formatting if necessary

Do not assume the rating scale without checking the backend/product contract.

---

## 28. Favorites

Each result has:

```text
favorite_border
```

This is a real interaction.

Requirements:

```text id="l7pxwn"
not favorite
favorite
loading/update
failure rollback
```

Do not merely toggle a local boolean if the user's favorites are persisted by backend.

Inspect the existing favorite-related backend contract and the product documentation.

The user's existing favorite feature requirements should align with this screen.

If favorite infrastructure is not implemented yet, this screen may be blocked on the relevant backend/client work.

---

## 29. Sponsored Results

Stitch displays:

```text id="7z5c7q"
Sponsored
```

This must be data-driven.

Do not mark arbitrary results as sponsored.

The backend should identify promoted/sponsored results.

If no backend support exists, implement the UI capability only if the product contract already requires it, otherwise document it as pending.

---

## 30. Service Tags

Examples:

```text id="y8aj8n"
Haircut
Beard Trim
Hot Towel
Styling
Facial
```

These are dynamic data.

Do not hardcode tags.

Limit the number rendered according to the actual API/presentation requirements.

Consider overflow behavior for many services.

All service names require localization/data handling according to where the backend sources them from.

Do not translate backend user-defined content as though it were static ARB copy unless the backend provides localized values.

---

## 31. Availability Status

Examples:

```text id="l7n2da"
2 Chairs Available
Busy - 15m wait
```

These are dynamic operational states.

Do not hardcode.

Represent availability using a domain model rather than raw strings.

Potential semantic state:

```text id="0zq9bx"
available
busy
unavailable
```

The exact backend state must be discovered before implementation.

The visual status indicator must not rely only on green/red.

Use text/icon plus color.

---

## 32. Book Now

Stitch shows:

```text id="5qhynj"
Book Now
```

This is a protected action.

Guest:

```text
Book Now
   ↓
authentication_required
```

Authenticated:

```text
Book Now
   ↓
booking flow
```

Use the existing Guest Access rules and Track 12 auth-required infrastructure.

Do not bypass guards by letting a guest make a request and waiting for 401.

---

## 33. View Details

For cards without a direct booking action, Stitch uses:

```text id="2pnfbb"
View Details
```

This should navigate to the appropriate salon/branch/stylist detail flow.

The destination must be established from:

* PRD
* backend routes
* existing navigation rules

Do not invent a screen if the destination does not exist yet.

If the destination is part of a future feature, record the dependency.

---

## 34. Favorites / Profile Navigation

Top profile icon and bottom Profile destination should respect:

```text id="kkr1nc"
authenticated user
guest user
```

Guest profile action should use the existing authentication-required behavior.

Do not implement a second guest guard.

---

## 35. Mobile Bottom Navigation

Stitch shows:

```text id="v6f8sm"
Discover
Bookings
Favorites
Profile
```

with Discover active.

This is an important navigation architecture decision.

Before implementing:

1. Inspect existing navigation files (`app.router.dart`).
2. Determine whether a root authenticated shell already exists.
3. Determine how main destinations should be represented with go_router.
4. Avoid creating nested navigation architecture unless actually needed.

The bottom navigation must not be hardcoded inside the Discovery feature if it is a shared app shell.

If it is shared across multiple authenticated pages, place it at the appropriate app-shell/navigation layer.

---

## 36. Desktop Navigation

The Stitch design instead uses a desktop sidebar.

The responsive navigation architecture should therefore be:

```text id="rw5j1n"
mobile
  → bottom navigation

desktop/tablet
  → sidebar
```

Only implement desktop shell behavior if supported by the current app requirements.

Do not introduce a second app shell architecture just for 016.

---

## 37. Pagination

Discovery feeds commonly require pagination.

The repository already documents pagination infrastructure.

Inspect:

```text id="3tct51"
docs/state_management/pagination.md
```

The legacy pagination `ChangeNotifier`s were **deleted** — implement feed
pagination in the `DiscoveryBloc` (or a dedicated pagination bloc) instead.
Reuse the fetch contract they used to encode: `ApiClient.getPaginated` +
`PaginatedData<T>` + `PaginationMeta`.

Preferred behavior:

```text id="h7thjp"
initial load
   ↓
results
   ↓
scroll
   ↓
fetch next page
   ↓
append
```

Handle:

* initial loading
* next-page loading
* last page
* retry page
* empty first page
* error first page

Do not duplicate pagination abstractions already present.

---

## 38. Pull to Refresh

The discovery feed should support refresh if consistent with the existing pagination/state conventions.

Do not blindly reload everything through a new state system.

Use the canonical bloc refresh behavior if available.

---

## 39. Global UI States

This screen must integrate with Track 12.

Required states:

```text id="3lm7my"
Initial loading
Content
Empty
Inline pagination loading
Error
Retry
Offline
Authentication required
```

Do not hand-roll separate versions of global loading/error widgets if Track 12/15 provides shared components by the time Discovery is implemented.

---

## 40. Empty State

Possible scenario:

```text id="jyj6mi"
No discovery results
```

The empty state must:

* be localized
* explain what happened
* provide a useful next action when possible
* not look like an error

Do not use a random illustration unless already available/approved.

---

## 41. Error State

For discovery request failures:

* use global error conventions
* provide retry
* do not display raw API messages
* preserve current filter/search state where practical

Do not crash the screen on failed pagination.

---

## 42. Offline State

If the backend cannot be reached:

* show the appropriate global offline/error representation
* preserve entered search/filter state
* allow retry

Do not invent offline discovery data unless a real cache exists.

This interacts with Track 05 cache strategy.

If cache is not implemented, do not claim offline discovery is supported.

---

## 43. Performance

Discovery may contain many images/cards.

Requirements:

* lazy list/grid rendering
* image caching
* bounded image dimensions
* pagination
* avoid rebuilding entire feed unnecessarily
* do not load all pages at once
* avoid nested unbounded scrollables

On mobile, prefer a lazy scrollable result layout.

On desktop, use a responsive grid only where appropriate.

---

## 44. Data Model

Do not use UI-only map structures such as:

```text
Map<String, dynamic>
```

throughout the feature.

Create typed domain models/entities and DTOs according to repository rules.

Potential conceptual model:

```text id="k6fr9o"
DiscoveryResult
├── id
├── name
├── type
├── image
├── rating
├── distance
├── location
├── services
├── availability
├── sponsored
└── favorite
```

The exact fields must come from the backend.

Do not implement this exact model blindly.

---

## 45. Filtering State

Represent filters as structured state rather than many independent booleans.

Conceptually:

```text id="idp1mj"
DiscoveryFilters
├── query
├── universe/category
├── availability
├── price
├── rating
├── distance
└── sort
```

Use an immutable value object/entity if appropriate.

---

## 46. State Management

Use the canonical:

```text id="fxl37s"
Bloc
+
repository
```

(flutter_bloc — see the locked architecture; `ChangeNotifier` is not a target
pattern.)

Expected state categories:

```text id="c1ga1i"
initial
loading
loaded
empty
refreshing
loadingMore
error
```

Do not introduce a third-party state package.

---

## 47. Localization

Every static user-visible string must come from localization.

Likely concepts include:

```text id="j3wpaf"
discover
bookings
favorites
profile
welcomeToDorak
discoverLuxuryBeauty
mensGrooming
womensBeauty
searchSalonsAndServices
availableNow
price
rating
distance
rankedByDistance
viewMap
sponsored
bookNow
viewDetails
chairsAvailable
busyWait
noResults
retry
```

Do not create all keys blindly.

Inspect existing ARB keys first and reuse where possible.

Dynamic backend data must not automatically become ARB keys.

All new static strings must exist in:

```text id="a2s0sp"
app_en.arb
app_ar.arb
```

---

## 48. Arabic / RTL

Discovery must be fully RTL-safe.

Use:

* `TextAlign.start`
* `AlignmentDirectional`
* `EdgeInsetsDirectional`
* directional icons
* RTL-safe card layout
* horizontally scrollable filters that behave correctly in Arabic

Search text and filter controls must remain usable in Arabic.

Do not concatenate English and Arabic strings inside the same hardcoded UI string.

---

## 49. Accessibility

Required:

* semantic labels for search
* semantic labels for language/account buttons
* semantic labels for favorite action
* accessible result-card actions
* clear status information
* touch targets large enough for interaction
* screen-reader-friendly filter controls
* status not communicated by color alone

A result card must not be one giant inaccessible gesture target if it contains several independent actions.

---

## 50. Assets

The Stitch HTML uses external Google-hosted images.

Do not copy those URLs into production.

Use:

* backend image URLs where provided
* safe loading state
* fallback placeholder
* `errorBuilder`
* cache sizing

Do not add the remote demo URLs as permanent assets.

---

## 51. Authentication

Discovery itself may be accessible in guest mode.

Protected actions must use:

```text id="u5o73z"
authentication_required
```

rather than allowing unauthorized API requests to happen first.

This screen therefore depends on the Track 12 implementation.

Do not implement an ad-hoc login modal.

Use the established authentication-entry/navigation behavior.

---

## 52. Favorites Authentication

For favorite actions:

```text id="8emg4m"
Guest
  ↓
authentication_required

Authenticated
  ↓
favorite repository operation
```

When an authenticated favorite update fails:

* show appropriate error
* rollback optimistic state if used
* do not leave UI falsely marked

Use repository-driven state.

---

## 53. Search / Filter URL or Deep Link

Do not implement deep-link support during 016 unless Track 11 has already delivered the required infrastructure.

However, design the feature state so that query/filter state can later be represented in a route/deep-link model without major rewrites.

Do not introduce deep links ad hoc.

---

## 54. Map Dependency

`View Map` is potentially dependent on future map/location infrastructure.

Before implementation:

```text id="lmxutr"
Inspect existing location/map capabilities.
```

If absent:

```text id="w0tz3a"
document dependency
```

rather than introducing an unrelated map SDK or architecture.

---

## 55. Design-System Components

Potential reusable components should be evaluated under Track 15.

Candidates:

* search field
* filter chip
* result card
* navigation bar
* app bar
* status indicator
* rating display
* avatar/image
* loading/empty/error state

But do not automatically put all of them into `packages/design_system`.

Rule:

```text id="8yp2gq"
shared across apps/features
    → design_system

discovery-specific
    → client_app/features/discovery
```

---

## 56. Navigation Dependencies

Before implementation, inspect:

```text id="q3x9r9"
app.router.dart
app_routes.entity.dart
app_gate.entity.dart
existing navigation routes/docs
guest_access.md
```

Determine destinations for:

```text id="s0xr6n"
Profile
Favorites
Bookings
Salon/Branch Details
Stylist Profile
Booking
Map
Authentication
```

Do not invent screens for destinations not yet implemented.

Explicitly document blockers where needed.

---

## 57. Feature Dependencies

016 may depend on:

```text id="0d8cws"
Track 09 — State Management
Track 11 — Navigation
Track 12 — Global UI States
Track 15 — Shared Design Components
Track 13/14 — location/map/file/notification infrastructure where applicable
```

The agent must not silently implement unfinished foundation tracks inside the Discovery feature.

When a missing foundation capability is discovered, document it.

Do not bypass the architecture.

---

## 58. Testing

### State tests

Cover:

```text id="f0qf2x"
initial load success
initial load empty
initial load error
retry
refresh
pagination success
pagination end
pagination error
search
filter changes
```

### Favorite tests

Cover:

```text id="skc6s9"
guest → authentication_required
authenticated → favorite success
favorite failure → UI rollback
```

### Search/filter tests

Cover:

* query submission
* query clearing
* filter application
* combined filters
* reset filters
* loading behavior

### Widget tests

Cover:

* result cards
* rating
* favorite state
* availability state
* sponsored badge
* search
* filter bar
* empty/error/loading states
* navigation actions

### Navigation tests

Cover:

* Profile
* Bookings
* Favorites
* Details
* Booking
* Authentication-required action

Only test destinations that actually exist.

### Localization/RTL

Verify:

* English
* Arabic
* no overflow caused by Arabic labels
* directional controls

---

## 59. Testing Performance

Large result sets should not be rendered eagerly in widget tests.

Use small deterministic fixtures.

Do not use real network calls.

Use repository fakes.

Do not use Google-hosted image URLs in tests unless intentionally mocking remote images.

---

## 60. Acceptance Criteria

```text id="3fghwz"
[ ] Discovery feed is a real feature, not hardcoded Stitch data.
[ ] Existing Dorak design system is used.
[ ] No raw color literals in app code.
[ ] No hardcoded static user-visible strings.
[ ] EN + AR localization exists.
[ ] Real backend contract is inspected and followed.
[ ] No invented endpoints.
[ ] Typed DTO/entity models are used where required.
[ ] Repository boundary is respected.
[ ] Pure Bloc (flutter_bloc) is used for discovery state.
[ ] Search works according to backend contract.
[ ] Filters work according to backend contract.
[ ] Result pagination works.
[ ] Pull-to-refresh works if supported by state architecture.
[ ] Empty state works.
[ ] Error state works.
[ ] Retry works.
[ ] Loading-more state works.
[ ] Favorite behavior is persisted correctly.
[ ] Guest favorite action triggers authentication_required.
[ ] Guest booking action triggers authentication_required.
[ ] Dynamic rating is displayed.
[ ] Dynamic distance is displayed.
[ ] Dynamic availability is displayed.
[ ] Sponsored state is data-driven.
[ ] Service tags are dynamic.
[ ] Demo Stitch data is not hardcoded into production.
[ ] Image URLs are not copied from Stitch.
[ ] Mobile navigation works.
[ ] Desktop navigation is implemented only if in scope.
[ ] View Map is implemented only when map/location infrastructure exists.
[ ] RTL works.
[ ] Accessibility semantics exist.
[ ] No duplicate state-management architecture.
[ ] No duplicate HTTP architecture.
[ ] No invalid package dependencies.
[ ] Tests pass.
[ ] Analyze passes.
[ ] Taxonomy passes.
[ ] Full melos verify passes.
```

---

## 61. Verification

From:

```text id="z3q7sy"
/home/lenovo/work/projects/dorak/dorak-mobile
```

run the repository gate after implementation:

```bash
dart run melos run verify
```

Also inspect the relevant backend tests/contracts where applicable.

Do not mark 016 complete until the full verification gate passes.

---

## 62. Export Cleanup

Only after:

```text id="3bdnpe"
implementation
+
tests
+
verification
+
documentation
```

are complete:

```text
Delete:
docs/stitch/exports/016_discovery_feed/
```

Do not delete the export before the gate is green.

---

## 63. Documentation Updates

After implementation update:

```text id="tw0rjt"
docs/index.md
docs/feature-index.md
apps/client_app/docs/feature-index.md
```

Update the appropriate Track 18 / CL-09 status.

Do not mark the feature complete if dependencies remain unfinished.

---

## 64. Final Implementation Principle

The coding agent must treat this plan as the normalized implementation contract.

Use:

```text id="fd0d0c"
plan.md
+
AGENTS.md
+
CLAUDE.md
+
existing Flutter architecture
+
actual backend contract
+
screen.png
+
code.html
```

The priority order is:

```text id="i9fl1x"
Backend/API contract
        ↓
Existing Dorak architecture
        ↓
Product requirements
        ↓
plan.md
        ↓
Stitch visual/layout reference
        ↓
HTML/Tailwind implementation details
```

Stitch is not allowed to invent backend behavior, navigation architecture, state management, or security behavior.

The final Flutter implementation must be production code, not a Flutter translation of the HTML.
