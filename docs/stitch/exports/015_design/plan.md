# Stitch 015 — Dorak Design System Reference and Reconciliation Plan

## 1. Artifact Identity

* Export: `015_design`
* Artifact type: Global design-system reference
* Screen: None
* Client feature: None
* Track: Cross-cutting design-system reference
* Implementation target: `packages/design_system`
* Related historical exports: 010–014 and subsequent Stitch screens

This artifact is NOT a Flutter screen.

There must be no:

```text
015.screen.dart
015.widget.dart
```

created from this artifact.

---

## 2. Export Structure

The normalized export should be:

```text
docs/stitch/exports/015_design/
├── DESIGN.md
└── plan.md
```

There is intentionally no:

```text
code.html
screen.png
```

because Stitch 015 is a design-system document rather than a screen export.

---

## 3. Current Product Name

The current product name is:

```text
Dorak
```

Older project references such as:

```text
Kraseena
```

are historical names only and must not be treated as separate products, brands, tenants, or design systems.

Any implementation or documentation created from this artifact must use `Dorak`.

---

## 4. Purpose of This Artifact

`015_design` describes design principles intended to guide the wider Dorak product.

Its purpose is to document:

* visual language
* typography direction
* spacing principles
* component principles
* card/list patterns
* multi-tenant visual concepts
* status semantics
* Arabic/RTL considerations

It is not, by itself, an instruction to replace the existing Flutter design system.

The existing Flutter implementation remains authoritative for current production code.

---

## 5. Existing Flutter Design-System Authority

The current implementation lives under:

```text
packages/design_system/
```

The coding agent must inspect the actual implementation before changing anything.

Existing documented pieces include:

```text
DorakColors
DorakTypography
DorakDimensions
DorakTheme
```

and the existing shared widgets.

The agent must not regenerate these blindly from `015/DESIGN.md`.

---

## 6. Design-System Reconciliation Rule

Treat this document as:

```text
design reference
    ↓
compare with current design system
    ↓
identify aligned concepts
    ↓
identify missing concepts
    ↓
decide what is current, future, or obsolete
```

Do not treat it as:

```text
DESIGN.md
    ↓
overwrite packages/design_system
```

Any actual code change requires evidence that the change belongs to the current Dorak product and does not break existing screens.

---

## 7. Global Visual Direction

The design describes Dorak as:

* Corporate
* Modern
* Tactile
* premium
* structured
* trustworthy
* bilingual
* suitable for grooming and beauty workflows

The implementation should preserve the product's existing visual identity while using these principles as guidance for future features.

Do not introduce a second visual identity.

---

## 8. Dual-Universe Concept

The artifact describes two tenant-oriented visual universes:

```text
Men's Universe
    ↓
Charcoal / dark neutral base
    +
Antique Gold accents

Women's Universe
    ↓
Deep Burgundy base
    +
Champagne Gold accents
```

This is a product/design concept.

It must NOT automatically become a runtime theming system unless the current product requirements explicitly require it.

Before implementation, determine:

1. Whether tenant-specific theming is actually supported by the backend.
2. Whether the client application receives tenant/theme configuration.
3. Whether theme switching is a user-visible client requirement.
4. Whether the existing `DorakTheme` architecture can support this without violating current design-system boundaries.

Do not add multi-universe themes merely because this document mentions them.

If implemented later, it must be done as a deliberate architecture change with a documented decision.

---

## 9. Current Color-System Relationship

The artifact defines conceptual color groups:

```text
Primary
Secondary
Tertiary
Neutral
Functional status
Universe-specific accents
```

The current Flutter design system already provides semantic colors.

The implementation rule is:

```text
Stitch color intent
      ↓
existing Dorak semantic token
      ↓
Flutter widget
```

Do not write raw hex values in application code.

Any new colors must first be evaluated as semantic tokens.

---

## 10. Functional Status Colors

The design reference explicitly describes:

```text
Emerald
    ↓
available / confirmed

Crimson
    ↓
occupied / unavailable
```

These colors are intended for operational states such as:

* chair availability
* booking availability
* appointment status

They should not be added globally until their usage is required by an implemented feature.

When these states become necessary:

1. Define semantic tokens.
2. Define light/dark behavior.
3. Verify contrast.
4. Verify Arabic/RTL presentation.
5. Reuse them across the relevant booking/floor-plan components.

Do not hardcode these colors inside feature screens.

---

## 11. Typography

The design reference uses:

```text
IBM Plex Sans
```

The repository already has an established typography system.

The agent must continue using:

```text
DorakTypography
```

and must not create screen-specific typography tokens merely because this document gives alternate font sizes.

Typography changes require checking all currently implemented screens for regressions.

---

## 12. Arabic / RTL

The artifact explicitly treats Arabic as a first-class design concern.

Requirements for future implementation:

* Arabic and Latin must both be visually balanced.
* Text must not be treated as a translated-afterthought.
* Layout must use Flutter directional APIs.
* Typography must remain readable in Arabic.
* Larger text may require more vertical space.
* Components must survive longer Arabic strings.

Use the existing localization and RTL architecture.

Do not create a separate Arabic-only UI implementation unless an actual design requirement demands it.

---

## 13. Spacing

This artifact describes a 4px baseline grid:

```text
4
8
16
24
48
```

The existing Dorak implementation may use different normalized dimensions.

Therefore:

```text
Do not replace existing dimensions globally just because 015 specifies 4px.
```

Instead:

* map existing values where possible
* introduce a missing semantic dimension only when justified
* verify existing screens
* preserve consistency across the application

The final Flutter implementation must use `DorakDimensions`.

---

## 14. Component Principles

The artifact defines several conceptual component types:

```text
Buttons
Inputs
Cards
Status toggles
Lists
Tenant/universe switcher
```

These are design principles, not immediate implementation requirements.

Before creating any component:

1. Check whether an equivalent component already exists.
2. Check whether the component is genuinely shared.
3. Follow Track 15 rules.
4. Keep feature-specific components inside the feature unless multiple apps/features need them.

Do not create duplicate shared widgets.

---

## 15. Buttons

Concept:

```text
Primary
Secondary
Status Toggle
```

Current implementation already contains primary and secondary button components.

Reuse them where compatible.

A future status toggle should be evaluated separately because it has different semantics from ordinary navigation/action buttons.

Do not modify `PrimaryButton` just to satisfy a hypothetical future staff workflow.

---

## 16. Input Fields

Design principles:

* labels remain visible
* accessibility matters
* focus state is obvious
* error state is clear
* bilingual use is considered

The existing authentication input implementation is currently app-local.

Do not move it into `design_system` solely because 015 discusses input fields.

Track 15 governs promotion of shared components.

---

## 17. Cards / Modular Blocks

The artifact describes cards as modular blocks for:

* services
* staff
* appointments
* operational information

Future implementation should prefer:

```text
semantic data
+
consistent card structure
+
tonal layering
```

rather than creating many unrelated card styles.

Before creating a card, inspect existing components and the specific Stitch screen requiring it.

Do not create a global card widget merely because the design document describes cards conceptually.

---

## 18. Lists

The artifact describes appointment lists containing:

```text
timestamp
client name
status indicator
```

This should remain a feature-level design requirement until appointment functionality is implemented.

Likely implementation areas:

```text
appointments
booking
business/stylist workflows
```

Do not implement these components during the 015 migration itself.

---

## 19. Dual-Universe Switcher

The document describes:

```text
Dual-Universe Switcher
```

for global administrators to preview Men/Women skins.

This is not currently part of the client-app implementation described by the repository documentation.

Therefore:

```text
STATUS: Future / Not implemented
```

Do not build it during 015.

If later required, it needs:

* product requirement
* backend/theme contract
* theme architecture decision
* state-management decision
* testing strategy

---

## 20. Elevation and Depth

Preferred visual approach:

```text
tonal layering
+
subtle outlines
+
limited shadow
```

Avoid:

* heavy shadows
* excessive borders
* unnecessary blur
* expensive rendering effects

This aligns with the existing Dorak design direction.

Future components should use semantic surfaces and restrained elevation.

---

## 21. Shape Language

The design reference favors:

* disciplined rounded corners
* small radii for controls
* larger radius for grouped containers
* pills for status tags

Do not replace the existing global radii tokens based only on this document.

Use `DorakDimensions` and current theme values.

New radius tokens require an explicit reason.

---

## 22. Motion

The design language favors subtle motion:

```text
fade
slide-up
stagger
```

The current Stitch converter already contains validated motion conventions.

Future screens should reuse those conventions.

Do not introduce a new animation framework.

---

## 23. Dark Mode / Theme Support

The design document primarily describes a light visual system and tenant-specific concepts.

The Flutter repository already has theme infrastructure.

Future theme changes must:

* preserve semantic color names
* support light/dark where required
* avoid raw colors
* preserve contrast
* not break localization/RTL

Do not add dark-mode or tenant-mode behavior solely from this document without an actual product requirement.

---

## 24. Multi-Tenant Considerations

The artifact strongly suggests tenant-driven visual adaptation.

Before implementation of any tenant skin:

```text
Backend tenant
      ↓
theme/universe configuration
      ↓
core data/configuration
      ↓
app theme
      ↓
components
```

The exact architecture must be decided later.

Do not put tenant-specific theme logic directly into arbitrary feature screens.

---

## 25. Accessibility

All future implementations derived from this design reference must preserve:

* readable text
* visible focus
* usable touch targets
* semantic controls
* accessible error states
* sufficient contrast
* Arabic/RTL usability

Do not rely solely on color for operational state.

Status should also have text, icon, or another semantic representation.

---

## 26. Localization

The design reference is explicitly bilingual.

All future user-visible text must follow the repository localization rules:

```text
packages/localization/l10n/app_en.arb
packages/localization/l10n/app_ar.arb
```

Never copy English strings from Stitch directly into Flutter code.

Arabic must be a real translation.

---

## 27. Security / Sensitive UI

Future appointment, booking, stylist, and client information must be treated as application data, not decorative content.

Do not log sensitive client information unnecessarily.

Do not expose private appointment/client information through debug output.

This document itself does not create a storage or security contract; those remain governed by the core architecture documentation.

---

## 28. Relationship to Stitch Screen Exports

For future screens:

```text
015_design/
    ↓
global design reference

016+/screen export/
    ↓
screen-specific layout

current Flutter design_system
    ↓
implementation source
```

Every screen plan should reference 015 conceptually where relevant but should not duplicate the entire document.

A screen plan remains responsible for:

* specific layout
* specific strings
* specific interactions
* specific states
* specific navigation
* specific engineering contracts

---

## 29. What the AI Agent Must NOT Do

When processing 015, the AI agent must NOT:

```text
[ ] Create a 015 Flutter screen.
[ ] Replace the existing Dorak design system.
[ ] Generate a second theme architecture.
[ ] Generate a second localization system.
[ ] Introduce raw colors into application code.
[ ] Implement tenant switching without a product/backend requirement.
[ ] Implement Men/Women themes merely because this document describes them.
[ ] Create generic cards/buttons/inputs without checking existing components.
[ ] Modify existing production screens only to make them match 015.
[ ] Treat 015 as a higher-priority engineering contract than CLAUDE.md/AGENTS.md.
```

---

## 30. What the AI Agent MAY Do

During future feature implementation, the agent may use 015 to:

```text
[ ] Understand Dorak's intended visual language.
[ ] Understand spacing/radius principles.
[ ] Understand bilingual requirements.
[ ] Understand future status semantics.
[ ] Evaluate whether a component should follow tonal layering.
[ ] Evaluate future tenant/universe theming requirements.
[ ] Compare new Stitch screens against the wider design direction.
```

---

## 31. Current Status

```text
Artifact status: REFERENCE
Flutter implementation status: ALREADY REPRESENTED PARTIALLY
Screen migration status: NOT APPLICABLE
```

This artifact does not become `Migrated` in the same sense as a screen export.

It should remain available as a reference until the design system itself is formally updated or the artifact is superseded.

---

## 32. Acceptance Criteria

```text
[ ] 015 is represented as a folder containing DESIGN.md + plan.md.
[ ] No screen is created for 015.
[ ] Current Dorak design_system remains authoritative.
[ ] Historical design concepts are documented without blindly implementing them.
[ ] Tenant/universe theming is explicitly treated as future unless product requirements change.
[ ] Functional status colors are treated as semantic future requirements.
[ ] Arabic/RTL expectations are preserved.
[ ] Existing components are reused rather than duplicated.
[ ] Future screen plans can reference this artifact.
[ ] No production code is changed solely because of 015.
```

---

## 33. Final Rule

`015_design` is a reference document, not an implementation task.

Its job is to reduce ambiguity for future AI agents.

The correct relationship is:

```text
015_design
   ↓
global visual/UX principles

Current Dorak design_system
   ↓
actual reusable Flutter implementation

Individual Stitch export
   ↓
screen-specific plan.md

plan.md
   ↓
feature implementation
```

Do not allow 015 to overwrite working production architecture.

When the design reference conflicts with the current backend, product requirements, or established Flutter architecture, the real product and engineering contracts win.
