# Shimmer — Text/Skeleton Primitive

Component: `ShimmerBox`

```dart
ShimmerBox(width: 160, height: 16)
ShimmerBox(width: 240, height: 24, borderRadius: BorderRadius.circular(8))
```

A hand-rolled animated skeleton primitive: `AnimationController` (1.4s repeat)
driving a `LinearGradient` sweep (`surfaceContainerHighest` base →
`surfaceBright` highlight) through `ShaderMask`. ~40 lines — **no `shimmer`
package** (rule: no dependency without a concrete consumer).

Card/list/profile skeletons are compositions of `ShimmerBox` — build them when
their first consumer (016) needs them, not now.

Use for `Paged<T>.isFirstLoad` skeletons that mirror the final layout.