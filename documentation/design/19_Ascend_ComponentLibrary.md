# Ascend — Component Library Specification

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers |
| Purpose | Catalog of every UI component with its purpose, variants, states, and behavior. The build order list. |

> Each component below includes: **purpose**, **variants**, **states**, **accessibility notes**, and **usage guidance** (when to reach for it; when not to). Components are grouped by category. shadcn/ui covers many primitives — we use it as a starting point and customize to match Ascend's tokens.

---

## 1. Form Controls

### 1.1 Button

**Purpose:** Trigger an action or submit a form.

**Variants:**
- `primary` — main action on a screen (e.g., Submit, Post Question). Solid primary-700 background.
- `secondary` — alternative action. Outlined, primary-700 border and text.
- `tertiary` — low-emphasis action (Cancel, Skip). Text-only with hover background.
- `destructive` — destructive actions (Delete, Ban). Solid error background.
- `ghost` — minimal; for icon-only or inline actions.
- `link` — text styled as link; for in-flow actions.

**Sizes:** `sm` (32px height), `md` (40px), `lg` (48px). Default `md`.

**States:** default, hover, focus-visible, active/pressed, disabled, loading.

**Loading state:** spinner replaces label or appears next to it; button is disabled; preserves width to prevent layout shift.

**Accessibility:**
- All interactive buttons use `<button>`. Links use `<a>`.
- Focus ring per Design System Foundations.
- Loading state announces to screen readers ("Loading…").
- Icon-only buttons require `aria-label`.

**Usage:**
- Maximum one `primary` per screen (or per primary section). More than one creates competition for attention.
- `tertiary` and `ghost` are nearly interchangeable; use `tertiary` in form contexts (Cancel), `ghost` for inline actions.
- Never use `destructive` for routine actions, only for genuinely destructive ones.

### 1.2 Text Input

**Purpose:** Single-line text entry.

**Variants:**
- `default` — standard text input.
- `search` — with search icon prefix; rounded corners; clear-button suffix.
- `password` — with show/hide toggle.

**States:** default, hover (subtle border darken), focus, invalid (error border + helper), disabled, read-only.

**Anatomy:** Label (above input), input, helper text (below, optional), error text (below, on invalid).

**Accessibility:**
- `<label>` always associated with `<input>` via `htmlFor`/`id`.
- Helper text linked via `aria-describedby`.
- Error text linked via `aria-describedby` and announced via `aria-invalid="true"` on input.
- Required fields marked with asterisk in label and `aria-required="true"`.

**Usage:**
- Validate on blur (not on every keystroke) for most fields. Validate on submit for the form as a whole.
- Show errors below the field, not in a summary at top.
- Maximum length indicators (e.g., "120 / 120") appear when within 20% of limit, never always.

### 1.3 Textarea

**Purpose:** Multi-line text entry. Used for comments, short answers, simple bodies.

**Variants:** `default`, `markdown` (with preview toggle and toolbar — for question/answer/post bodies).

**Sizing:** auto-grow up to a max-height; scroll thereafter. Min 3 rows.

**Accessibility:** Same as Text Input plus character count for length-limited fields.

### 1.4 Markdown Editor

**Purpose:** Rich body composition for questions, answers, posts, resource descriptions.

**Layout:** Two-tab toggle on mobile (Write / Preview); side-by-side on desktop ≥ 1024px.

**Toolbar:** Bold, Italic, Heading (h2-h4), Unordered list, Ordered list, Quote, Inline code, Code block, Link. Keyboard shortcuts shown in tooltips.

**Insertion:** Link insertion uses a small popover form (URL + display text), not a modal.

**Constraints:**
- Character limit shown when within 20% of cap.
- Server-side sanitization is the source of truth; client-side preview matches server rendering.

**Accessibility:**
- Toolbar buttons have `aria-label` and tooltips.
- Tab/preview toggle uses ARIA tabs pattern.
- Keyboard shortcuts documented and accessible.

### 1.5 Select

**Purpose:** Choose one option from a small-to-medium list (≤ 20 options).

**Variants:** Native `<select>` on mobile (uses OS picker — better UX than custom). Custom dropdown on desktop ≥ 1024px for richer styling.

**Behavior:** Custom variant uses Radix Primitive (or shadcn Select). Search within the dropdown when options ≥ 8.

**Accessibility:** Full keyboard support (arrow keys, Enter to select, Escape to close, type to search).

### 1.6 Multi-Select / Tag Picker

**Purpose:** Select multiple options. Used for tags on questions/posts/resources.

**Behavior:**
- Type to filter.
- Selected tags appear as chips inside the input.
- Maximum cap enforced (e.g., 5 tags); UI prevents adding beyond.
- Suggestion to create a new tag when query has no match → links to TagSuggestion form (per spec).

**States:** default, focused, with-selection, max-reached (input disabled with helper text).

**Accessibility:**
- Chips removable with backspace when input is empty (focus on last chip).
- Each chip has remove button with `aria-label="Remove [tag name]"`.
- Combobox ARIA pattern.

### 1.7 Checkbox

**Purpose:** Binary choice; multiple-of-many in a group.

**Anatomy:** Box (16px), label to the right.

**States:** unchecked, checked, indeterminate, focused, disabled.

**Accessibility:** Native `<input type="checkbox">` wrapped with custom styling. Label associated. Indeterminate via JS prop.

### 1.8 Radio Group

**Purpose:** One-of-many choice.

**Anatomy:** Stacked radios with labels. Group has a `<fieldset>` with `<legend>`.

**States:** as Checkbox.

### 1.9 Toggle Switch

**Purpose:** Binary on/off for a setting that takes effect immediately.

**Use only for settings,** not for form fields where the value applies on submit.

**Anatomy:** Track (40x24), thumb (20x20). Label to the left.

### 1.10 Slider

**Purpose:** Choose a value within a range.

**Use sparingly.** Most controls in Ascend don't need sliders. A possible use: setting a notification frequency. Most settings are switches.

### 1.11 Form Layout

**Purpose:** Consistent vertical form structure.

**Anatomy:**
- Each field block: label (top), input (middle), helper or error (bottom).
- Spacing: space-2 between label and input; space-1 between input and helper.
- Spacing between field blocks: space-5.
- Required marker: `*` after label, `text-error`.
- Optional marker: "(optional)" in muted text after label.

**Submit area:** primary button right-aligned on desktop; full-width below form on mobile. Cancel link/button to the left of submit.

---

## 2. Display & Containers

### 2.1 Card

**Purpose:** Enclose a discrete unit of content (a question in a feed, a post, a resource).

**Variants:**
- `default` — surface background, subtle shadow on hover, radius-lg.
- `flat` — no shadow, only border. Used in dense lists.
- `interactive` — adds cursor-pointer and elevated shadow on hover when entire card is clickable.

**Anatomy:** Padding (space-5 mobile, space-6 desktop). Internal structure varies by content type.

**Accessibility:**
- If the entire card is clickable, the card wraps an `<a>` (or has an `<a>` overlay covering it) — not a `<div onClick>`. Right-click and middle-click work; URL is shareable.
- Inner buttons (vote, bookmark) are above the link layer; ensure event propagation handled.

**Usage:**
- Don't nest cards in cards. If you find yourself wanting to, you need a different pattern.
- Use `flat` in tight lists where shadows on every row create noise.

### 2.2 Question Card

**Purpose:** Specific composition for a question in a feed.

**Anatomy (mobile, top-to-bottom):**
- Persona indicator + author name (or "Anonymous Student") + timestamp
- Title (text-lg, semibold)
- Body preview (text-base, 2 lines, ellipsized)
- Tag chips (max 3 visible, "+N more" if exceeded)
- Footer: vote score, answer count, "answered" check icon if accepted

**Anatomy (desktop):** Same content; vote score and answer count may shift to a left rail.

**State:** unread (subtle accent dot), unanswered (subtle warning indicator), accepted (success check on answer count).

### 2.3 Post Card

**Purpose:** Experience Feed post in a list.

**Anatomy:**
- Persona indicator + author + timestamp + category tag
- Title
- Body preview (3 lines on mobile, 2 on desktop with side image; no images for v1)
- Tag chips
- Footer: upvote count, comment count, bookmark button

### 2.4 Resource Card

**Purpose:** Library or pending resource entry.

**Anatomy:**
- Submitter + timestamp + category
- Title (linked to external URL with `rel="noopener nofollow"` and external link icon)
- Description (2 lines)
- Tags
- Footer: upvote count, endorsement chip if endorsed (with faculty count), broken-link warning if applicable

**Distinct visual:** Resources have a left border accent in `accent-500` to differentiate from questions/posts in mixed feeds (if mixed). Actually — recommend not mixing them in feeds; resources have their own tab.

### 2.5 Avatar

**Purpose:** Visual identity for a user.

**Variants:**
- Initials fallback (most common — we don't have profile photos at v1, so initials it is).
- Persona-tinted background (per persona color).
- Sizes: `xs` (24px), `sm` (32px), `md` (40px), `lg` (56px), `xl` (80px).

**Persona indicator:** small icon overlay (bottom-right) showing persona — student book icon, faculty mortar-board, alumnus arrow-up. Adds at-a-glance identity.

**Accessibility:** `alt` text with name. Persona indicator described in `aria-label`.

**Anonymous variant:** generic icon, gray background, "Anonymous" tooltip.

### 2.6 Persona Indicator (Inline)

**Purpose:** Show persona context without a full avatar (in metadata strips).

**Anatomy:** Small pill with persona icon + label.

**Variants:**
- Compact: "Student · 5th sem"
- Default: "Faculty, CSE Department"
- Alumnus: "Alumnus, Class of 2018"

### 2.7 Badge (Achievement)

**Purpose:** Display earned reputation badges (Helpful, Connector, etc.).

**Anatomy:** Small chip with badge icon + label.

**Variants:**
- `subtle` — text only, no background; used inline.
- `tinted` — accent-tinted background; used in profile.
- `prominent` — full color, used on badge-earned notifications and on badge detail page.

### 2.8 Tag (Topic)

**Purpose:** Display or select a topic tag (DSA, Cloud, Internships).

**Variants:**
- `display` — non-clickable, on cards.
- `link` — clickable, navigates to filtered view.
- `removable` — X icon, used in selected-tag chips.
- `selectable` — click toggles selection.

**Sizing:** small (24px height) to fit in dense card footers.

### 2.9 Vote Control

**Purpose:** Up/down vote on questions, answers, posts, resources.

**Anatomy (vertical, on Q&A):** Up arrow → number → down arrow.

**Anatomy (horizontal, on cards):** Up arrow + number; down arrow only on detail view.

**States:**
- Default (gray icons)
- Upvoted (filled + accent color)
- Downvoted (filled + error color)
- Disabled (cannot vote on own; show tooltip)

**Animation:** Number bumps on vote (per Foundations § 6.4).

**Accessibility:** Two buttons with `aria-label` ("Upvote", "Downvote"). Pressed state via `aria-pressed`.

### 2.10 Comment

**Purpose:** Display a comment under a question, answer, post, or resource.

**Anatomy:** Avatar (sm) + author + timestamp + body. Indented from parent. Edit/delete actions on hover (or always visible on mobile).

**Variants:**
- `default` — standard.
- `nested` — currently we only allow one level of comments (no nested replies); if we need nesting later, add `nested` variant.

### 2.11 Profile Header

**Purpose:** Top of a user profile page.

**Anatomy:**
- Avatar (xl)
- Name + persona indicator
- Bio
- Stats row (rep score, questions, answers, badges count)
- Action row (Connect, Follow, More)

**Mobile:** stacked vertically. **Desktop:** avatar left, info right.

### 2.12 Section Heading

**Purpose:** Group content within a screen.

**Anatomy:** Heading text + optional action (e.g., "View all" link). Bottom border or generous space-below.

---

## 3. Navigation

### 3.1 Top Navigation Bar (Desktop)

**Anatomy:**
- Logo (left, links to home)
- Primary nav links (Home, Questions, Posts, Resources, People)
- Search input (center, expandable)
- Notifications bell + avatar/menu (right)

**Sticky** at the top; subtle border-bottom; surface background.

### 3.2 Bottom Navigation (Mobile)

**Anatomy:** 5 icons + labels: Home, Questions, Search, Notifications, Profile.

**Behavior:** persistent across most screens; hides on scroll-down, reappears on scroll-up; active tab indicated by primary color.

**Accessibility:** Each icon is a `<button>` or `<a>` with both icon and label visible (icons alone fail many accessibility heuristics).

### 3.3 Sidebar Navigation (Desktop, Settings/Admin)

**Purpose:** Secondary navigation within sections that have many sub-pages (Settings, Admin).

**Anatomy:** Vertical list of links, current page highlighted, optional grouping headings.

### 3.4 Tabs

**Purpose:** Switch between views at the same hierarchical level (e.g., Library / Pending tabs on Resources).

**Anatomy:** Horizontal row of tab buttons; underline indicator on active.

**Behavior:** Active tab persists in URL (e.g., `?tab=library`) so deep links work and back-button preserves.

### 3.5 Breadcrumbs

**Used sparingly.** Only on admin pages where navigation hierarchy matters (e.g., Admin > Tags > Edit Tag).

**Format:** "Admin / Tags / Edit"

### 3.6 Filter Chips

**Purpose:** Show active filters in a list view; allow removal.

**Anatomy:** Pill with filter type + value + X. Click to remove.

**Example:** "Tag: DSA ×", "Branch: CSE ×".

---

## 4. Feedback

### 4.1 Toast

**Purpose:** Transient confirmation or non-blocking notification ("Question posted", "Connection request sent").

**Anatomy:** Icon + message + optional action (e.g., "Undo"). Auto-dismiss after 5s by default; persistent for errors that need user attention.

**Position:** Bottom-center mobile; top-right desktop.

**Accessibility:** `role="status"` for non-critical, `role="alert"` for errors. Screen reader reads on appearance.

**Usage:**
- Toasts confirm actions ("Posted"). They don't deliver important information that the user must act on — that's a notification or an inline message.
- Stack max 3 toasts; queue beyond that.

### 4.2 Inline Alert

**Purpose:** Persistent message inside a content area ("Your account is pending verification").

**Variants:** `info`, `success`, `warning`, `error`. Tinted background, semantic icon, descriptive heading + body.

**Dismissibility:** Some are dismissible (informational), some are not (e.g., verification status).

### 4.3 Banner

**Purpose:** Full-width, top-of-page or top-of-screen message.

**Use sparingly.** Only for: maintenance windows, critical service announcements, account lockouts.

**Anatomy:** Full-width tinted bar with icon + message + dismiss (if applicable).

### 4.4 Skeleton Loader

**Purpose:** Indicate loading content with placeholder shapes.

**Use:**
- For content that takes >300ms to load.
- Shape matches the eventual content (e.g., card-shaped skeleton for a feed card).

**Animation:** Subtle pulse (per Foundations § 6.4). Respect `prefers-reduced-motion`.

### 4.5 Spinner

**Purpose:** Indeterminate loading where skeleton doesn't fit (button loading, infinite scroll loading more).

**Anatomy:** Circular, 16-24px.

**Use:** Inside buttons, after the last item in an infinite scroll, in modal-loading states.

### 4.6 Progress Bar

**Purpose:** Determinate progress (file processing, multi-step flows).

**Anatomy:** Linear, 4px tall, primary color. Optional percentage text.

**Use:**
- File processing (data export). 
- Multi-step flows (signup wizard) showing "Step 2 of 4".

### 4.7 Empty State

**Purpose:** Communicate that a list is empty and what to do.

**Anatomy:** Centered illustration or icon + heading + description + primary action.

**Variants per surface:**
- Empty feed: "Your feed is quiet right now. Follow some tags or people to see content here." + Browse Tags button.
- Empty notifications: "You're all caught up." + brief encouragement.
- Empty search: "No results for '[query]'. Try different keywords or fewer filters."
- (More in State Catalog doc.)

### 4.8 Error State

**Purpose:** Communicate failure and recovery path.

**Anatomy:** Centered icon + heading + description (per principle 5: honesty in failure) + retry/recover action + secondary action (e.g., go home).

**Common patterns:**
- Network error: "We couldn't reach the server. Check your connection and try again."
- 404: "We couldn't find this question. It may have been removed."
- 500: "Something on our end isn't working. We've been notified. Try again in a moment."

---

## 5. Overlays

### 5.1 Modal Dialog

**Purpose:** Focused interaction that blocks the underlying page.

**Use sparingly.** Modals interrupt. Acceptable uses: confirmations of destructive actions, focused forms (report content, decline connection with reason), critical onboarding steps.

**Anatomy:** Backdrop (semi-transparent overlay) + dialog (max-width 480px usually) with heading, body, action footer.

**Behavior:**
- Focus trapped within modal; Escape closes (when allowed).
- First focusable element receives focus on open.
- Background scrolling locked.
- On mobile, modal becomes full-screen if content is significant.

**Accessibility:**
- `role="dialog"`, `aria-labelledby`, `aria-describedby`.
- Focus management on open and close (return focus to trigger).
- Click outside dismisses unless action is destructive (then require explicit close).

### 5.2 Drawer (Side Panel)

**Purpose:** Slide-in panel from screen edge for secondary content.

**Use:** Filters, settings panels, mobile navigation overflow.

**Anatomy:** Slides from left or right edge; full-height; overlay backdrop on mobile; pushes content on desktop (rare).

### 5.3 Bottom Sheet (Mobile)

**Purpose:** Mobile equivalent of dropdowns/popovers; slides up from bottom.

**Use:** Action menus, filter selection, persona selection during signup.

**Anatomy:** Sheet covers up to 80% of screen height; drag handle at top; backdrop dismisses.

### 5.4 Dropdown / Popover

**Purpose:** Small contextual menu or content.

**Use:** Action menus (three-dot menu on a card), profile menu, tag picker.

**Anatomy:** Anchored to trigger; auto-positions to fit viewport; max-height with scroll if content overflows.

**Accessibility:** Full keyboard support; Escape closes; auto-focus first item on open via keyboard.

### 5.5 Tooltip

**Purpose:** Short hint on hover/focus.

**Use:** Icon-only buttons, abbreviated labels, hover details on dense data.

**Behavior:** Appears after 500ms hover; dismisses on mouseout or focusout.

**Accessibility:** Linked to trigger via `aria-describedby`. Never the only way to convey critical information.

---

## 6. Specialized

### 6.1 Notification List Item

**Purpose:** A single notification in the inbox.

**Anatomy:** Type icon + content (with linked entity names) + timestamp. Unread indicator on left.

**Behavior:** Click navigates to the relevant content. Mark-as-read happens automatically on click (or via menu).

**Accessibility:** Link surrounds entire item; `aria-label` includes the type and timestamp ("Answer received, 2 hours ago").

### 6.2 DM Thread Bubble

**Purpose:** A single message in a DM conversation.

**Anatomy:** Right-aligned (from current user) or left-aligned (from other party); subtle background tint; timestamp on hover or below; read indicator.

**Variants:**
- `sent` — primary-tinted background.
- `received` — surface-sunken background.
- `sending` — slight transparency, ‟Sending..." indicator.
- `failed` — red border + retry button.

### 6.3 Connection Request Card

**Purpose:** Display a sent or received connection request.

**Anatomy:** Sender/recipient avatar + name + persona, request topic, full request note (collapsed if long), timestamp, action buttons (Accept / Decline / Decline silently).

**States:** pending (action buttons), accepted/declined (show outcome), expired (muted with "Request expired").

### 6.4 Verification Status Banner

**Purpose:** Persistent reminder for accounts in PENDING state.

**Anatomy:** Inline alert pinned to top of authenticated views: "Your alumnus account is pending verification. You can browse and ask questions; answering and connecting unlock once verified."

**Behavior:** Dismissible per session but reappears on next visit until status changes.

### 6.5 Reputation Display

**Purpose:** Show user's reputation score in profile and metadata.

**Anatomy:** Number with subtle accent color; small label "rep" beside.

**Profile variant:** larger, with breakdown link ("Based on 89 events"). Detailed breakdown on click.

### 6.6 Composer (Inline)

**Purpose:** Quick text composition, used for comments and DMs.

**Anatomy:** Textarea + Send button + character counter.

**Behavior:** Send on Cmd/Ctrl+Enter (desktop). Disabled when empty or over limit.

### 6.7 Search Bar (Global)

**Purpose:** Site-wide search.

**Anatomy:** Input with search icon, placeholder ("Search questions, posts, resources, people..."), clear button when filled.

**Behavior:** 
- Typeahead suggestions appear after 2 chars (debounced 200ms).
- Suggestions grouped: recent searches, suggested tags, suggested people.
- Enter navigates to full search results page.

**Mobile:** triggers full-screen search overlay with same behavior.

### 6.8 Filter Bar

**Purpose:** Filter controls on list pages.

**Anatomy:** Horizontal row of filter chips + sort selector.

**Mobile:** "Filters" button opens a bottom sheet with all filters; active filters shown as removable chips above list.

### 6.9 Pagination / Load More

**Purpose:** Navigate through long lists.

**Pattern decision:** **Cursor-based infinite scroll** with explicit "Load more" button on mobile (don't auto-load; user keeps control of data usage).

**Anatomy:** "Load more" button at end of list; spinner while loading; "End of results" message at terminus.

---

## 7. Component States Reference

Every interactive component handles these states explicitly (where applicable):

| State | When | Visual treatment |
|---|---|---|
| Default | Resting | Per token |
| Hover | Mouse over (desktop only) | Subtle elevation/color shift |
| Focus | Keyboard focus | 3px ring (per token) |
| Active/Pressed | During click/tap | Slightly inset/darker |
| Disabled | Not currently usable | 40-50% opacity, no pointer events |
| Loading | Async operation in progress | Spinner or skeleton |
| Error | Validation or operation failed | Error border/text |
| Success | Operation completed | Brief success indicator (toast or inline check) |
| Empty | No content to display | Empty state component |

---

## 8. Composition Patterns

### 8.1 Page Layout

```
┌──────────────────────────────────────┐
│ Top Nav (desktop)                    │
├──────────────────────────────────────┤
│ ┌──────────┬───────────────────────┐ │
│ │ Sidebar  │ Page Title            │ │
│ │ (when    │                       │ │
│ │  applic) │ Breadcrumbs (admin)   │ │
│ │          │                       │ │
│ │          │ Page content          │ │
│ │          │                       │ │
│ │          │                       │ │
│ └──────────┴───────────────────────┘ │
└──────────────────────────────────────┘
[Bottom Nav (mobile only)]
```

### 8.2 List + Detail Pattern (Desktop)

For DMs and admin views: list on left (340px), detail on right (flex). On mobile, list is the page; tapping an item navigates to detail.

### 8.3 Reading Pattern (Question Detail)

Single-column, max-width container-md (~720px), centered. Maximizes reading comfort. Side actions (vote, bookmark) on left rail at desktop ≥ 1024px.

---

## 9. shadcn/ui Mapping

We extend shadcn/ui rather than build from scratch. Mapping:

| Component | shadcn/ui | Customization |
|---|---|---|
| Button | `Button` | Replace variants with our 6 |
| Input | `Input` | Tokens, focus ring |
| Textarea | `Textarea` | Tokens |
| Select | `Select` | Tokens |
| Checkbox | `Checkbox` | Tokens |
| Radio | `RadioGroup` | Tokens |
| Switch | `Switch` | Tokens |
| Dialog | `Dialog` | Tokens, motion |
| Drawer | `Drawer` | Tokens, motion |
| Dropdown | `DropdownMenu` | Tokens |
| Popover | `Popover` | Tokens |
| Tooltip | `Tooltip` | Tokens, 500ms delay |
| Tabs | `Tabs` | Tokens |
| Toast | `Toaster` | Tokens, position |
| Skeleton | `Skeleton` | Tokens, motion |
| Avatar | `Avatar` | Persona indicator overlay |
| Badge | `Badge` | Map to our badge variants |
| Form | `Form` (with react-hook-form + Zod) | Validation patterns |
| Card | `Card` | Tokens, variants |
| Separator | `Separator` | Tokens |

Components we build ourselves (not in shadcn): Markdown Editor, Tag Picker, Vote Control, Persona Indicator, Notification List Item, DM Thread Bubble, Connection Request Card, Bottom Navigation, Question/Post/Resource Cards.

---

## 10. Build Priority

When the engineering team starts implementation, build in this order:

**Sprint 1 (foundation):**
- Button, Input, Textarea, Select, Checkbox, Radio, Switch
- Card, Avatar, Badge (achievement and topic), Tag
- Form layout, Form validation
- Toast, Inline Alert
- Skeleton, Spinner
- Modal Dialog, Tooltip, Dropdown
- Top Nav, Bottom Nav (mobile)

**Sprint 2 (content composition):**
- Markdown Editor, Tag Picker
- Question Card, Post Card, Resource Card
- Vote Control
- Comment
- Persona Indicator, Profile Header
- Tabs, Filter Chips

**Sprint 3 (specialized):**
- DM Thread Bubble, Connection Request Card
- Notification List Item
- Verification Status Banner
- Empty State variants, Error State variants
- Search Bar (global), Bottom Sheet
- Drawer (mobile menu, filters)

Components built later, as features arrive: Reputation Display detail, Composer (inline), Filter Bar.

---

## 11. Testing Components

Per Engineering Standards:
- Each component has unit tests for state behavior (especially state transitions).
- Visual regression tests on key components (button variants, card variants) via Playwright snapshots.
- Accessibility tests using `@axe-core/playwright` on a representative page per template.
- Storybook (or similar) for designer-engineer review during build. Optional but recommended.
