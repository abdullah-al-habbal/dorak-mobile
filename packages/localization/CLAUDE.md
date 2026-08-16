# CLAUDE.md — `packages/localization`

Scoped rules for this package. Inherits [`../../CLAUDE.md`](../../CLAUDE.md).
Inventory and key list: [`AGENTS.md`](./AGENTS.md).

---

## 1. What this package is for

Every user-visible string in every Dorak app, in English and Arabic, exposed as
the generated `AppLocalizations` class.

## 2. Dependency ceiling

Permitted: `flutter`, `flutter_localizations`, `intl`. Nothing else.

Forbidden: `core`, `design_system`, `feature_floor_plan`, any `apps/*` import.
This package must stay independently reusable — it is the leaf of the
dependency graph.

## 3. Hard rules

1. **`l10n/app_en.arb` is the template.** Every key must exist in **both**
   `app_en.arb` and `app_ar.arb`. A key in one file only is a defect.
2. **Arabic must be a real translation**, never a transliteration and never
   English left in place.
3. **Never hand-edit `lib/src/generated/`.** Change the ARB, then run
   `dart run melos run generate`. The generated files are committed.
4. **Key naming:** camelCase, feature-prefixed, one key per string —
   `loginTitle`, `signUpPasswordHint`, `verifyResendDisabled`.
5. **Reuse before adding.** Check the existing 75 keys first; `skip`, `cancel`,
   `next`, `previous`, `back`, `errorGeneric`, `errorNetwork`, `fieldRequired`
   are deliberately generic.
6. **Every key carries an `@key` description block.** No bare entries.
7. **Demo and illustrative copy is localized too** — onboarding card labels, AI
   match labels, booking placeholders. Nothing user-visible is inlined in Dart.
8. **Placeholders are typed.** A key with `{name}` needs a `placeholders` block
   declaring the type; it then generates a method, not a getter.
9. **No app-specific namespacing yet.** All three apps share one ARB pair. If
   that stops scaling, decide the split deliberately — do not start prefixing
   ad hoc.

## 4. Verification

```bash
cd dorak-mobile
dart run melos run generate    # flutter gen-l10n, scoped to this package
dart run melos run analyze
```

Then confirm both ARB files still have identical key sets:

```bash
cd packages/localization/l10n
diff <(grep -oE '^  "[a-zA-Z][a-zA-Z0-9]*"' app_en.arb) \
     <(grep -oE '^  "[a-zA-Z][a-zA-Z0-9]*"' app_ar.arb)
```

Empty output means parity. There is no automated parity test — add one if you
touch this package substantially.
