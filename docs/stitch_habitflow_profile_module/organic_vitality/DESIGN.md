---
name: Organic Vitality
colors:
  surface: '#FFFFFF'
  surface-dim: '#dadad9'
  surface-bright: '#faf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f2'
  surface-container: '#eeeeed'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e3e2e1'
  on-surface: '#1a1c1c'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f0f0'
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
  background: '#faf9f8'
  on-background: '#1a1c1c'
  surface-variant: '#e3e2e1'
  success: '#22C55E'
  warning: '#F97316'
  danger: '#EF4444'
  background-dark: '#1F2937'
  kids-primary: '#00D991'
  kids-accent: '#FFC107'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
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
  body-numbers:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  caption:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
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
  button-padding: 16px
  chip-padding: 12px
  touch-target-min: 48px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 32px
---

## Brand & Style
The design system is rooted in the "Organic Vitality" style—a blend of **Minimalism** and **Corporate Modern** aesthetics tailored for a premium family experience. It prioritizes a sense of "calm growth" by utilizing heavy whitespace, a refined 8pt grid, and subtle tonal layering rather than aggressive shadows. 

The personality is approachable yet authoritative, ensuring parents feel the product is a reliable tool for family development, while the "Kids Theme" introduces higher vibrancy to stay engaging without becoming cartoonish. Visual clutter is intentionally removed to focus on "emotion through simplicity," ensuring the UI feels fast, breathable, and premium.

## Colors
The palette is centered around **Emerald Green**, symbolizing growth and vitality. 

- **Light Mode:** Uses "Warm White" (#FDFCFB) for backgrounds to reduce eye strain and create a more domestic, inviting feel than clinical pure white.
- **Dark Mode:** Transitions to "Dark Gray" (#1F2937) to maintain depth while preserving the vibrancy of the Emerald primary.
- **Kids Theme:** Utilizes higher saturation variants of the primary and accent colors to evoke energy and playfulness, while maintaining the same structural layout for familiarity.
- **Functional Colors:** Success, Warning, and Danger colors follow standard semantic patterns but are slightly desaturated to fit the "calm" brand pillar.

## Typography
The system uses **Inter** exclusively to ensure maximum legibility across Flutter’s adaptive engine on both iOS and Android. 

- **Hierarchy:** Distinct weight jumps (from 400 to 600/700) define the hierarchy rather than excessive color changes.
- **Numbers:** Habit tracking requires clear data visualization; use `Medium` (500) weight for all numerical data to ensure they stand out within body text.
- **Accessibility:** All type scales are designed to scale with system settings. Headers use slight negative letter spacing to feel tighter and more "editorial" at larger sizes.

## Layout & Spacing
This design system employs a **Fluid Grid** based on an **8pt rhythm**. 

- **Grid:** A 4-column grid is used for mobile, expanding to 8 or 12 for tablets. 
- **Consistency:** Spacing is strictly derived from the base 8px unit. However, component-specific paddings (20px for cards, 16px for buttons) are prioritized to ensure a "roomy" and premium feel.
- **Touch Targets:** A 48dp minimum touch target is enforced for all interactive elements, regardless of their visual size, to ensure ease of use for both children and parents.
- **Safe Areas:** Implementation must use Flutter's `SafeArea` or `MediaQuery` padding to ensure content is never obscured by notches or home indicators.

## Elevation & Depth
In alignment with Adaptive Material Design 3, elevation is conveyed through **Tonal Layers** and extremely soft **Ambient Shadows**.

- **Level 0 (Background):** The base layer, using the "Warm White" surface.
- **Level 1 (Cards):** Standard interactive containers. Use a subtle 1px border or a very soft, low-opacity shadow to separate from the background.
- **Level 2 (Floating/Active):** Reserved for items being dragged or high-priority status cards.
- **Level 3 (Overlays):** Dialogs and Bottom Sheets. These use a backdrop dim (scrim) and a higher tonal elevation to focus the user’s attention.
- **Performance:** Avoid heavy blurs or complex gradients to maintain a 60 FPS target on older devices.

## Shapes
The shape language is **Rounded**, reflecting the "Family-Friendly" and "Warm" brand values. 

- **Standard Elements:** Buttons and input fields use a base roundedness of 0.5rem (8px).
- **Cards:** Use `rounded-lg` (16px - 20px) to create a soft, containerized look that feels safe and modern.
- **Chips & Tags:** Use pill-shaped (fully rounded) edges to distinguish them from actionable buttons.
- **Icons:** Must be "Material Symbols Rounded" to match the container geometry.

## Components

### Buttons
- **Primary:** Filled with Emerald Green, white text. High emphasis.
- **Secondary:** Outlined with 1.5px border in Primary color. Medium emphasis.
- **Tertiary:** Ghost/Text-only buttons for less frequent actions.
- **Sizing:** Fixed height of 48dp or 56dp for primary actions to ensure high hit-rate.

### Cards (The Core Container)
- **Styling:** 20dp internal padding, Level 1 elevation, 20dp corner radius.
- **Types:** Signature cards like the "Growth Tree" and "Family Score" should use subtle background patterns or organic illustrations to feel distinct from "Today's Habits" cards.

### Input Fields
- **Style:** Outlined Material 3 style.
- **Focus State:** 2px Emerald Green border with a subtle inner glow.
- **Adaptation:** Use native iOS pickers/date-selectors via Flutter's adaptive constructors while keeping the text field styling consistent.

### Navigation
- **Bottom Navigation:** Use 5 core destinations: Home, Habits, Goals, Rewards, Family.
- **FAB:** The "Quick Add" button is the only element allowed to use Level 2 elevation on the main dashboard.

### Progress Indicators
- **Growth Tree:** A custom organic progress component.
- **Success States:** Use the Success Green (#22C55E) and playful, fast animations to celebrate small wins.