# AGENTS.md — `packages/localization`

Every user-visible string, EN + AR, via generated `AppLocalizations`.

Parent: [`../../AGENTS.md`](../../AGENTS.md) · Rules: [`CLAUDE.md`](./CLAUDE.md)

---

## 1. Layout

```
l10n/app_en.arb                       template — source of truth
l10n/app_ar.arb                       Arabic, identical key set
l10n.yaml                             gen-l10n config
lib/localization.dart                 barrel — exports app_localizations.dart only
lib/src/generated/                    committed, never hand-edited
  app_localizations.dart              abstract AppLocalizations
  app_localizations_en.dart
  app_localizations_ar.dart
```

`l10n.yaml`:

```yaml
arb-dir: l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/src/generated
output-class: AppLocalizations
preferred-supported-locales: [en, ar]
```

Deps: `flutter`, `flutter_localizations`, `intl ^0.20.0`. `flutter: generate: true`.

## 2. Consuming it

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.loginTitle);
```

App wiring (already done in `client_app`):

```dart
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

`business_app` and `stylist_app` do **not** depend on this package yet.

## 3. The 75 keys

**Common** — `splashTitle` `skip` `cancel` `next` `previous` `back` `homeTitle`

**Errors / validation** — `errorNetwork` `errorGeneric` `fieldRequired`
`fieldInvalidEmail` `fieldPasswordTooShort` `fieldPasswordMismatch`

**Locale toggle** — `localeArabic` `localeEnglish`

**Onboarding — welcome** — `onboardingWelcomeTitle` `onboardingWelcomeSubtitle`
`onboardingGetStarted`

**Onboarding — skip sheet** — `skipOnboardingQuestion` `skipForNow`
`dontShowAgain`

**Onboarding — discovery** — `discoveryTitle` `discoverySubtitle`
`discoveryCardShops` `discoveryCardBarbers` `discoveryCardServices`

**Onboarding — booking** — `bookingTitle` `bookingSubtitle` `bookingServiceLabel`
`bookingServiceMeta` `bookingProfessionalLabel` `bookingProfessionalRating`
`bookingDateLabel` `bookingTimeLabel`

**Onboarding — AI** — `aiTitle` `aiSubtitle` `aiMatchLabel` `aiRecommendedLabel`
`aiStyleFade` `aiStyleCrop` `aiFaceShapeLabel` `aiPrivacyNote`

**Auth entry (006)** — `authWelcomeTitle` `authSubtitle` `authLogIn`
`authCreateAccount` `authContinueAsGuest` `authGuestHint`

**Login (007)** — `loginTitle` `loginSubtitle` `loginEmailLabel`
`loginPasswordLabel` `loginForgotPassword` `loginButton` `loginSignUpPrompt`
`loginCreateAccountLink` `loginErrorInvalidCredentials`

**Sign-up (008)** — `signUpTitle` `signUpSubtitle` `signUpFullNameLabel`
`signUpEmailLabel` `signUpPasswordLabel` `signUpConfirmPasswordLabel`
`signUpPasswordHint` `signUpButton` `signUpAlreadyHaveAccount` `signUpLogInLink`

**Verify (009)** — `verifyTitle` `verifySubtitle` `verifyButton`
`verifyDidNotReceive` `verifyResend` `verifyResendDisabled` `verifyErrorInvalid`
`verifySkip`

## 4. Parameterised keys

Only two, and they generate **methods**, not getters:

```dart
String verifySubtitle(String email);        // "…code we sent to {email}"
String verifyResendDisabled(int seconds);   // "Resend Code ({seconds}s)"
```

ARB form:

```json
"verifyResendDisabled": "Resend Code ({seconds}s)",
"@verifyResendDisabled": {
  "description": "Verify account resend action during cooldown",
  "placeholders": { "seconds": { "type": "int" } }
}
```

Everything else is a plain getter. There are no plurals or `select` messages
yet — adding one is fine, but declare the placeholder type.

## 5. Adding a string

1. Add the key **and** its `@key` description to `app_en.arb`.
2. Add the same key to `app_ar.arb` with a real Arabic translation.
3. `dart run melos run generate`.
4. Use `l10n.<key>` — never inline the literal.
5. Commit the regenerated files under `lib/src/generated/`.

Naming: camelCase, feature-prefixed, one key per string. Check §3 before adding
— `skip`, `cancel`, `next`, `previous`, `back`, `errorGeneric`, `errorNetwork`
and the `field*` set are intentionally shared.

## 6. RTL

Flutter flips layout automatically when the locale is `ar` — the app passes
`locale:` to `MaterialApp` and `DorakTheme.forLocale` swaps to
`IBM Plex Sans Arabic`.

Your part: use `AlignmentDirectional`, `EdgeInsetsDirectional` and
`TextAlign.start`; never hardcode left/right. For directional icons the
codebase idiom is `isRtl ? Icons.arrow_forward : Icons.arrow_back`.

## 7. Gotchas

- **Locale is not persisted.** The EN/AR toggle lives in a `ValueNotifier` in
  `DorakApp` and resets on restart. It is **transitional** (Phase 3 folds it
  into a `SettingsBloc`). Persisting it is unowned work — it would go in
  `AppPreferences` (`packages/core`).
- **Generated files are committed** and excluded from the analyzer and the
  taxonomy checker. Do not add them to `.gitignore`, and do not edit them.
- **No ARB parity test exists.** `test/localization_test.dart` is a placeholder.
  A key added to only one locale will pass the gate and fail at runtime as a
  missing-translation fallback. Diff the key sets manually (see
  [`CLAUDE.md`](./CLAUDE.md) §4).
- **`preferred-supported-locales: [en, ar]`** — adding a third locale means a
  new ARB file plus updating that list.
- **`client_app/test/widget_test.dart` asserts the literal `'Dorak'`**, which is
  `splashTitle`. Changing that value breaks the test.
