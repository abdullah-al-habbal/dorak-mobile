# Inline Loading

Component: `AppLoader.inline()`

```dart
AppLoader.inline()        // 20px, shrink-wrapped
AppLoader.inline(size: 24)
```

A shrink-wrapped spinner for list footers (`Paged<T>.isLoadingMore`) and other
embedded contexts. It does not expand — place it inside the footer's own
alignment/padding.

Takes no strings.