# Ascend — Information Architecture & Navigation

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers, product |
| Purpose | The structural skeleton: what's where, how users move between things, what URL each thing has. |

---

## 1. Sitemap

```
/
├── /  (Home — feed)
├── /questions
│   ├── /questions/ask
│   ├── /questions/:id
│   └── /questions/:id/edit
├── /posts
│   ├── /posts/new
│   ├── /posts/:id
│   └── /posts/:id/edit
├── /resources
│   ├── /resources              (default tab: library)
│   ├── /resources?tab=pending
│   ├── /resources/submit
│   └── /resources/:id
├── /people
│   ├── /people                 (browse)
│   └── /people/:id             (profile)
├── /search
│   └── /search?q=...&type=...
├── /notifications
│   └── /notifications/preferences
├── /messages
│   ├── /messages               (thread list)
│   └── /messages/:threadId
├── /connections
│   ├── /connections            (active)
│   ├── /connections/sent
│   └── /connections/received
├── /tags
│   ├── /tags                   (browse all)
│   └── /tags/:slug             (filtered view)
├── /bookmarks
│   ├── /bookmarks              (questions)
│   ├── /bookmarks?type=posts
│   └── /bookmarks?type=resources
├── /profile
│   ├── /profile/me
│   └── /profile/me/edit
├── /settings
│   ├── /settings/account
│   ├── /settings/notifications
│   ├── /settings/privacy
│   ├── /settings/connections
│   ├── /settings/blocked
│   ├── /settings/sessions
│   ├── /settings/security      (password, MFA)
│   ├── /settings/data          (export, deletion)
│   └── /settings/admin-activity
│
├── /badges
│   ├── /badges/me              (earned)
│   └── /badges/all             (all available)
│
├── /onboarding
│   ├── /onboarding/welcome
│   ├── /onboarding/profile
│   └── /onboarding/tour
│
├── /auth
│   ├── /auth/login
│   ├── /auth/signup            (persona selector)
│   ├── /auth/signup/student
│   ├── /auth/signup/faculty
│   ├── /auth/signup/alumnus
│   ├── /auth/forgot-password
│   ├── /auth/reset-password
│   ├── /auth/verify-email
│   ├── /auth/mfa-setup
│   └── /auth/mfa-challenge
│
├── /pending-verification         (alumni waiting)
│
├── /admin
│   ├── /admin                  (dashboard)
│   ├── /admin/verifications
│   ├── /admin/reports
│   ├── /admin/users
│   ├── /admin/users/:id
│   ├── /admin/tags
│   ├── /admin/tag-suggestions
│   ├── /admin/audit
│   ├── /admin/calendar
│   └── /admin/admins
│
├── /help
│   ├── /help                   (index)
│   ├── /help/getting-started
│   ├── /help/asking-questions
│   ├── /help/reputation-and-badges
│   ├── /help/connections
│   ├── /help/community-guidelines
│   └── /help/privacy
│
├── /privacy                    (legal: privacy policy)
├── /terms                      (legal: terms)
└── /about                      (about Ascend)
```

---

## 2. Primary Navigation

### 2.1 Mobile (< 1024px) — Bottom Tab Bar

Five persistent tabs across the bottom:

| Tab | Icon | Destination |
|---|---|---|
| Home | `home` | `/` |
| Q&A | `message-circle-question` | `/questions` |
| Search | `search` | `/search` (or full-screen overlay) |
| Notifications | `bell` (with badge) | `/notifications` |
| Profile | avatar | `/profile/me` |

**Why these five:**
- Home, Q&A: primary content surfaces (most use)
- Search: most-used action, deserves a tab
- Notifications: needs glanceable badge
- Profile: gateway to everything else (settings, badges, bookmarks, connections)

**What's not in primary nav (mobile):**
- Posts: accessible via Home (mixed feed) or filter on Q&A; not a tab
- Resources: accessed via Search or specific tag flows; not a tab (but easily added if usage warrants)
- Messages: accessed from Profile or Notifications; not a tab (predicted as low-frequency)

This will be tested with users; we accept that the tab bar may need to change after launch data.

### 2.2 Desktop (≥ 1024px) — Top Navigation Bar

Horizontal bar with the following items:

```
[Logo]    Home    Q&A    Posts    Resources    People        [Search ___]    [🔔]  [Avatar ▾]
```

**Avatar dropdown contains:** My Profile, My Bookmarks, My Connections, My Badges, Settings, Help, Sign Out.

**Notification bell** opens dropdown with recent notifications + "View all" link.

### 2.3 Tablet (768-1023px)

Hybrid: top navigation bar (collapsed icons + labels), no bottom bar. Hamburger menu on left if more items than fit.

---

## 3. Secondary Navigation

Used within sections that have multiple sub-pages.

### 3.1 Settings Sidebar (Desktop)

```
Settings
├── Account
├── Notifications
├── Privacy
├── Connections
├── Blocked Users
├── Sessions
├── Security
├── Data & Privacy
└── Admin Activity
```

**Mobile:** rendered as a single list page; tap to navigate; back button to return.

### 3.2 Admin Sidebar

```
Admin
├── Dashboard
├── Verifications      (badge if pending > 5)
├── Reports            (badge if open)
├── Users
├── Tags
├── Tag Suggestions    (badge if pending)
├── Audit Log
├── Calendar
└── Admins
```

### 3.3 Profile Tabs

Within a user profile (own or others):

```
[Activity]  [Questions]  [Answers]  [Posts]  [Resources]  [Badges]
```

Activity is the default; shows mixed recent contributions.

### 3.4 Resources Tabs

```
[Library]  [Pending]
```

### 3.5 Connections Tabs

```
[Active]  [Sent]  [Received]
```

### 3.6 Bookmarks Tabs

```
[Questions]  [Posts]  [Resources]
```

---

## 4. URL Conventions

- **Lowercase, hyphens for separation:** `/getting-started`, not `/getting_started` or `/gettingStarted`.
- **CUIDs for IDs:** `/questions/cmkx7y9z00001abcd...`
- **Slugs for tags and content where relevant:** `/tags/data-structures` (slug derived from tag name).
- **Query params for filters:** `/questions?tag=cloud&unanswered=true&sort=top`.
- **Query params for tabs:** `/resources?tab=pending`.
- **Persistent state in URL:** filters, tabs, search queries — so back-button and share work.

---

## 5. Search Architecture

### 5.1 Global Search

Always accessible from primary navigation. Behavior:

- **Mobile:** tap Search tab → full-screen overlay with input focused.
- **Desktop:** input in top nav, expands on focus; typeahead dropdown.

**Typeahead suggestions** (after 2 chars):
- Recent searches (max 3)
- Matching tags (max 3)
- Matching people (max 3)
- "Search for '[query]'" — links to full results page

**Full results page** (`/search?q=...`):
- Tab strip at top: All / Questions / Posts / Resources / People / Tags
- "All" tab shows top 3 from each category with "See all in [category]" links
- Specific tabs show paginated full results
- Filter rail (desktop) or bottom-sheet filters (mobile): branch, persona, date range
- Sort: Relevance (default), Recent, Top

### 5.2 Within-Section Search

Search input appears at the top of list views (questions, posts, resources, people) and scopes to that section. URL shows scoped query (`/questions?q=...`).

---

## 6. Cross-Linking Patterns

### 6.1 From Question Detail
- **Tags** → `/tags/:slug`
- **Author** → `/people/:id` (unless anonymous)
- **Mentioned users (@-mentions)** → `/people/:id`
- **Related questions** (sidebar/below) → `/questions/:id`

### 6.2 From Profile
- **Stats** ("47 answers") → filtered profile tab
- **Badges** → `/badges/all` to see what others mean
- **Tag in expertise list** → filtered profile or `/tags/:slug`

### 6.3 From Notifications
- **Notification body** → linked entity (question, post, etc.)
- **Author** → profile

### 6.4 From Admin
- **User in report** → admin user detail (`/admin/users/:id`)
- **Audit log entry** → linked target (admin view)

---

## 7. Onboarding Flow

### 7.1 First-Time Tour (after signup + verification)

Three lightweight screens, dismissible:

1. **Welcome** — "Hi [name]. Ascend is where the RSET community asks, answers, and stays connected. Quick tour?" (Skip / Continue)
2. **What you can do** — three cards: Ask, Browse, Connect. Brief description each.
3. **Notifications setup** — "Stay informed without being interrupted. Choose what you'd like email and push for. (You can change this anytime.)" Defaults pre-selected; user adjusts.

After tour, land on home feed.

### 7.2 Persona-Specific Onboarding

- **Student:** focus on asking and following tags.
- **Faculty:** focus on creating Faculty Announcements and endorsing answers.
- **Alumnus:** focus on responding to mentorship requests.

The differences are in the third screen's example actions, not separate flows.

### 7.3 Empty State Onboarding

When a new user lands on an empty home feed (no follows yet), the empty state guides them: "Follow some tags to start seeing content" with a Browse Tags button.

---

## 8. Verification Status Routing

### 8.1 Pending Alumnus

After signup, before approval: lands on `/pending-verification` page. Cannot access most surfaces. Can:
- Edit own profile
- Browse public-read content (questions, resources)
- Submit additional verification info
- Cannot post, answer, connect, send DMs

### 8.2 Verified
Standard access.

### 8.3 Locked
Routed to `/auth/login` on every navigation; login page shows lock reason and unlock time/contact.

### 8.4 Suspended
Logged in but limited: can read; cannot write. Banner explains until-when and reason.

---

## 9. Permissions & Routing

The router enforces access based on:
- Authenticated vs unauthenticated
- Verification status
- Role (admin)
- Persona (faculty for some actions)

Unauthorized access redirects:
- Unauthenticated → `/auth/login` with `?next=` param
- Insufficient role → 403 page with explanation
- Suspended → `/account-status` with details

---

## 10. URL Sharing & Deep Links

Every meaningful resource has a stable, shareable URL:
- Questions, answers (via question URL with `#answer-:id` fragment)
- Posts, resources (with optional comment fragment)
- User profiles
- Tag pages
- Search results (with full query in URL)
- Notification preferences (admin-shareable as link to user)

URLs that are NOT shareable:
- DM threads (intentionally — privacy)
- Modal-only states (e.g., open report modal)

---

## 11. Mobile App Considerations (PWA)

As a PWA, Ascend installable on mobile gets a separate launcher icon. Considerations:

- **No bottom-nav overlap with iOS home indicator:** add safe-area-inset-bottom padding.
- **Status bar color:** matches top nav color (primary-700) when in standalone mode.
- **Splash screen:** logo on bg color background.
- **Manifest:** `display: standalone`, `theme_color: #1e3a5f`, `background_color: #faf9f6`, `icons` at multiple sizes.

---

## 12. Navigation Edge Cases

### 12.1 Back Button Behavior
- Back from question detail → previous list (preserves scroll position).
- Back from search results → preserves query and filters.
- Back from modal → closes modal, no navigation.
- Back from admin action → admin list with action acknowledged ("Report resolved").

### 12.2 Scroll Restoration
- List views: scroll position restored on back-navigation.
- Detail views: scroll to top.
- Anchor links (`#answer-:id`): scroll to anchor on load.

### 12.3 Long Lists
- Cursor-based infinite scroll.
- "Back to top" button appears after scrolling > 1 viewport; floats bottom-right.
- "Load more" button on mobile (no auto-load on slow connections).

### 12.4 Notifications Behavior
- Tapping a notification:
  - Marks as read.
  - Navigates to the target (question, profile, etc.).
  - On mobile: opens notification list briefly, then transitions to target.

### 12.5 Persistent Drafts
- Question/post/answer composers preserve drafts in localStorage (per device, per logged-in user).
- On revisit, prompt to restore draft or discard.

---

## 13. Responsive Navigation Summary

| Breakpoint | Pattern |
|---|---|
| < 768px (mobile) | Bottom tab bar; hamburger overflow if needed |
| 768-1023 (tablet) | Top bar with icons + labels |
| ≥ 1024 (desktop) | Top bar with full labels; sidebars for settings/admin |

---

## 14. Wayfinding Cues

These visual elements help users know where they are and where they can go:

- **Active nav state:** primary color, optional underline or pill background.
- **Page title at top of every screen:** matches the user's mental model of "where am I."
- **Breadcrumbs on admin and deep nested:** explicit path.
- **Section headings on long pages:** orient within page.
- **"Currently viewing" indicators:** e.g., when filtered, show active filter chips.
- **Notification badge counts:** glanceable summaries on icons.

---

## 15. Open Decisions

Things to test or decide during design phase:

- Should "Posts" be a top-level mobile tab? Or accessed via filter? Tested by usage.
- Should "Resources" appear in primary nav at all on mobile? Or live inside Q&A as a tab?
- Where does "Help" sit — under profile menu only, or also a footer nav item?
- Should there be a "compose" floating action button (FAB) on mobile? Convention in some apps but visually heavy.
- Search behavior: dedicated tab vs persistent input at top of every page?

These get resolved with usability testing on prototypes, not on guesswork.
