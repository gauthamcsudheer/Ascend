# Ascend — Responsive Strategy

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers |
| Purpose | How Ascend adapts across screen sizes, input modes, and network conditions. |

> Ascend is mobile-first. Most users are on Android phones, often on intermittent mobile data, often holding the phone with one hand. Every layout decision starts there. Desktop is a layered enhancement, not the canonical experience.

---

## 1. Why Mobile-First Matters Here

### 1.1 The User Reality

The expected usage pattern based on the user research summarized in the PRD:

- Students between classes, on the bus, at midnight in the hostel
- Faculty checking quickly during a break, sometimes on a tablet
- Alumni on a phone during a lunch break, returning to it later from a desktop

**Common conditions:**
- 4G or slower connections
- Older Android devices (3+ years old, 4GB RAM)
- Battery-conscious browsing
- Frequent app-switching
- One-handed use
- Variable lighting (outdoors, classrooms)

These shape every design choice that follows.

### 1.2 Implications

- Touch targets are larger than desktop conventions suggest (44px+ everywhere).
- Important actions reach the thumb (bottom of screen on mobile).
- Initial render is fast even on slow connections (skeleton, prioritized content).
- Network errors are graceful (cached state, clear retry).
- Battery and data usage are considered (no auto-playing motion, no aggressive polling).

---

## 2. Breakpoints

We use Tailwind's defaults with one custom small breakpoint.

| Token | Width | Device profile |
|---|---|---|
| `xs` | < 480px | Small phones (older Android, smaller iPhones) |
| `sm` | ≥ 640px | Large phones, small tablets in portrait |
| `md` | ≥ 768px | Tablets in portrait, small laptops |
| `lg` | ≥ 1024px | Laptops, tablets in landscape |
| `xl` | ≥ 1280px | Desktops |
| `2xl` | ≥ 1536px | Large desktops (rare; we cap at this) |

### 2.1 Where Layouts Change

| Breakpoint | What changes |
|---|---|
| Below `sm` | Mobile layout: single column, bottom nav, full-width cards |
| `sm`-`md` | Mobile layout but with slightly more padding and larger cards |
| `md` | Top nav appears (replacing/augmenting bottom nav); some pages get a side rail |
| `lg` | Two-column layouts where appropriate (Q&A list with filter sidebar; profile with side info) |
| `xl` | Three-column layouts on home (left rail + feed + right rail); admin gets denser tables |
| `2xl` | Content stays max-width 1440; the rest is whitespace |

We don't design fluidly for every pixel — the major layout shifts are at `md` and `lg`.

---

## 3. The Mobile-First Canon

### 3.1 What "Mobile-First" Means in Practice

It means **every screen is designed for mobile first**, then enhanced for larger viewports. Concretely:

- The Figma frame for a screen starts at 375x667 (iPhone reference).
- Every interaction, every form, every flow is verified at that size before larger sizes are considered.
- Larger viewports add features (multi-column, side rails, hover affordances), but never *remove* features.
- If something only works on desktop, it's a bug in mobile design, not a feature of desktop.

### 3.2 The Common Mistakes We Avoid

- Designing the desktop version first and "responsive-ing it down" — this consistently produces poor mobile experiences.
- Hiding features on mobile because they're "complex." If the feature exists, it works on mobile, fully.
- Tiny touch targets that work with a mouse but fail with a finger.
- Using hover for critical information (tooltips that hide what users need to know).

---

## 4. Layout Adaptations

This section documents how key screens shift across breakpoints. Visual designer fills in pixel-level specifics.

### 4.1 Home Feed

| Breakpoint | Layout |
|---|---|
| Mobile (< md) | Single column, full-width cards, bottom tab nav |
| Tablet (md-lg) | Single column with wider gutters, top nav, optional right rail (320px) for "What's new" |
| Desktop (lg-xl) | Two-column: feed (max 720px) + right rail (300px) |
| Wide desktop (xl+) | Three-column: left rail (200px) with widgets + feed + right rail |

### 4.2 Question Detail

| Breakpoint | Layout |
|---|---|
| Mobile | Single column. Vote control horizontal at top of question and each answer |
| Tablet | Single column, more whitespace |
| Desktop (lg+) | Single column max 800px centered. Vote control on left rail (sticky as you scroll). Right rail (300px) with related questions, asker mini-profile |

The reading column never exceeds ~75 characters per line. We don't add a third column for "comments" — those are inline.

### 4.3 People Browse

| Breakpoint | Layout |
|---|---|
| Mobile | Single column list of person cards |
| Tablet | 2-column grid |
| Desktop | 3-column grid; filter sidebar on left |

### 4.4 Messages

| Breakpoint | Layout |
|---|---|
| Mobile | Two screens: thread list (one screen), thread detail (separate screen, back to return) |
| Desktop (lg+) | Master-detail in one view: thread list (340px) on left, selected thread on right |

### 4.5 Settings & Admin

| Breakpoint | Layout |
|---|---|
| Mobile | Settings as a single list page; tap to navigate to sub-page; back to return |
| Desktop (lg+) | Sidebar navigation (240px) + content area; current page highlighted in sidebar |

### 4.6 Forms

| Breakpoint | Layout |
|---|---|
| Mobile | Single column, full-width inputs, submit button full-width at bottom |
| Tablet+ | Form max-width 480-640px centered, submit button right-aligned |

Multi-column form layouts are used sparingly (for related field pairs like "City" + "State") only on tablet+.

### 4.7 Modal Dialogs

| Breakpoint | Layout |
|---|---|
| Mobile | Full-screen takeover (or bottom sheet for small actions) |
| Tablet+ | Centered modal with backdrop, max-width 480-560px depending on content |

The decision: mobile users have small screens; modals competing with the page underneath cause focus issues. Full-screen is clearer.

### 4.8 Tables (Admin)

| Breakpoint | Layout |
|---|---|
| Mobile | Each row collapses to a card-style block; columns become labeled fields |
| Tablet+ | Standard table with horizontal scroll if needed |

We don't show tables with horizontal scroll on mobile. Each row becomes a card.

---

## 5. Navigation Adaptations

(Cross-referenced from Information Architecture doc § 13.)

### 5.1 Mobile Navigation (< md)

- **Bottom tab bar:** persistent across most screens; 5 items.
- **Top bar:** logo + page title + contextual actions (e.g., "Edit" on profile).
- **Hamburger menu:** accessed from profile tab; reveals secondary items.
- **Search:** dedicated tab opening full-screen overlay.

### 5.2 Tablet Navigation (md-lg)

- **Top bar:** logo + horizontal nav links (icons + labels) + search + notifications + profile.
- **No bottom tab bar.**
- **Sidebar navigation:** appears on settings and admin pages.

### 5.3 Desktop Navigation (lg+)

- Same top bar as tablet, with more spacing.
- Hover affordances appear (dropdown menus, tooltips).
- Keyboard shortcuts gain prominence.

---

## 6. Input Mode Considerations

### 6.1 Touch (Mobile, Tablet)

- Touch targets ≥ 44x44 px.
- Adjacent targets have ≥ 8px spacing.
- No hover-only affordances.
- Long press supported (with ≥ 500ms delay) for context menus.
- Pull-to-refresh on feed views.
- Pinch zoom enabled (no `user-scalable=no` in viewport).
- Tap delay removed via `touch-action: manipulation`.

### 6.2 Mouse (Desktop)

- Hover states on interactive elements (subtle).
- Cursor changes (`pointer` for clickable, `text` for inputs, `not-allowed` for disabled).
- Right-click respects browser default (we don't override unless we have a custom menu, which we usually don't).
- Tooltips on icon-only buttons.

### 6.3 Keyboard (Desktop, Accessibility)

- All interactive elements reachable and activatable (per Accessibility Spec).
- Visible focus indicators always.
- Keyboard shortcuts available but never required.

### 6.4 Stylus (Tablet, Some Desktops)

- Treated as touch + slight precision improvement.
- No specific stylus features in v1.

---

## 7. Image and Media Handling

### 7.1 No User Media Uploads in v1

We don't accept image or video uploads from users. Avatars are initials-based. Resources link to external content; we don't embed or thumbnail.

### 7.2 Static Assets

- App icons, illustrations, and any product imagery use modern formats (WebP with PNG fallback).
- SVG for icons and simple illustrations.
- Lazy-loading via native `loading="lazy"` for any images below the fold.
- Responsive images via `srcset` where appropriate.

### 7.3 No Background Images

We don't use decorative background images. Surfaces are color-only. This keeps initial load fast and respects users on metered connections.

---

## 8. Performance on Slower Connections

### 8.1 Initial Load Targets

| Connection | Target Time-to-Interactive |
|---|---|
| Wi-Fi / 4G+ | < 2s |
| 3G | < 5s |
| 2G | best effort; basic content visible |

### 8.2 Strategies

**Critical CSS inlined.** Above-the-fold styles render immediately.

**Code-split aggressively.** Each route loads its own JS chunk. Markdown editor, charts, and heavy components are dynamic imports.

**Server-rendered HTML.** Next.js App Router with React Server Components delivers fast first paint with content visible before JS hydrates.

**Skeleton loaders.** Visible structure within 100ms of navigation; real content within reasonable load time.

**Optimistic updates.** Votes, follows, bookmarks update UI instantly; sync happens in background.

**Cached reads.** Recently-viewed feed and profiles cached client-side; stale-while-revalidate updates.

### 8.3 Prefetching

- Next.js Link components prefetch on hover (desktop) and on viewport entry (mobile).
- Prefetching disabled on slow connections (`navigator.connection.effectiveType` check).
- Prefetching disabled when user has data-saver enabled (`navigator.connection.saveData`).

### 8.4 Bundle Budgets

| Bundle | Target gzipped size |
|---|---|
| Initial JS for home page | < 100KB |
| Total JS for any single page | < 200KB |
| Total CSS | < 30KB |
| Total fonts | < 80KB (subsetted woff2) |

CI fails when budgets exceeded by > 10%.

### 8.5 Render Performance

- Long lists (feed, comments) use windowing/virtualization where item count > 50.
- Avoid re-renders via memoization where measurable.
- Animations use CSS `transform` and `opacity` only (cheap on GPU).

---

## 9. Network and Connectivity

### 9.1 Offline Behavior

We are not a fully offline-first app at v1, but degrade gracefully:

- **Cached pages remain visible.** A user on a stale connection still sees the last-loaded feed.
- **Failed requests show inline retry.** Not a blank page; the existing content stays.
- **Composer drafts persist locally.** A question being written survives connection loss.
- **No useless errors.** "You're offline. Some things may not work until you're connected" appears once, not on every action.

### 9.2 Reconnection

- App detects reconnect via `online` event.
- Queued mutations replay (votes, comments) where idempotent.
- "Reconnected" indicator shows briefly.

### 9.3 Polling vs Real-Time

- Real-time (Socket.IO) is the primary mechanism.
- No background polling that drains battery.
- When tab is hidden (Page Visibility API), connection is downgraded; reconnects on visibility.

---

## 10. PWA Considerations

### 10.1 Manifest

```json
{
  "name": "Ascend",
  "short_name": "Ascend",
  "description": "Knowledge and mentorship platform for the RSET community",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#1e3a5f",
  "background_color": "#faf9f6",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "/icon-maskable.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

### 10.2 Service Worker

- Caches static assets (JS, CSS, fonts) with cache-first strategy.
- Caches HTML with network-first, falling back to cached version.
- No aggressive cache that prevents users from seeing updated content.
- Precaches the offline fallback page for navigation requests that fail.

### 10.3 Install Prompt

- Browser-default install affordance is allowed.
- We don't show our own install banner aggressively. After 3 visits, a single subtle prompt: "Install Ascend for quick access?"

### 10.4 Safe Areas

Layouts respect `env(safe-area-inset-*)` for iOS notches and Android gesture bars:

```css
.bottom-nav {
  padding-bottom: env(safe-area-inset-bottom, 0);
}
```

---

## 11. Density Modes

We don't expose a density toggle. Each viewport has its own density profile baked in:

- **Mobile:** comfortable (more spacing, larger touch targets, less per screen).
- **Tablet:** standard (slightly tighter, more per screen).
- **Desktop:** dense in admin/data views (tables, audit logs); standard in user-facing views.

Admin desktop views can show 20+ rows of content per page; user-facing desktop views never feel cramped.

---

## 12. Tested Devices and Browsers

### 12.1 Browsers

**Tier 1 (full support, tested every release):**
- Chrome (latest 2 versions)
- Safari (latest 2 versions)
- Firefox (latest 2 versions)
- Edge (latest version)
- Samsung Internet (latest 2 versions) — common on Android in India

**Tier 2 (functional, tested on releases):**
- Chrome on Android 9+ (older devices)
- Safari iOS 15+

**Not supported:**
- Internet Explorer
- Browsers older than 2 years

### 12.2 Devices

Representative test devices:
- iPhone SE (2nd gen, 4.7" — small screen reference)
- iPhone 13/14
- Pixel 5 / 7 (mid-range Android)
- Older Samsung Galaxy A-series (3-year-old Android)
- iPad (10.2" — primary tablet target)
- Standard 13"-15" laptops at 1280x800 and 1920x1080

### 12.3 Network Conditions

Tested via Chrome DevTools and real low-bandwidth scenarios:
- Fast 3G (~1.6 Mbps)
- Slow 3G (~400 Kbps)
- Offline (PWA cached state)

---

## 13. Responsive Implementation Patterns

### 13.1 Tailwind Class Pattern

```html
<!-- Mobile-first; sm: and above adds enhancements -->
<div class="px-4 py-3 sm:px-6 sm:py-4 lg:px-8 lg:py-6">
  <h2 class="text-xl sm:text-2xl lg:text-3xl">...</h2>
</div>
```

### 13.2 Container Pattern

```html
<div class="mx-auto max-w-screen-md px-4 sm:px-6 lg:px-8">
  ...
</div>
```

### 13.3 Stack to Grid Pattern

```html
<!-- Single column on mobile, 2-col on md+, 3-col on lg+ -->
<div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
  <Card />
  <Card />
  <Card />
</div>
```

### 13.4 Hide on Mobile / Show on Desktop

Use sparingly. Most things should appear on both, just adapted. When we do:

```html
<aside class="hidden lg:block">...</aside>  <!-- desktop-only sidebar -->
<nav class="lg:hidden">...</nav>  <!-- mobile-only bottom nav -->
```

Document the reason in code comments; "hidden on mobile" should never hide a feature, only an enhancement.

---

## 14. Testing the Responsive Behavior

### 14.1 Designer Workflow
- Design at mobile size first.
- Once approved, design tablet (768px) and desktop (1280px) variants.
- Note the breakpoint at which each adaptation kicks in.

### 14.2 Engineer Workflow
- Implement the mobile layout first.
- Add `sm:`, `md:`, `lg:`, `xl:` modifiers progressively.
- Test in Chrome DevTools responsive mode at each breakpoint.
- Test on at least one real Android device per major build.

### 14.3 QA Checklist (Per Feature)
- Render correctly at 320px, 375px, 768px, 1024px, 1440px.
- No horizontal scrolling on any width except where intentional (tables).
- Touch targets meet 44px minimum.
- Critical actions reachable with thumb on phone.
- Keyboard navigation works at all sizes.
- Loading on simulated 3G completes in < 5s.

---

## 15. Adapting to Future Devices

Foldables, large desktop displays, watches: these aren't v1 considerations, but the foundation is forward-compatible:

- **Foldables:** treat as variable mobile size; layouts already adapt fluidly.
- **Ultrawide displays:** content max-width caps at 1440px; users get whitespace, not stretched layouts.
- **Watches / small embedded:** out of scope. We do not expect watch users.

---

## 16. Open Questions for Designer

When the designer joins, they'll resolve:

- Exact type scale at the smallest breakpoint (xs < 480) — current scale may need adjustment for 320px-wide phones.
- Whether the right rail on home (xl+) is essential or nice-to-have.
- How aggressive the empty/loading states are on mobile — should we stagger reveals or show all at once?
- Whether tablet portrait deserves its own dedicated layout or shares mobile/desktop.

These are calibration questions answered through prototyping and testing.
