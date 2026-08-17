# Offline State

Presentation variant of the network error — same `StatusView` layout, offline
copy:

```dart
StatusView(
  icon: Icons.cloud_off,
  title: l10n.errorTitleOffline,
  message: l10n.errorNetwork,
  iconColor: DorakColors.of(context).error,
  actionLabel: l10n.actionRetry,
  onAction: retry,
)
```

**No new mechanism.** There is no connectivity package in the workspace and
none is planned. `NetworkException` is already distinguishable at the call
site (`statusCode` 0) and `AuthError.from` already maps it to `errorNetwork` —
an offline state is therefore just the error state with offline copy. Do not
add `connectivity_plus` or similar to detect connectivity; the failure itself
is the signal.