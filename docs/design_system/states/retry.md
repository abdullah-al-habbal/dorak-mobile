# Retry

**Retry is an action, not a state.** There is no `RetryButton` widget — a
retry button would duplicate `PrimaryButton`.

Retry is the `actionLabel` + `onAction` pair on:

- `StatusView` — full-page failure (`hasFailedFirst`)
- `StatusBanner` — inline footer failure (`hasFailedMore`)

The label comes from `l10n.actionRetry` ("Try again" / "حاول مرة أخرى"). The
callback re-dispatches the failed load event to the feature bloc; the bloc
owns the retry semantics (`Paged<T>` has no generic retry method).