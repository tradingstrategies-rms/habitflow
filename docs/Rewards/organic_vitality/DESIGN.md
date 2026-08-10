---
name: Organic Vitality
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
  tertiary: '#855300'
  on-tertiary: '#ffffff'
  tertiary-container: '#e29100'
  on-tertiary-container: '#523200'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
  background-warm: '#FFFFFF'
  background-dark: '#121212'
  surface-dark: '#1E1E1E'
  emerald-glow: rgba(16, 185, 129, 0.15)
  kids-primary: '#059669'
  kids-secondary: '#0D9488'
  kids-accent: '#D97706'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  numbers-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  card-padding: 20px
  chip-gap: 12px
  button-height: 48px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
The design system embodies a premium wellness aesthetic, shifting the focus from utilitarian tracking to holistic family growth. The brand personality is calm, encouraging, and sophisticated, avoiding the frantic energy of typical gamified apps in favor of "Organic Vitality."

The visual style is **Modern Minimalist with Tactile Accents**, utilizing high-quality whitespace, crisp typography, and organic shapes. For the Kids Theme, the system transitions into a **Playful Contemporary** style—maintaining the premium feel but increasing saturation and structural softness to invite engagement without appearing "childish" or cartoonish. The goal is to evoke a sense of steady, natural progress.

## Colors
The palette is rooted in "Emerald Green" to symbolize growth. 

- **Light Mode:** Uses a warm white base (#FFFFFF) to keep the interface airy. Text is rendered in soft charcoal (#1F2937) to reduce harsh contrast while maintaining legibility.
- **Dark Mode:** Employs a rich deep charcoal (#121212). Accents use a "soft emerald glow"—a desaturated, slightly luminous version of the primary green—to ensure the UI feels calm in low-light environments.
- **Kids Theme:** Swaps the palette for more saturated, energetic versions of the core colors. While the hues remain consistent, the vibrance is increased to create clear visual distinction and "fun" without breaking the brand’s premium core.

## Typography
The system relies exclusively on **Inter** for its neutral, systematic, and highly legible properties across all platforms. 

- **Headlines:** Use tighter letter spacing and semi-bold weights to establish a strong hierarchy.
- **Numbers:** Are treated as primary data points, utilizing the Medium weight for clarity in progress tracking and balances.
- **Scaling:** On mobile devices, `headline-xl` should be used sparingly, reserved for the primary dashboard and Reward Vault entry points.

## Layout & Spacing
This design system utilizes an **8pt Fluid Grid**. Layouts are characterized by "Large Spacing," favoring generous margins and gutters to prevent information density from overwhelming the user.

- **Grid:** Content typically follows a single-column layout on mobile and a 12-column grid on tablets/desktop.
- **Rhythm:** Spacing between sections should be 32px or 40px to create distinct "visual islands." 
- **Touch Targets:** All interactive elements (buttons, chips, list items) must maintain a minimum 48dp height to ensure accessibility across age groups.

## Elevation & Depth
Hierarchy is established through **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows.

- **Surface Levels:** 
  - **Level 0:** Background (Warm White / Deep Charcoal).
  - **Level 1:** Standard cards with a subtle 1px border or a 2% darker/lighter tonal shift.
  - **Level 2:** Floating cards for "High Emphasis" items like the Reward Balance Card, featuring a soft, diffused "Ambient Shadow" with an 8% opacity tint of the primary emerald.
- **Glassmorphism:** Reserved exclusively for navigation bars and dialog overlays in Dark Mode to maintain a sense of depth and context.

## Shapes
The default shape language is "Rounded," reflecting an organic and friendly aesthetic.

- **Standard:** Cards use a 20dp corner radius; chips use 12dp.
- **Kids Theme:** Transition to a significantly softer profile with **24px (1.5rem)** corners on all major containers and buttons.
- **Interactive Elements:** Buttons utilize a fully rounded (pill) shape to denote high interactivity.

## Components

### Reward Balance Card (High Emphasis)
- **Styling:** Uses Level 2 elevation. In Light Mode, it may feature a subtle linear gradient (Emerald to Teal).
- **Content:** Large `headline-xl` for the point balance. Includes a small "History" text button and a localized "Redeem" primary button.

### XP Progress Bar (Organic Rounded)
- **Styling:** A pill-shaped container with a 100% rounded track.
- **Details:** The "fill" uses the Emerald Green primary. The "track" uses a 10% opacity version of the primary color. In the Kids Theme, the bar is 12px thick; in Standard, it is 8px.

### Reward Transaction Item (Timeline Style)
- **Styling:** A clean list item with a left-aligned vertical line segment connecting consecutive items. 
- **Icons:** Minimal 24dp rounded icons indicating the type (Earned vs. Spent).
- **Typography:** `body-lg` for the title, `label-md` for the date, and `numbers-md` for the value (Green for positive, Charcoal for negative).

### Level Badge (Premium Geometric)
- **Styling:** A distinct geometric shape (e.g., a soft hexagon or diamond) containing the level number.
- **Kids Theme:** Transition to a circular badge with a thicker, "squishy" border.
- **Coloring:** Uses the Accent (Amber) or Primary color with a subtle metallic sheen effect to feel like an achievement.

### Additional Components
- **Habit Chips:** Small 12dp rounded filters for viewing rewards by category.
- **Approval Modal:** A Level 3 dialog with clear "Approve" and "Reject" actions, using adaptive platform buttons.