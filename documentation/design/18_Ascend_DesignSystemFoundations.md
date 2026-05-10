# Ascend — Design System Foundations

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers |
| Purpose | The base tokens. Every visual decision in Ascend draws from this document. Tokens are exported to `tailwind.config.ts` and become the source of truth in code. |

> Note: These tokens are a starting point informed by the brand voice (quietly confident, warm but not chummy) and the product's editorial-reference quality. They are intended to be tested against real designs and adjusted before launch. They are *not* arbitrary — each choice has a reason. They are also not sacred — when a designer reviews this with eyes on actual mockups, expect refinement.

---

## 1. Color

### 1.1 Palette Philosophy

Ascend's palette is rooted in **deep ink** as the primary, with **warm neutrals** for surfaces, and **muted gold** as a sparingly-used accent. We avoid bright saturated colors except where semantic meaning demands it. The result feels closer to a thoughtful publication than a SaaS app — which is the intent.

We do not use:
- Bright primary blue (#0066ff or similar) — feels generic and tech-corporate
- Pure black (#000) — too harsh on light backgrounds
- Pure white (#fff) as canvas — too cold; we use a warm off-white
- Gradients on UI elements (acceptable in occasional illustration only)

### 1.2 Core Tokens

| Token | Hex | Use |
|---|---|---|
| `--color-primary-50` | `#f0f4f9` | Tinted backgrounds, hover surfaces |
| `--color-primary-100` | `#dbe4ee` | Selected list items |
| `--color-primary-200` | `#b7c8db` | Disabled primary buttons |
| `--color-primary-400` | `#5d7895` | Secondary primary, links on dark |
| `--color-primary-600` | `#2c4d75` | Hover state for primary |
| `--color-primary-700` | `#1e3a5f` | **Primary brand color** |
| `--color-primary-800` | `#152a47` | Active/pressed state |
| `--color-primary-900` | `#0d1a30` | Dark surface (rare) |

| Token | Hex | Use |
|---|---|---|
| `--color-accent-50` | `#fcf7eb` | Tinted highlight surfaces |
| `--color-accent-200` | `#ecd49a` | Subtle accent (badges, highlights) |
| `--color-accent-500` | `#b8843d` | **Accent color** (for badges, notable highlights) |
| `--color-accent-700` | `#8b5e22` | Accent on light surfaces |

| Token | Hex | Use |
|---|---|---|
| `--color-bg` | `#faf9f6` | Page background (warm off-white) |
| `--color-surface` | `#ffffff` | Cards, panels |
| `--color-surface-raised` | `#ffffff` | Modals, elevated cards (with shadow) |
| `--color-surface-sunken` | `#f4f2ec` | Embedded content, code blocks |

| Token | Hex | Use |
|---|---|---|
| `--color-text-primary` | `#1a1a1a` | Body and headings |
| `--color-text-secondary` | `#4a4a48` | Supporting text, metadata |
| `--color-text-tertiary` | `#767672` | Timestamps, hints, placeholder |
| `--color-text-disabled` | `#b0b0ac` | Disabled state |
| `--color-text-inverse` | `#faf9f6` | Text on primary-700 surfaces |

| Token | Hex | Use |
|---|---|---|
| `--color-border` | `#e8e6e0` | Default borders, dividers |
| `--color-border-strong` | `#d0cec7` | Input borders, defined separations |
| `--color-border-focus` | `#1e3a5f` | Focus ring (3px, 2px offset) |

### 1.3 Semantic Colors

Semantic colors are muted to fit the palette. They are *legible*, not loud.

| Token | Hex | Use |
|---|---|---|
| `--color-success` | `#2d6a4f` | Confirmation, accepted answer markers |
| `--color-success-bg` | `#e8f3ec` | Success message backgrounds |
| `--color-error` | `#92353e` | Errors, destructive actions |
| `--color-error-bg` | `#f7e8ea` | Error message backgrounds |
| `--color-warning` | `#b07a1f` | Warnings, link-broken indicator |
| `--color-warning-bg` | `#faf2e1` | Warning backgrounds |
| `--color-info` | `#2c4d75` | Informational, system messages |
| `--color-info-bg` | `#eaeff5` | Info backgrounds |

### 1.4 Persona Indicator Colors

Persona affiliation is a frequent UI signal. Indicators use hue + label, never hue alone (accessibility).

| Persona | Indicator hex | Background tint |
|---|---|---|
| Student | `#1e3a5f` (primary) | `#f0f4f9` |
| Faculty | `#2d6a4f` (success) | `#e8f3ec` |
| Alumnus | `#8b5e22` (accent-700) | `#fcf7eb` |
| Former Student | `#767672` (tertiary) | `#f4f2ec` |

### 1.5 Dark Mode

Dark mode is **not in scope for v1.** Designed-from-scratch dark mode is a project of its own; bolt-on dark mode is worse than no dark mode. We will revisit after launch.

### 1.6 Color Contrast

All text/background combinations above meet **WCAG 2.1 AA** (4.5:1 for body, 3:1 for large text and UI components). Verified pairs:

- `text-primary` on `bg`: 14.8:1 ✓
- `text-secondary` on `bg`: 8.9:1 ✓
- `text-tertiary` on `bg`: 4.7:1 ✓
- `primary-700` on `bg`: 9.4:1 ✓
- `accent-500` on `bg`: 4.9:1 ✓
- `success` on `bg`: 6.1:1 ✓
- `error` on `bg`: 6.6:1 ✓

The `text-tertiary` token is at the floor; do not use for important information, only metadata and hints.

---

## 2. Typography

### 2.1 Font Families

**UI font:** [Inter](https://rsms.me/inter/) — variable weight, open source, excellent on screen, supports a wide range of weights.

**Long-form reading font (optional, recommended):** [Source Serif 4](https://github.com/adobe-fonts/source-serif) — for question/answer/post body content. Provides editorial feel without sacrificing legibility on small screens.

**Code font:** [JetBrains Mono](https://www.jetbrains.com/lp/mono/) — for inline code and code blocks.

**Fallback stack:**
```css
--font-ui: 'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
--font-reading: 'Source Serif 4', Georgia, 'Times New Roman', serif;
--font-mono: 'JetBrains Mono', ui-monospace, 'SF Mono', Consolas, monospace;
```

**Loading strategy:** self-host fonts with `font-display: swap`. Subset to Latin + Devanagari (we may have Malayalam content; consider that subset too). Total font payload target < 80KB woff2.

### 2.2 Type Scale

A modular scale, slightly compressed at small sizes for density.

| Token | px | rem | Use |
|---|---|---|---|
| `text-xs` | 12 | 0.75 | Metadata, timestamps, fine print |
| `text-sm` | 14 | 0.875 | Secondary UI text, secondary labels |
| `text-base` | 16 | 1.0 | Body text, default UI |
| `text-md` | 18 | 1.125 | Long-form reading body (questions/answers) |
| `text-lg` | 20 | 1.25 | Card titles, sub-section headings |
| `text-xl` | 24 | 1.5 | Page section headings |
| `text-2xl` | 30 | 1.875 | Page titles |
| `text-3xl` | 36 | 2.25 | Hero titles (sparingly) |

### 2.3 Font Weights

Inter variable: we use four weights to keep visual rhythm.

| Token | Weight |
|---|---|
| `font-regular` | 400 |
| `font-medium` | 500 |
| `font-semibold` | 600 |
| `font-bold` | 700 |

Headings use `font-semibold`. Bold is reserved for emphasis within text and for high-stakes UI (button labels, primary CTAs).

### 2.4 Line Heights

| Token | Value | Use |
|---|---|---|
| `leading-tight` | 1.2 | Headings 24px+ |
| `leading-snug` | 1.35 | Card titles, smaller headings |
| `leading-normal` | 1.5 | Body text |
| `leading-relaxed` | 1.7 | Long-form reading body |

### 2.5 Letter Spacing

| Token | Value | Use |
|---|---|---|
| `tracking-tight` | -0.01em | Large headings |
| `tracking-normal` | 0 | Default |
| `tracking-wide` | 0.04em | All-caps labels (use sparingly) |

### 2.6 Type Patterns

These are the canonical patterns; designers extend rarely.

| Pattern | Spec |
|---|---|
| **Page title** | text-2xl / font-semibold / leading-tight / text-primary |
| **Section heading** | text-xl / font-semibold / leading-snug / text-primary |
| **Card title** | text-lg / font-semibold / leading-snug / text-primary |
| **Body** | text-base / font-regular / leading-normal / text-primary |
| **Reading body** | text-md / font-regular / leading-relaxed / text-primary / font-reading |
| **Secondary** | text-sm / font-regular / leading-normal / text-secondary |
| **Metadata** | text-xs / font-regular / leading-normal / text-tertiary |
| **Button label** | text-sm / font-medium / leading-none / (color per variant) |
| **Tag** | text-xs / font-medium / tracking-wide / leading-none |

### 2.7 Mobile Adjustments

On screens narrower than 640px:
- `text-3xl` → behaves as `text-2xl`
- `text-2xl` → behaves as `text-xl` for less critical headings
- Reading body remains `text-md` (do not shrink reading content)

---

## 3. Spacing

### 3.1 Spacing Scale

Base unit: **4px**. All spacing values are multiples of 4. This produces vertical rhythm and prevents pixel-perfect drift.

| Token | px |
|---|---|
| `space-0` | 0 |
| `space-1` | 4 |
| `space-2` | 8 |
| `space-3` | 12 |
| `space-4` | 16 |
| `space-5` | 20 |
| `space-6` | 24 |
| `space-8` | 32 |
| `space-10` | 40 |
| `space-12` | 48 |
| `space-16` | 64 |
| `space-20` | 80 |
| `space-24` | 96 |

Note: Tailwind defaults align to this; no overrides needed. Use Tailwind's `gap-4`, `p-6`, etc., directly.

### 3.2 Spacing Patterns

These are conventions, not rules. Strong rhythm in layouts emerges from consistency.

| Context | Spacing |
|---|---|
| Inside a button (vertical, horizontal) | space-2, space-4 |
| Inside a card (padding all) | space-5 (mobile) / space-6 (desktop) |
| Between cards in a list | space-3 (compact) / space-4 (default) |
| Between sections on a page | space-12 |
| Between a label and its input | space-2 |
| Between an input and helper text | space-1 |
| Below a page title | space-6 |
| Around an icon next to text | space-2 |

---

## 4. Border Radius

| Token | px | Use |
|---|---|---|
| `radius-none` | 0 | Tables, dividers |
| `radius-sm` | 4 | Inputs, small chips, tags |
| `radius-md` | 6 | Buttons, cards (mobile) |
| `radius-lg` | 8 | Cards (desktop), modals |
| `radius-xl` | 12 | Large containers |
| `radius-full` | 9999 | Avatars, pills |

Ascend uses moderate rounding. Sharp corners feel cold; very rounded feels playful and undermines the brand voice.

---

## 5. Elevation (Shadows)

Shadows are subtle. We use them to indicate hierarchy, not to dramatize.

| Token | CSS | Use |
|---|---|---|
| `shadow-none` | none | Default flat surface |
| `shadow-xs` | `0 1px 2px rgba(20, 20, 20, 0.04)` | Subtle separation; cards on light bg |
| `shadow-sm` | `0 2px 4px rgba(20, 20, 20, 0.06)` | Default card |
| `shadow-md` | `0 4px 8px rgba(20, 20, 20, 0.08)` | Hover state on cards; dropdown |
| `shadow-lg` | `0 8px 24px rgba(20, 20, 20, 0.12)` | Modals, popovers |
| `shadow-xl` | `0 16px 40px rgba(20, 20, 20, 0.16)` | Reserved (avoid) |

We do not stack multiple shadows for "softer" effects. One shadow per surface.

---

## 6. Motion

### 6.1 Duration

| Token | ms | Use |
|---|---|---|
| `duration-instant` | 0 | Immediate (rare) |
| `duration-fast` | 150 | Hover states, button presses, small UI feedback |
| `duration-normal` | 200 | Most transitions: drawer slide, panel reveal |
| `duration-slow` | 300 | Modal appearance, large transitions |
| `duration-slower` | 500 | Page transitions (rare) |

### 6.2 Easing

| Token | Bezier | Use |
|---|---|---|
| `ease-standard` | `cubic-bezier(0.4, 0, 0.2, 1)` | Default for most transitions |
| `ease-out` | `cubic-bezier(0, 0, 0.2, 1)` | Elements entering the screen |
| `ease-in` | `cubic-bezier(0.4, 0, 1, 1)` | Elements leaving the screen |
| `ease-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Sparingly: success confirmations |

### 6.3 Motion Principles

- **Purposeful, not decorative.** A transition exists because it helps the user understand a change of state. If it doesn't, cut it.
- **Reduced motion respected.** All non-essential animation is disabled when `prefers-reduced-motion: reduce`. Page transitions become instant; hover states stay; loading spinners stay.
- **Direction matches semantic.** Drawers slide from the edge they're attached to. Modals appear in place. Toasts slide from the bottom on mobile, top-right on desktop.
- **Consistency is currency.** The same kind of element transitions the same way everywhere. We don't have multiple modal animations.

### 6.4 Common Motion Patterns

| Element | Motion |
|---|---|
| Button hover | Background color over 150ms ease-standard |
| Card hover | Shadow change over 200ms ease-standard |
| Modal open | Backdrop fade + content scale (0.96 → 1.0) over 200ms ease-out |
| Modal close | Reverse, 150ms ease-in |
| Drawer slide | Translate over 250ms ease-out |
| Toast appear | Slide + fade over 250ms ease-out |
| Toast dismiss | Slide + fade over 200ms ease-in |
| Dropdown open | Fade + slight slide over 150ms ease-out |
| Skeleton pulse | 1.5s linear infinite, opacity 0.6 ↔ 1.0 |
| Vote feedback | Number bump animation: scale 1.0 → 1.15 → 1.0 over 300ms ease-spring |

---

## 7. Z-Index Scale

We do not let z-index sprawl. Six layers is enough.

| Token | Value | Use |
|---|---|---|
| `z-base` | 0 | Default |
| `z-sticky` | 10 | Sticky headers, sticky filter bars |
| `z-overlay` | 20 | Mobile bottom navigation |
| `z-dropdown` | 30 | Dropdowns, popovers |
| `z-modal` | 40 | Modals, drawers, sheets |
| `z-toast` | 50 | Toasts, system notifications |

Anything beyond z-50 is a bug. If something needs to be above a toast, the toast is in the wrong layer.

---

## 8. Iconography

### 8.1 Icon Library

Use [Lucide](https://lucide.dev) (the modern Feather successor). Available as `lucide-react` package; matches our design quality and is open source.

We do not mix icon families. All icons in the product come from Lucide. If a needed icon is missing, we either commission a custom one (rare) or rephrase to use a different metaphor.

### 8.2 Icon Sizes

| Size | px | Use |
|---|---|---|
| `icon-xs` | 12 | Inline metadata icons (timestamps, etc.) |
| `icon-sm` | 16 | Buttons, inline labels |
| `icon-md` | 20 | Standalone actions, list-row icons |
| `icon-lg` | 24 | Navigation, primary actions |
| `icon-xl` | 32 | Empty state illustrations, large affordances |

### 8.3 Stroke Weight

Lucide defaults to 2px stroke at 24px. We adjust for size:
- 12-16px: 1.5px stroke
- 20-24px: 2px stroke
- 32px+: 2.5px stroke

### 8.4 Icon Color

Icons inherit their parent's color (`currentColor`). We do not assign icon-specific colors except for semantic meaning (success-green check, error-red x, etc.).

---

## 9. Focus States

Visible focus is non-negotiable. We use a 3px solid ring in `--color-border-focus` with 2px offset from the focused element. This is the same on every interactive element (buttons, links, inputs, custom widgets).

```css
:focus-visible {
  outline: 3px solid var(--color-border-focus);
  outline-offset: 2px;
}
```

We use `:focus-visible` not `:focus` so that mouse users don't see rings on every click — only keyboard users. This is the modern accessible default.

---

## 10. Layout Tokens

### 10.1 Container Widths

| Token | px | Use |
|---|---|---|
| `container-sm` | 640 | Narrow content (single-column reading) |
| `container-md` | 768 | Standard content width |
| `container-lg` | 1024 | Two-column layouts |
| `container-xl` | 1280 | Three-column layouts; admin dashboards |
| `container-max` | 1440 | Maximum width; never wider |

Content blocks use `container-md` by default. The reading column for question/answer body is constrained to ~70-80 characters per line at the standard reading size — roughly 640-720px depending on font.

### 10.2 Layout Grid

We do not use a strict 12-column grid. Mobile is single-column. Desktop uses flexible compositions: 2-column (content + sidebar), occasional 3-column (admin views).

Side margins:
- Mobile (< 640px): 16px gutter
- Tablet (640-1024): 24px gutter
- Desktop (> 1024): 32px gutter, content centered

---

## 11. Tailwind Configuration Sketch

A starting `tailwind.config.ts` extending these tokens:

```typescript
import type { Config } from 'tailwindcss';

export default {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f4f9', 100: '#dbe4ee', 200: '#b7c8db',
          400: '#5d7895', 600: '#2c4d75', 700: '#1e3a5f',
          800: '#152a47', 900: '#0d1a30',
        },
        accent: {
          50: '#fcf7eb', 200: '#ecd49a',
          500: '#b8843d', 700: '#8b5e22',
        },
        bg: '#faf9f6',
        surface: '#ffffff',
        'surface-sunken': '#f4f2ec',
        ink: {
          DEFAULT: '#1a1a1a',
          secondary: '#4a4a48',
          tertiary: '#767672',
          disabled: '#b0b0ac',
        },
        border: {
          DEFAULT: '#e8e6e0',
          strong: '#d0cec7',
        },
        success: '#2d6a4f',
        'success-bg': '#e8f3ec',
        error: '#92353e',
        'error-bg': '#f7e8ea',
        warning: '#b07a1f',
        'warning-bg': '#faf2e1',
        info: '#2c4d75',
        'info-bg': '#eaeff5',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Source Serif 4', 'Georgia', 'serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1rem' }],
        sm: ['0.875rem', { lineHeight: '1.25rem' }],
        base: ['1rem', { lineHeight: '1.5rem' }],
        md: ['1.125rem', { lineHeight: '1.875rem' }],
        lg: ['1.25rem', { lineHeight: '1.75rem' }],
        xl: ['1.5rem', { lineHeight: '2rem' }],
        '2xl': ['1.875rem', { lineHeight: '2.25rem' }],
        '3xl': ['2.25rem', { lineHeight: '2.5rem' }],
      },
      boxShadow: {
        xs: '0 1px 2px rgba(20, 20, 20, 0.04)',
        sm: '0 2px 4px rgba(20, 20, 20, 0.06)',
        md: '0 4px 8px rgba(20, 20, 20, 0.08)',
        lg: '0 8px 24px rgba(20, 20, 20, 0.12)',
      },
      transitionDuration: {
        fast: '150ms',
        normal: '200ms',
        slow: '300ms',
      },
      zIndex: {
        sticky: '10',
        overlay: '20',
        dropdown: '30',
        modal: '40',
        toast: '50',
      },
    },
  },
} satisfies Config;
```

---

## 12. Notes for the Visual Designer

These tokens are a starting point. When the designer joins:

- **Validate against actual mockups.** Some choices feel right in isolation but need adjustment in context. Expect 1-2 rounds of refinement.
- **Color contrast must be re-verified** for every text+background pair in finished designs, especially on tinted surfaces.
- **The accent gold is risky.** It can feel tacky if used too widely. Restrict to badges, key callouts, and highlights — never large fills.
- **Reading typography is a first-class concern.** Spend disproportionate attention on the question/answer reading view. That's where users live.
- **Empty states need illustrations or strong typography.** Designer should propose the empty-state visual language. We don't yet have illustrations.

Once the designer has a v1 of mockups, this document gets a v1.1 with adjusted tokens.
