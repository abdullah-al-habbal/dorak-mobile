# Network Error State

Component: `StatusView`

```dart
StatusView(
  icon: Icons.cloud_off,
  title: l10n.errorTitleGeneric,
  message: l10n.errorGeneric,
  iconColor: DorakColors.of(context).error,
  actionLabel: l10n.actionRetry,
  onAction: retry,
)
```

Full-page failure of a first load (`Paged<T>.hasFailedFirst`). Pass
`colors.error` as `iconColor` to switch the neutral default to the error tone.
The `errorGeneric` / `errorNetwork` ARB message bodies are existing keys; the
title keys (`errorTitleGeneric`, `errorTitleOffline`) are the Track 12
fallbacks.

Mapping exceptions to ARB strings stays in the app layer (`AuthError.from` is
the precedent) — `design_system` never resolves a string.