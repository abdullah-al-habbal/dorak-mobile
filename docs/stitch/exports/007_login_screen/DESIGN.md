---
name: Dorak Modern Enterprise
colors:
  surface: '#fdf8fd'
  surface-dim: '#ddd9de'
  surface-bright: '#fdf8fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f2f8'
  surface-container: '#f1ecf2'
  surface-container-high: '#ebe7ec'
  surface-container-highest: '#e5e1e7'
  on-surface: '#1c1b1f'
  on-surface-variant: '#494551'
  inverse-surface: '#313034'
  inverse-on-surface: '#f4eff5'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6850a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#d0bcff'
  secondary: '#625b71'
  on-secondary: '#ffffff'
  secondary-container: '#e8def9'
  on-secondary-container: '#686177'
  tertiary: '#4c435e'
  on-tertiary: '#ffffff'
  tertiary-container: '#645a76'
  on-tertiary-container: '#e0d3f5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#22005c'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e8def9'
  secondary-fixed-dim: '#ccc2dc'
  on-secondary-fixed: '#1e192b'
  on-secondary-fixed-variant: '#4a4358'
  tertiary-fixed: '#eaddff'
  tertiary-fixed-dim: '#cec1e2'
  on-tertiary-fixed: '#1f1730'
  on-tertiary-fixed-variant: '#4b425d'
  background: '#fdf8fd'
  on-background: '#1c1b1f'
  surface-variant: '#e5e1e7'
  input-bg-soft: rgba(234, 221, 255, 0.05)
  input-bg-focus: rgba(234, 221, 255, 0.1)
typography:
  display-lg:
    fontFamily: IBM Plex Sans
    fontSize: 57px
    fontWeight: '400'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 36px
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 36px
  title-lg:
    fontFamily: IBM Plex Sans
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  margin-mobile: 20px
  margin-desktop: 64px
  gutter: 24px
  container-max: 1280px
---

## Brand & Style

Dorak embodies a **Corporate Modern** aesthetic that balances enterprise-grade reliability with a soft, welcoming touch. The brand is designed for professional environments where clarity and focus are paramount, but it avoids the coldness of traditional legacy software by using organic, blurred background elements and a refined purple-hued palette.

The visual style is influenced by **Material 3** principles, utilizing tonal layers and a "fidelity" color approach. It evokes a sense of calm efficiency and modern sophistication through a combination of high-quality typography, intentional whitespace, and smooth motion transitions (like the signature fade-slide-up animation).

## Colors

The palette is rooted in a deep royal purple (`primary`), which provides strong contrast and authority. This is balanced by a soft lavender-tinted background (`surface-bright`) and neutral greys with subtle violet undertones to maintain a cohesive atmospheric feel.

- **Primary:** Used for main actions and branding.
- **Surface Tones:** A tiered system of container colors (low to highest) provides subtle nesting for UI elements.
- **Validation:** Error states use a high-visibility crimson (`#ba1a1a`) that remains legible against the light surface colors.
- **Accents:** Atmospheric blurs use `primary-fixed` and `secondary-fixed` at low opacities to create depth without distracting from content.

## Typography

The system exclusively uses **IBM Plex Sans**, a typeface designed for enterprise interfaces that balances technical precision with friendly humanist details.

- **Headlines:** Use Medium weights (500) to stand out against the body text. On mobile, the `headline-lg` should scale down to 28px to ensure comfortable line wrapping.
- **Body:** Use Regular weights (400) for optimal readability. 16px is preferred for primary input and content, while 14px handles secondary information.
- **Labels:** Use SemiBold/Bold weights (600) with slight letter spacing to differentiate interactive elements and meta-data from standard body text.

## Layout & Spacing

The system uses a **Fixed Grid** approach for content canvases within a fluid shell. The main action area is centered and constrained (max-width 448px for authentication and narrow forms) to reduce cognitive load.

- **Grid:** A standard 12-column grid is used for dashboard layouts, while mobile layouts utilize a single-column flow with 20px side margins.
- **Rhythm:** An 8px base unit (unit-8) drives all spacing decisions. Vertical spacing between form elements is typically 24px (3 units), while text groupings use 8px or 4px for tighter associations.
- **Breakpoints:** Transitions occur at 768px (md) where margins expand from 20px to 64px to utilize the extra horizontal space on desktop.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** rather than heavy shadows. The system feels flat and "integrated" with the background.

- **Surfaces:** Different levels of `surface-container` (lowest to highest) are used to group related content. The primary canvas is usually `surface-bright`.
- **Depth:** Subtle interaction states use a very light shadow or a color shift (e.g., `surface-variant` on hover) to indicate interactivity.
- **Background Elements:** Large, soft radial gradients in the background provide a sense of space and environmental depth without affecting the functional hierarchy of the foreground components.

## Shapes

The design uses a mixed-radius strategy to differentiate between containers and interactive triggers.

- **Inputs:** Top corners are slightly rounded (0.5rem), but the bottom remains sharp to emphasize the `outline-variant` border-bottom stroke, creating a "Material-style" text field look.
- **Buttons:** Fully pill-shaped (rounded-full) for primary CTAs to maximize visual distinction and friendly appeal.
- **Small Elements:** Icons and small buttons use circular backgrounds (rounded-full) for a balanced, symmetrical appearance.

## Components

### Buttons
- **Primary:** Large (56px height), pill-shaped, using `primary` background and `on-primary` text. Includes an trailing icon that shifts 4px on hover to indicate momentum.
- **Ghost/Icon:** 40px diameter, circular, used for navigation (back buttons). Only shows a background on hover.

### Input Fields
- **Floating Label:** Built with a `primary-container` light tint (5-10% opacity) and a 1px bottom border (`outline-variant`).
- **States:** On focus, the bottom border thickens/darkens to `primary` and the label shrinks and floats upward using a cubic-bezier transition.
- **Validation:** Error states replace the border and label color with `error` and include a trailing icon/caption.

### Feedback & Indicators
- **Icons:** Use Material Symbols Outlined with a weight of 400 and grade 0.
- **Animations:** All new view entries should use the `fade-slide-up` animation with staggered delays (100ms increments) to guide the user's eye from the top to the primary action.

### Cards & Containers
- Cards should be used sparingly, relying on spacing and background tonal shifts rather than borders to define sections.