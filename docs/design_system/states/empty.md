# Empty State

Component: `StatusView`

```dart
StatusView(
  icon: Icons.inbox_outlined,
  title: l10n.emptyTitleGeneric,
  message: l10n.emptyMessageGeneric,
)
```

Neutral tone — `iconColor` defaults to `colors.onSurfaceVariant`. The icon and
copy are parameters: feature-specific empty copy (e.g. "No reviews yet") stays
with its feature's ARB keys. `actionLabel`/`onAction` are optional for an
empty-state call to action (e.g. "Explore salons").