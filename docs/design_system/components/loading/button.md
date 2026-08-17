# Button Loading

Component: `PrimaryButton.isLoading` (Track 12 objective — **already
implemented and in production**).

```dart
PrimaryButton(
  label: l10n.loginButton,
  onPressed: _submit,
  isLoading: widget.isSubmitting,
)
```

When `isLoading` is true the label is replaced by a 20px spinner
(`colors.onPrimary`) and `onPressed` is suppressed. Every auth form uses it
(login, sign-up, verify).

**`SecondaryButton` deliberately has no `isLoading`.** No current consumer
needs a loading secondary action, and no Track 12 requirement names one. If a
real consumer appears, add the flag mirroring `PrimaryButton` — not before.

For `Paged<T>` semantics: form submissions use bloc `isSubmitting` state;
`isFirstLoad`/`isLoadingMore` use `AppLoader` instead.