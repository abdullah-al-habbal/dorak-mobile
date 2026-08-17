# Design System — States & Loading Components

Track 12 (Global UI States). See `docs/index.md` §Track 12.

## The no-strings rule

`design_system` must never resolve a string (CLAUDE.md §2). Every state
component takes its copy as constructor parameters; the app layer supplies ARB
strings (`localization`) and picks the component from bloc state.

## Component map

| Component | Covers | API |
|---|---|---|
| `StatusView` | empty · error · offline · retry (as `onAction`) | `icon`, `title`, `message?`, `actionLabel?`, `onAction?`, `iconColor?` |
| `StatusBanner` | compact inline error/message row | `message`, `color?`, `actionLabel?`, `onAction?` |
| `AppLoader.page()` | full-page loading | 32px centred, expands |
| `AppLoader.inline()` | inline loading (list footers) | `size` default 20 |
| `ShimmerBox` | shimmer skeleton primitive | `width`, `height`, `borderRadius?` |
| `PrimaryButton.isLoading` | button loading | `isLoading` flag |
| `RefreshIndicator` / `SnackBar` | refresh + transient failure | framework, no wrapper |

**Retry is an action, not a state.** No `RetryButton` widget exists — retry is
`actionLabel` + `onAction` on `StatusView` / `StatusBanner`.

## Filled state docs

- [`states/empty.md`](./states/empty.md)
- [`states/network_error.md`](./states/network_error.md)
- [`states/offline.md`](./states/offline.md)
- [`states/retry.md`](./states/retry.md)
- [`states/session_expired.md`](./states/session_expired.md)
- [`states/authentication_required.md`](./states/authentication_required.md)
- [`components/loading/fullscreen.md`](./components/loading/fullscreen.md)
- [`components/loading/inline.md`](./components/loading/inline.md)
- [`components/loading/button.md`](./components/loading/button.md)
- [`components/shimmer/text.md`](./components/shimmer/text.md)

## Deliberately empty

| File | Reason |
|---|---|
| `states/permission_required.md` | No permission mechanism exists in the workspace (no `permission_handler`, `geolocator`, or `connectivity_plus`) and no production consumer. Deferred by Track 12; owner is Tracks 13/14, triggered by Discovery 016. See `docs/index.md` §Track 12. |
| `states/success.md` | No component. Success is the absence of an error state. |
| `states/no_search_results.md` | A copy variant of the empty state (`StatusView`), not a component. |
| `components/shimmer/{card,list,profile}.md` | Compositions of `ShimmerBox`; built when their first consumer (016) needs them. |
| `components/loading/circular.md` | Framework `CircularProgressIndicator`; `AppLoader` is the wrapper. |
| `components/feedback/{snackbar,toast}.md` | Framework `SnackBar`; no wrapper warranted. |

## Paged<T> mapping (Track 09)

| `Paged<T>` | Render |
|---|---|
| `isFirstLoad` | `ShimmerBox` list skeleton or `AppLoader.page()` |
| `isLoadingMore` | `AppLoader.inline()` in the list footer |
| `isRefreshing` | `RefreshIndicator` |
| `isEmpty` | `StatusView` (neutral icon) |
| `hasFailedFirst` | `StatusView` with `colors.error` + retry action |
| `hasFailedMore` | `StatusBanner` in the footer + retry |
| `hasFailedRefresh` | `SnackBar` |
| `isEndOfList` | text line |

Track 12 stays `IN_PROGRESS` until Discovery 016 consumes these components.