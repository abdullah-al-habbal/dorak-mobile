---
name: Dorak High-End Grooming & Beauty
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display-lg:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: IBM Plex Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 20px
    fontWeight: '500'
    lineHeight: '1.4'
  body-main:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-caps:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  arabic-override:
    fontSize: 110%
    lineHeight: '1.8'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 48px
  container-margin: 20px
  gutter: 12px
---

## Brand & Style

The design system is built on a "Dual-Universe" architecture, catering to the distinct aesthetic expectations of high-end Men's Grooming and Women's Beauty salons in Syria. The brand personality is rooted in high-stakes professionalism, reliability, and local prestige.

The design style is **Corporate / Modern** with a **Tactile** edge. It utilizes a modular, backend-driven UI approach where the interface serves as a sophisticated frame for service imagery and scheduling data. The experience should feel like walking into a luxury atelier—quiet, organized, and premium. 

Key attributes:
- **Bilingual Excellence:** Equal visual weight for Arabic and Latin scripts.
- **Contextual Adaptation:** The UI skin shifts based on the tenant's "Universe" while maintaining a unified structural logic.
- **Trust-Based Utility:** High-contrast status indicators for real-time chair and booking management.

## Colors

This design system utilizes a dynamic color token strategy to support multi-tenancy:

1.  **Men’s Universe:** Features "Charcoal Slate" as the primary base with "Antique Gold" accents. The palette is deep, grounded, and masculine, suggesting stability and precision.
2.  **Women’s Universe:** Utilizes "Deep Burgundy" paired with "Champagne Gold." This evokes luxury, elegance, and a premium spa-like atmosphere.
3.  **Functional Status:** Universal colors are reserved for operational status. **Emerald Green** denotes available chairs or confirmed slots; **Crimson Red** denotes occupied or unavailable status.
4.  **Neutral Palette:** A shared set of cool greys is used for borders, inactive states, and secondary metadata to ensure cross-universe consistency.

## Typography

The design system employs **IBM Plex Sans** for its exceptional clarity in both Arabic and Latin scripts. The typeface bridges the gap between technical precision (appropriate for SaaS) and modern elegance.

- **Bilingual Strategy:** Since Arabic script typically appears smaller and more compressed than Latin at the same point size, the `arabic-override` token increases line height and relative scale for right-to-left (RTL) contexts to ensure optical balance.
- **Hierarchy:** Display styles are bold and authoritative for salon names and price points. Body text is optimized for readability in service descriptions. 
- **Scalability:** Larger headlines automatically scale down for mobile viewport safety to prevent awkward word breaks in longer Arabic strings.

## Layout & Spacing

This design system follows a **4px baseline grid** to ensure mathematical precision in tight, data-heavy dashboard views.

- **Mobile-First Layout:** The default view is a single-column stack with a 20px "safe-zone" margin on the left and right.
- **Modular Grid:** Content is organized into "Service Blocks." On tablet and desktop, these blocks transition into a 12-column fluid grid.
- **Density:** High-density spacing is used for calendar and scheduling views to maximize information density, while low-density (loose) spacing is used for the "discovery" and "booking" flows to feel more premium.

## Elevation & Depth

To maintain a professional, high-end feel, this design system avoids heavy, muddy shadows. 

- **Tonal Layering:** Depth is primarily conveyed through subtle background shifts (e.g., a slightly darker surface for the container and a pure white/charcoal for the card).
- **Low-Contrast Outlines:** Interactive elements use 1px "Ghost Borders"—a subtle, 10-15% opacity border of the text color—to define shape without adding visual noise.
- **Active Elevation:** Only the primary "Action Card" (the current appointment or the selected chair) receives a soft, diffused ambient shadow with a tint of the Universe's primary color to create focus.

## Shapes

The shape language is **Soft (0.25rem)**. 

While rounded enough to feel contemporary and approachable, the corners remain disciplined. This reflects the "sharp" nature of grooming (blades, precision cuts) and the "structured" nature of beauty treatments.
- **Buttons & Inputs:** Follow the 4px (`rounded-sm`) radius.
- **Surface Containers:** Use 8px (`rounded-lg`) to enclose groups of information.
- **Pill Tags:** Status indicators (Available/Occupied) use a fully rounded "pill" shape to distinguish them from interactive buttons.

## Components

### Buttons
- **Primary:** Solid fill (Universe Primary). High-contrast text. No gradients.
- **Secondary:** Outlined with a 1px border of the Universe Primary color.
- **Status Toggle:** Large, tactile buttons for staff to toggle chair status. Available = Green border/text; Occupied = Red solid fill.

### Input Fields
- Understated design with a focus on clear labeling. Labels are always visible (not floating) to ensure accessibility for users switching between languages.
- Focus state uses a 2px stroke of the Universe's Secondary (Gold) color.

### Cards (Modular Blocks)
- The core of the backend-driven UI. Each service, staff member, or appointment is a discrete card.
- **Header:** Contains the Title and Price.
- **Footer:** Contains the primary action (Book Now, Edit, Check-in).

### Dual-Universe Switcher
- A specialized component in the platform's multi-tenant admin view that allows global admins to preview the UI in both "Men" and "Women" skins instantly.

### Lists
- Clean, border-bottom separated lists for "Today's Appointments." Every list item must include a timestamp, client name, and a "Status Dot."