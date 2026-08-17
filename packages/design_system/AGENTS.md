# AGENTS.md — `packages/design_system`

Tokens, theme, fonts, and cross-app widgets. No strings, no logic, no `core`.

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)

---

## 1. Layout

```
lib/design_system.dart              root barrel — tokens + theme + 14 widgets
lib/src/tokens/
  colors.token.dart                 DorakColors
  typography.token.dart             DorakTypography
  dimensions.token.dart             DorakDimensions
  tokens.barrel.dart
lib/src/theme/
  dorak_theme.theme.dart            DorakTheme
lib/src/widgets/                    14 widgets, one class each
fonts/                              IBM Plex Sans + Arabic, 4 weights each
```

Declared-but-empty directories: `lib/src/tokens/{colors,elevation,radii,spacing,typography}/`
and `lib/src/components/{avatars,bottom_sheets,buttons,cards,inputs}/`. The real
widgets live in `lib/src/widgets/` — **do not** start using `components/`
without deciding the convention first.

## 2. Tokens

### `DorakColors` — 49 semantic fields

Instance fields, not statics. Access is always theme-aware:

```dart
final colors = DorakColors.of(context);   // picks light or dark
```

`static const DorakColors light` / `dark` are the two palettes.

Groups: `background`/`onBackground`; `surface`, `surfaceBright`, `surfaceDim`,
`surfaceContainerLowest…Highest`, `surfaceVariant`, `onSurface`,
`onSurfaceVariant`, `inverseSurface`, `inverseOnSurface`, `surfaceTint`;
`outline`, `outlineVariant`; `primary`/`secondary`/`tertiary` each with
`on*`, `*Container`, `on*Container`; `inversePrimary`; `error`, `onError`,
`errorContainer`, `onErrorContainer`; the `*Fixed`, `*FixedDim`, `on*Fixed`,
`on*FixedVariant` set; and **`inputBgSoft`** / **`inputBgFocus`** — the
form-field fill pair (5% / 10% tint).

### `DorakTypography` — 10 styles

`displayLg` `headlineLg` `headlineLgMobile` `headlineMd` `headlineSm`
`titleLg` `bodyLg` `bodyMd` `labelLg` `labelMd`

Plus `fontFamily` (`IBM Plex Sans`), `fontFamilyArabic`
(`IBM Plex Sans Arabic`), `fontFamilyFallback`.

`bodyMd` and `labelLg` are both 14 px — `labelLg` is w600 with letter-spacing.

### `DorakDimensions`

`unit` 8 · `gutter` 24 · `marginMobile` 20 · `marginDesktop` 64 ·
`containerMaxWidth` 1280
`radiusSm` 4 · `radiusDefault` 8 · `radiusMd` 12 · `radiusLg` 16 ·
`radiusXl` 24 · `radiusFull` 9999
`spacingSmall` 8 · `spacingMedium` 16 · `spacingLarge` 24 · `spacingXLarge` 32

## 3. Theme

```dart
DorakTheme.light
DorakTheme.dark
DorakTheme.forLocale(locale, brightness)   // swaps to the Arabic family for 'ar'
```

`_build` maps the full `ColorScheme`, all 10 text styles into `textTheme`, and
forces `radiusFull` on `elevatedButtonTheme`.

**Not configured:** `inputDecorationTheme`, `outlinedButtonTheme`,
`textButtonTheme`, `bottomSheetTheme`, `appBarTheme`, `dialogTheme`,
`snackBarTheme`. Components that need those styles build their own decoration —
`AuthTextField` in `client_app` is the current example.

## 4. Widgets

| Widget | Constructor |
|---|---|
| `PrimaryButton` | `label`, `onPressed`, `isLoading`, `isDisabled`, `backgroundColor?` |
| `SecondaryButton` | `label`, `onPressed`, `isDisabled`, `foregroundColor?`, `borderColor?` |
| `SkipButton` | `label`, `onPressed`, `isDisabled` |
| `ProgressDots` | `count`, `activeIndex` |
| `OnboardingHeader` | `brandLabel`, `skipLabel`, `onSkip`, `localeLabel?`, `onLocaleToggle?` |
| `BottomSheetModal` | `child`, `onDismiss?` |
| `HeroImage` | `image`, `opacity`, `errorBuilder?` |
| `GradientOverlay` | — |
| `SwipeNavigation` | `child`, `onSwipeRight?`, `onSwipeLeft?`, `velocityThreshold` |
| `StatusView` | `icon`, `title`, `message?`, `actionLabel?`, `onAction?`, `iconColor?` |
| `AppLoader` | `.page()` 32px centred and expanding · `.inline({size = 20})` shrink-wrapped |
| `ShimmerBox` | `width`, `height`, `borderRadius?` — animated skeleton primitive |
| `StatusBanner` | `message`, `color?` (defaults to `colors.error`), `actionLabel?`, `onAction?` |

Notes:

- `PrimaryButton` is the **only** button with `isLoading` (20 px spinner
  replacing the label). `SecondaryButton` deliberately has none — no consumer
  has a loading secondary action yet; wrap it if that ever changes.
- Buttons are full-width pills with `radiusFull` and 16 px vertical padding.
  Label only — no trailing icons by default.
- `SkipButton` is a borderless shrink-wrapped `TextButton`
  (`minimumSize: Size.zero`, `MaterialTapTargetSize.shrinkWrap`) — use it for
  inline text links, not just Skip.
- `OnboardingHeader` has **no back affordance**. It is not a general app bar.
  Screens needing back build their own header (see `AuthHeader` in `client_app`).
- `BottomSheetModal` is a scrim + bottom container with `maxWidth: 448`, 24 px
  top radii and a drag handle. It does **not** call `showModalBottomSheet` —
  the caller does, then renders this as the sheet body.
- `HeroImage` takes an `ImageProvider`, not a URL. Asset-vs-network selection is
  the caller's job.
- `StatusView` is the single layout for empty / error / offline / retry — a
  centered icon, title, optional message and optional full-width action
  (`PrimaryButton`). Feature copy is the caller's ARB strings; no strings live
  here.
- `AppLoader.page()` fills and centres — full-page loading; `AppLoader.inline()`
  shrink-wraps — list footers.
- `ShimmerBox` is a hand-rolled `AnimationController` + `LinearGradient` +
  `ShaderMask` sweep (~40 lines, no `shimmer` package). It is the only animated
  state primitive; skeleton compositions are future compositions of it.
- `StatusBanner` is the promoted `AuthErrorBanner` (client_app §9 note). It is
  the compact inline message row under form actions, with an optional trailing
  text action.

## 5. Missing — do not assume these exist

No text field, password field, OTP input, checkbox, radio, switch, select,
search, phone or email input. No app bar, dialog, snackbar, toast, chip, card,
list item, avatar, tab. No permission-required state widget — there is no
permission mechanism in the workspace and Track 12 defers it (owner: Tracks
13/14, triggered by 016). No precision skeleton compositions for card/list/
profile shimmer — those are compositions of `ShimmerBox`.

`docs/design_system/components/**` contains ~125 markdown specs for these —
**all 0 bytes**. They are Track 15 placeholders, not designs.

## 6. Gotchas

- **Fonts are bundled and declared here.** The `cursor/skills/stitch-flutter-converter.md`
  note that IBM Plex is "deferred, no `.ttf` in the repo" is stale — the files
  are in `fonts/` and wired into `pubspec.yaml`.
- **Never `Image.asset` an SVG.** Flutter cannot decode it and throws at
  runtime. Convert to PNG/JPG or add `flutter_svg`.
- **`OnboardingHeader` fits its brand into a `Flexible` with ellipsis** so the
  locale toggle and Skip keep their space on narrow screens. Keep it that way.
- **The test-suite font is not IBM Plex.** Flutter's test fallback renders every
  glyph at full em width, roughly double. A `RenderFlex overflowed` in a widget
  test is not proof of a device bug — measure before changing layout.
- **`design_system` has no example app.** Verify rendering through
  `client_app`.

## 7. Adding a widget

1. Confirm it is genuinely cross-app. If only one feature uses it, it belongs
   in that app.
2. `lib/src/widgets/<subject>.widget.dart`, one class.
3. Strings and callbacks as constructor parameters. No `AppLocalizations`.
4. Tokens only — `DorakColors.of(context)`, `DorakTypography`,
   `DorakDimensions`.
5. Export from `lib/design_system.dart`.
6. `dart run melos run analyze && dart run melos run taxonomy`.
7. Record it in `docs/feature-index.md` and in §4 above.

## 8. Tests

`test/` holds 14 widget tests: `locale_switcher_test.dart` (2),
`status_banner_test.dart` (3), `status_view_test.dart`
(4), `app_loader_test.dart` (2), `shimmer_box_test.dart` (2), plus the original
`design_system_test.dart` placeholder. There are no golden tests. Real usage
coverage of the button/header widgets comes from `client_app`'s widget tests.
