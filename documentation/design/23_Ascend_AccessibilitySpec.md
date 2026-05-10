# Ascend — Accessibility Specification

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers, QA |
| Compliance Target | WCAG 2.1 Level AA |
| Purpose | Concrete accessibility requirements that translate the standard into our specific product. |

> Accessibility is not a checklist applied after the design is done. It's a series of decisions baked into every design and engineering choice. This document captures those decisions so they don't get forgotten.

---

## 1. Why This Matters Specifically for Ascend

Beyond legal compliance and ethics, Ascend's user base includes:
- Students with low-bandwidth screen readers on Android
- Users on small screens with tired eyes after long study days
- Faculty members who may be older and benefit from larger type
- Users with temporary impairments (broken arm, eye strain, distracting environments)

Accessibility benefits everyone, not only people with permanent disabilities. We design for it.

---

## 2. Compliance Targets

**Primary:** WCAG 2.1 Level AA across all user-facing surfaces.

**Aspirational:** WCAG 2.1 Level AAA where practical without trading off other principles.

**Beyond WCAG:** patterns recommended by the GOV.UK Service Manual, the Inclusive Components book by Heydon Pickering, and modern Radix/shadcn primitives.

---

## 3. Color & Contrast

### 3.1 Text Contrast Ratios

| Text size | Minimum ratio (AA) |
|---|---|
| Body (< 18pt regular or < 14pt bold) | 4.5:1 |
| Large (≥ 18pt regular or ≥ 14pt bold) | 3:1 |
| Disabled state | No requirement (but we still aim for 3:1 for usability) |

Verified against Design System Foundations § 1.6.

### 3.2 Non-Text Contrast

UI components and meaningful graphical objects: **3:1 minimum** against adjacent colors.

Includes:
- Form input borders against background
- Focus indicators
- Icons that convey meaning
- Charts and data visualizations

### 3.3 Color Alone is Never the Cue

Whenever color carries information, an additional cue is required:
- Persona indicator: tint **plus** icon **plus** label
- Vote state: color **plus** filled icon (vs outline)
- Form errors: red color **plus** error icon **plus** error text
- Required fields: red asterisk **plus** "required" text in `aria-required`
- Link text in body: color **plus** underline (especially within paragraph text)

### 3.4 Dark Mode Note

Not in v1. When implemented, will independently meet AA contrast in dark colors.

---

## 4. Typography

### 4.1 Resizable Text

All text resizes correctly when the browser zooms or text is enlarged via OS settings (up to 200% zoom). No fixed pixel values that prevent scaling. Use `rem` units throughout.

### 4.2 Line Length

Reading content (questions, answers, posts): max ~75 characters per line at default font size. Achieved via `container-md` (~720px) at the standard reading size.

### 4.3 Line Height

Body text: minimum 1.5 line-height (per Design System: `leading-normal` = 1.5; `leading-relaxed` = 1.7 for reading).

### 4.4 Reading Order

- DOM order matches visual order. CSS may shift presentation, but tab order and screen reader reading remain logical.
- Left-to-right by default; we don't ship RTL in v1 but design with awareness (logical properties used).

### 4.5 Lowercase / Uppercase

- We don't use ALL CAPS for body content.
- Tags may use lowercase or hyphenated; presentation is the source. Screen readers read tags as written.
- Brand voice prefers sentence case for buttons and headings ("Ask a question," not "ASK A QUESTION" or "Ask a Question").

---

## 5. Keyboard Accessibility

### 5.1 Universal Requirements

- Every interactive element reachable via Tab.
- Every interactive element activatable via Enter (links, buttons) or Space (buttons, checkboxes, switches).
- Tab order matches visual order and reading flow.
- Focus visible at all times during keyboard navigation (via `:focus-visible`).
- No keyboard traps. User can always Tab out of any component, with Escape providing additional escape from dialogs and menus.

### 5.2 Skip Links

A "Skip to main content" link is the first focusable element on every page. Visually hidden until focused; then visible at top-left.

```html
<a href="#main" class="skip-link">Skip to main content</a>
```

### 5.3 Focus Management

Specific patterns from the Component Library that need explicit focus management:

| Pattern | Behavior |
|---|---|
| Modal opens | Focus moves to first focusable element in modal (or modal heading) |
| Modal closes | Focus returns to the element that triggered the modal |
| Drawer opens | Same as modal |
| Toast appears | Focus does NOT change (toast is non-interactive by default) |
| Toast with action button | Focus does NOT auto-move; user can Tab to it |
| Form submitted with errors | Focus moves to first invalid field |
| Page navigation | Focus moves to main page heading or skip link |
| Search opens (mobile full-screen) | Focus moves to search input |
| Dropdown opens | Focus moves to first menu item; Up/Down arrows navigate |
| New content arrives via WebSocket | Focus does NOT auto-move; an `aria-live` region announces |

### 5.4 Visible Focus Indicators

- 3px solid ring in `--color-border-focus`, 2px outset (per Design System).
- Visible against all backgrounds we use.
- Never removed without replacement (no `outline: none` without alternative).
- Applied via `:focus-visible` so mouse users don't see rings on every click.

### 5.5 Custom Components

Custom interactive components (Tag Picker, Vote Control, Markdown Editor toolbar) implement full keyboard support:

- **Tag Picker:** typeahead supports keyboard nav (Up/Down through suggestions, Enter to select, Backspace removes last selected, Escape closes suggestions).
- **Vote Control:** Up/Down arrows toggle votes when focused; Enter activates; Space activates.
- **Markdown Editor toolbar:** Tab through toolbar; Arrow keys within toolbar; standard formatting shortcuts (Cmd+B, Cmd+I, Cmd+K).

---

## 6. Screen Reader Support

### 6.1 Semantic HTML First

We use semantic HTML before reaching for ARIA. The order of preference:

1. Native HTML elements with their default roles (`<button>`, `<a>`, `<nav>`, `<main>`, `<article>`, `<section>`, `<form>`, `<label>`).
2. Native elements with attributes (`<input type="email">` over generic `<input type="text">`).
3. ARIA only when native HTML can't express the pattern.

### 6.2 Landmarks

Every page has the standard landmarks:

```html
<header>...</header>     <!-- top navigation -->
<nav aria-label="Main">...</nav>  <!-- if separate from header -->
<main id="main">...</main>  <!-- target of skip link -->
<aside>...</aside>       <!-- right rail, sidebars -->
<footer>...</footer>
```

A user navigating via screen reader landmarks should be able to jump directly to the main content.

### 6.3 Headings

- One `<h1>` per page (the page title).
- Headings nest properly (h1 → h2 → h3 — never skip levels).
- Visual size doesn't dictate heading level. Use semantic level for structure; style separately if needed.

### 6.4 Lists

Lists of items use `<ul>` or `<ol>`. Cards in feeds are list items. Comments in a thread are list items.

### 6.5 Images and Icons

| Type | Treatment |
|---|---|
| Decorative image | `alt=""` (empty alt; screen readers skip) |
| Informative image | Descriptive `alt` |
| Icon with adjacent text label | Icon is decorative; `aria-hidden="true"` |
| Icon-only button | `aria-label` describes the action |
| Icon-only link | `aria-label` describes the destination |
| Avatar | `alt` with the user's name |
| Persona indicator overlay on avatar | Included in `aria-label` of parent ("Avatar, Alice Roy, Student") |

### 6.6 Forms

- Every input has a `<label>`.
- Labels visually present (not just placeholder text).
- Helper text linked via `aria-describedby`.
- Error text linked via `aria-describedby` and `aria-invalid="true"`.
- Required fields: `aria-required="true"` plus visible asterisk.
- Fieldsets group related controls (e.g., radio groups) with `<legend>`.

### 6.7 Live Regions

Dynamic content uses `aria-live` regions to announce changes:

| Element | Live setting |
|---|---|
| Toast (success/info) | `aria-live="polite"` (`role="status"`) |
| Toast (error) | `aria-live="assertive"` (`role="alert"`) |
| Notification badge count change | `aria-live="polite"` on a sr-only text node ("3 unread notifications") |
| New message received | `aria-live="polite"` summary ("New message from Alice") — single-line, doesn't include full content |
| Form submission result | `aria-live="polite"` |
| Loading state changes | `aria-busy="true"` on the loading element |

We are conservative with `assertive`: only for errors that interrupt user actions.

### 6.8 Anonymous Authors

When a question is anonymous, screen reader hears "Anonymous Student" — not the actual user's name (which is hidden from all readers).

---

## 7. Component-Specific Accessibility

### 7.1 Button

- Native `<button>` element.
- `type="button"` unless inside a form where submit is desired (then `type="submit"`).
- `aria-disabled` rather than `disabled` when we want screen reader to announce it but keep it focusable in some contexts (rare).

### 7.2 Vote Control

```html
<div role="group" aria-label="Vote on question">
  <button aria-label="Upvote" aria-pressed="false">↑</button>
  <span aria-live="polite">12</span>
  <button aria-label="Downvote" aria-pressed="false">↓</button>
</div>
```

`aria-pressed` reflects the user's vote state. The vote count announces on change.

### 7.3 Tabs

Use Radix or shadcn Tabs primitive (handles `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`, `aria-controls` correctly).

### 7.4 Modal Dialog

- `role="dialog"` with `aria-modal="true"`.
- `aria-labelledby` points to dialog heading.
- `aria-describedby` points to body text.
- Focus trap within modal.
- Escape closes modal.

### 7.5 Tooltips

- `aria-describedby` linking trigger to tooltip text.
- Tooltip appears on hover AND focus (not hover only).
- Not the only place critical information lives.

### 7.6 Notifications List

- Each notification is a list item.
- Read/unread state communicated via text in screen reader output ("Unread: Alice answered your question, 2 hours ago").

### 7.7 DM Thread

- Message list as `role="log"` (or just `<ol>`) with `aria-live="polite"`.
- Each message identifies sender and time in screen reader output.
- "Other party typing" announced once when state changes, not continuously.

### 7.8 Markdown Editor

- Toolbar uses `role="toolbar"` with grouped buttons.
- Each button has `aria-label`.
- Preview tab and Edit tab use ARIA tabs pattern.

### 7.9 Custom Dropdowns / Comboboxes

- Use Radix or shadcn primitives (handle ARIA combobox pattern correctly).
- Listbox role, option roles, `aria-activedescendant` for keyboard nav.

---

## 8. Touch and Pointer

### 8.1 Touch Target Size

WCAG 2.5.5 (Level AAA): minimum 44x44 CSS pixels.

We meet this for all touch targets, including:
- Bottom navigation icons (full-tab tappable)
- Vote arrows
- Action menu triggers (three-dot icons get padding)
- Inline links in dense lists (sufficient line-height creates target)

Where two interactive elements are stacked or adjacent, at least 8px gap between them.

### 8.2 Pointer Cancellation

For destructive or significant actions, the action triggers on pointer-up (release), not pointer-down. This allows users to cancel a tap by sliding their finger away. (This is the browser's default for buttons; we don't override.)

### 8.3 No Hover-Only Interactions

Anything available on hover is also available on tap. Tooltips that supplement information (not replace it) are exempted.

---

## 9. Motion & Animation

### 9.1 prefers-reduced-motion

When the user's OS sets `prefers-reduced-motion: reduce`:

- Page transitions become instant.
- Toast slide-in becomes a fade only.
- Modal scale-in becomes opacity only.
- Skeleton pulse animations are disabled (skeletons are static).
- Vote bump animations are disabled (count changes instantly).
- All animations longer than 150ms reduce to ≤ 150ms or disappear entirely.

### 9.2 Auto-Playing Content

- No auto-playing video.
- No auto-scrolling carousels.
- No auto-redirecting timers (e.g., "redirecting in 5...").
- No infinite-looping decorative animations except subtle skeleton pulse (which respects reduced-motion).

### 9.3 Vestibular Safety

Avoid:
- Parallax scrolling.
- Large-scale zoom or rotation animations.
- Strobing or flashing content (especially anything that flashes more than 3 times per second — WCAG 2.3.1 hard requirement).

---

## 10. Forms in Depth

### 10.1 Required Field Indication

- Visible asterisk (red) after the label.
- Tooltip on asterisk: "Required."
- `aria-required="true"` on the input.
- Form-level helper if appropriate: "Fields marked with * are required."

### 10.2 Error Messaging

Pattern for an invalid field:

```html
<div class="form-field">
  <label for="email">Email <span aria-hidden="true">*</span></label>
  <input
    id="email"
    type="email"
    aria-required="true"
    aria-invalid="true"
    aria-describedby="email-error email-helper"
  />
  <div id="email-helper" class="helper-text">We'll send a verification link.</div>
  <div id="email-error" class="error-text">
    <Icon aria-hidden /> Please enter a valid email address.
  </div>
</div>
```

### 10.3 Inline Validation Timing

- On blur for single-field validation.
- On submit for cross-field validation.
- Never on every keystroke (anxiety-inducing for slow typists, especially screen reader users).

### 10.4 Auto-Complete

Use HTML autocomplete attributes:

```html
<input type="email" autocomplete="email">
<input type="password" autocomplete="current-password">
<input type="password" autocomplete="new-password"> <!-- in signup -->
<input type="text" autocomplete="name">
<input type="tel" autocomplete="tel">
```

### 10.5 Long Text Inputs

- Allow expanding (textarea auto-grow).
- Don't auto-correct silently (acceptable to enable browser native, but no custom intercept).
- Word and character count where limits apply.

---

## 11. Time Limits

### 11.1 Session Timeout
- 30-day sliding session (per Auth Spec) — long enough that timeout is rare.
- If shorter timeouts ever introduced: warning at 5 minutes before expiry; option to extend.

### 11.2 Form Timeouts
- Forms don't have client-side time limits.
- Server may rate-limit (per minute / hour); we communicate the limit, not a timer.

### 11.3 Verification Token Expiry
- Email verification: 24 hours.
- Password reset: 1 hour.
- MFA setup verification: not time-limited by us within the setup flow.

---

## 12. Multimedia

### 12.1 No Video / Audio Content in v1
We don't produce or host video. No accessibility concerns specific to multimedia until that changes.

### 12.2 If Added Later
- Captions for all video.
- Transcripts for audio.
- Audio descriptions where visual content is essential.
- No autoplay.

---

## 13. Mobile-Specific Accessibility

### 13.1 Screen Reader on Mobile
- TalkBack (Android) and VoiceOver (iOS) support is a primary requirement.
- Test on real devices, not just simulators.
- Bottom nav items use proper labels (not just icons).

### 13.2 Touch Exploration
- Screen reader users explore by touching different elements; ensure each has a clear label and announced state.

### 13.3 Magnification
- Pinch-zoom not disabled (no `user-scalable=no` in viewport).
- Layout reflows correctly at 200% zoom without horizontal scrolling for primary content.

### 13.4 Orientation
- Portrait and landscape both supported.
- Critical actions visible in both orientations.

---

## 14. Cognitive Accessibility

### 14.1 Plain Language

- Avoid jargon. ("Dynamic Seniority Engine" is internal — UI says "You can answer questions from earlier semesters and from faculty/alumni.")
- Sentences short. Paragraphs short.
- Active voice over passive.

### 14.2 Predictable Navigation

- Same elements in the same place across pages.
- Same affordances behave the same way.
- Surprises are minimized.

### 14.3 Error Prevention

- Confirmations for irreversible actions.
- Clear undo where possible.
- Form validation that catches errors before submit, with chance to fix.

### 14.4 Help and Support

- Help link visible in user menu.
- Contextual help text on complex forms.
- Error messages explain what to do, not just what's wrong.

---

## 15. Internationalization Hooks

We launch in English only but build with i18n in mind:

- All user-facing strings extracted to a translation file.
- Date and time formatting via `Intl.DateTimeFormat` (handles locale).
- Number formatting via `Intl.NumberFormat`.
- No string concatenation that assumes English grammar ("3 questions" — use ICU MessageFormat for plurals).
- CSS uses logical properties (`margin-inline-start` over `margin-left`) where it doesn't add complexity.
- RTL support is not v1 but the foundation doesn't preclude it.

---

## 16. Testing & Verification

### 16.1 Automated Testing

- `@axe-core/playwright` runs against representative pages in CI.
- Common rules enforced; violations fail CI.
- Lighthouse accessibility score > 95 on key pages.

### 16.2 Manual Testing

Per release, manually verify:

- **Keyboard:** Navigate the full primary flows (signup, ask, answer, search, send DM) using only the keyboard.
- **Screen reader:** NVDA on Windows, VoiceOver on macOS, TalkBack on Android. Walk through key screens.
- **Zoom:** Browser zoom to 200%; verify no horizontal scroll on main content.
- **Reduced motion:** Set OS preference; verify animations behave.
- **High contrast:** Test on Windows High Contrast mode.

### 16.3 User Testing

When we conduct user testing, include participants who use assistive technology. Their feedback uncovers issues automated tools miss.

---

## 17. Common Failures to Watch For

These are issues that frequently slip through:

- **Missing focus indicator on custom interactive elements** — verify every clickable thing has visible focus.
- **Modal traps focus but doesn't return it on close** — check after every modal close.
- **`aria-label` overriding visible text** — when both exist, screen reader should hear the visible text.
- **Color-coded data** without alternative — pie charts without legends, status indicated only by hue.
- **Click handlers on non-button elements** — `<div onClick>` is the most common. Use `<button>`.
- **Helper text disappearing on focus** — placeholder text vanishes when typing; if it was the label, screen reader users lose it.
- **Auto-playing motion** that doesn't honor reduced-motion preference.
- **Touch targets too small** at default font size — verify with finger on actual phone.

---

## 18. Documentation in Components

Each component in our library includes accessibility notes (per Component Library doc). When a developer uses a component, they can read its accessibility behavior in the doc.

When something violates accessibility (e.g., temporarily disabled feature for a constraint), the issue is filed and visible in the project's `TECH_DEBT.md`.

---

## 19. The Standard Isn't Sacred — But It Is the Floor

WCAG 2.1 AA is our floor. We can exceed it. We should not be below it.

If a design choice clearly improves usability for most users and might fall short of AA in a narrow technical sense, we discuss it explicitly and document the decision. We don't silently accept failures.

When a tension arises between visual aesthetic and accessibility, accessibility wins by default.
