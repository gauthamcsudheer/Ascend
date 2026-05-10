# Ascend — Screen Inventory & Layout Specifications

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers, QA |
| Purpose | Every screen in the product, with its purpose, layout pattern, content, and key interactions. |

> Each screen entry includes: **purpose**, **primary user**, **entry points**, **layout** (mobile and desktop), **key content blocks**, **primary actions**, **state notes** (empty, loading, error). This is the build checklist; the visual designer fills in pixel-level details on top.

---

## A. Authentication & Onboarding

### A1. Landing / Login (`/auth/login`)

**Purpose:** Entry point for returning users and the brand-front for visitors.

**Primary user:** Anyone arriving at the app URL.

**Entry points:** Direct URL, expired session redirect, after sign-out.

**Layout (mobile):** Single-column. Logo + tagline at top; email/password form; "Sign in with Google" button below; "Forgot password?" link; "New to Ascend? Create an account" link at bottom.

**Layout (desktop):** Centered card (max-width 440px) with same content; subtle background pattern or color block on left third (decorative, low-emphasis).

**Key content:** Logo, tagline ("Ask. Answer. Connect."), email input, password input, MFA prompt if enabled, Google SSO button, recovery link, signup link.

**Primary actions:** Sign in, Sign in with Google, Forgot password, Create account.

**States:**
- Default
- Submitting (button loading)
- Invalid credentials (inline error, generic message)
- Account locked (403 response) → show with unlock time
- MFA required (prompt for code)

### A2. Signup Persona Selector (`/auth/signup`)

**Purpose:** Pick which persona is creating an account.

**Layout:** Three large cards: Student / Faculty / Alumnus. Each card briefly describes who it's for and what verification looks like. "Sign in instead" link at bottom.

**Notes:** This screen exists because each persona has a different signup form. Putting them all on one form would be confusing.

### A3. Student Signup (`/auth/signup/student`)

**Layout (mobile):** Vertical form: email, password (with strength indicator), name, branch (select), current semester (select 1-8), batch year (select), is-lateral-entry (checkbox), accept privacy (checkbox + linked policy).

**Email validation:** must end with `@rajagiri.edu.in`. Error inline.

**Help text:** "We'll auto-verify your account using your institutional email." below email.

**Submit button:** "Create account."

### A4. Faculty Signup (`/auth/signup/faculty`)

**Same as Student but:**
- Email: `@rajagiritech.edu.in` required.
- Branch field replaced with Department.
- No semester or batch year fields.

### A5. Alumnus Signup (`/auth/signup/alumnus`)

**Layout:** email (any domain), password, name, branch, batch year, current role, current company, LinkedIn URL (validated as LinkedIn link), short note "Why are you joining Ascend?" (helps verifiers, max 500 char), accept privacy.

**Help text below submit:** "Your account will be reviewed by our team. This usually takes up to 3 days. We'll email you when it's verified."

### A6. Email Verification (`/auth/verify-email?token=...`)

**Purpose:** Activate a signed-up account via email link.

**Layout:** Centered card. Success or failure message based on token validity.

**States:**
- Verifying (spinner)
- Verified (success message + "Continue to Ascend" CTA)
- Token expired (resend prompt)
- Token invalid (sign-in link)

### A7. Pending Verification (`/pending-verification`)

**Purpose:** Holding page for alumni waiting for admin approval.

**Layout:** Centered illustration (placeholder until designer creates) + heading "Hang tight, [name]." + body: "Your alumni account is being verified. We typically respond within 3 days. While you wait, you can browse Ascend and ask questions." + secondary actions: Browse Q&A, Edit Profile, Sign out.

**Notes:** This is a real screen, not just a banner. Pending alumni can't access the main app surfaces fully.

### A8. Forgot Password (`/auth/forgot-password`)

**Layout:** Email input, Submit. Success message: "If an account exists for that email, we've sent reset instructions." (Same message regardless of validity — no enumeration.)

### A9. Reset Password (`/auth/reset-password?token=...`)

**Layout:** New password input (with strength), confirm password input, Submit. Success → redirect to login with success toast.

### A10. MFA Setup (`/auth/mfa-setup`)

**Purpose:** Enable MFA for an account.

**Layout (mobile):** Step-by-step guidance.
1. "Install an authenticator app" with links to Google Authenticator and Authy.
2. "Scan this QR code" (large QR; tap to copy secret as text fallback).
3. "Enter the 6-digit code" — input + Verify.
4. "Save these recovery codes" — list of 10 codes + copy button + acknowledge checkbox.

**Layout (desktop):** Same content, multi-column where it fits.

### A11. MFA Challenge (`/auth/mfa-challenge`)

**Purpose:** Prompt for MFA code during login.

**Layout:** Code input (6 digits, auto-focus, monospace), Verify button, "Use recovery code" link, "Trouble?" link.

### A12. First-Time Tour (`/onboarding/welcome`, etc.)

Three lightweight screens (per IA doc § 7).

**Each:** Heading + brief explanation + optional illustration + "Continue" / "Skip" buttons. Step indicator at top (1 of 3, etc.).

---

## B. Home & Feeds

### B1. Home (`/`)

**Purpose:** Personalized landing for authenticated users; the default destination.

**Primary user:** All authenticated users, every visit.

**Entry points:** Logo click, Home tab/link, post-login redirect.

**Layout (mobile):**
- Top: status banner if applicable (verification pending, etc.)
- Tab strip: For You / Following / Department (3 tabs)
- Feed: vertical list of mixed content (questions + posts), card-based
- Bottom nav fixed

**Layout (desktop):**
- Top nav fixed
- Three-column: left rail (160px) with "What's happening" widget (active tags, online faculty?, your stats), center column (max 720px) with feed, right rail (260px) with prompts (suggested follows, unanswered questions in your area, badge progress)
- Each card slightly more spacious than mobile

**Tab content:**
- **For You:** algorithmic mix of followed tags, recent activity from connections, dept activity
- **Following:** strict chronological from explicitly followed users + tags
- **Department:** content from your branch/department

**Key content blocks:**
- Question Cards (most common)
- Post Cards (interleaved)
- Suggestion cards: "Follow these tags to see more" (after 3 cards if user has few follows)
- Day separators ("Today", "Yesterday", "This week") on Following tab

**Primary actions:** Read a card (click), vote, bookmark, follow tag/user.

**States:**
- **Empty (new user, no follows):** Empty state with "Your feed is quiet — follow some tags to start." + Browse Tags CTA.
- **Empty (user with follows but no recent content):** "Nothing new from your follows. Browse all questions or check back later."
- **Loading:** Skeleton cards.
- **Error:** Error state with retry; cached content if available.

### B2. Question List (`/questions`)

**Purpose:** Browse all questions with filtering.

**Layout (mobile):**
- Top: search input + "Ask a Question" button
- Filter chips row: Tags, Branch, Status (Unanswered), Sort
- "Filters" button opens bottom sheet for advanced
- List of Question Cards

**Layout (desktop):**
- Top nav
- Two-column: filter sidebar (240px) with collapsible filter sections, main content with question cards
- "Ask a Question" button prominent at top of main content

**Default sort:** Recent activity (last vote, comment, or new answer).

**Filter options:** Tags (multi-select), Branch (multi-select), Persona of asker, Status (Unanswered, Recently answered, Accepted), Date range.

**States:**
- Filtered with no results: "No questions match these filters. Try removing some, or [Ask a Question]."
- Loading more: spinner at bottom of list.

### B3. Question Detail (`/questions/:id`)

**Purpose:** Read a question and its answers; act on it.

**Primary user:** Anyone who clicks a question.

**Layout (mobile):**
- Back button + sticky condensed title on scroll
- Question section:
  - Asker meta (persona indicator + name or "Anonymous" + timestamp)
  - Title (text-2xl on mobile)
  - Body (Reading typography: Source Serif if loaded, fallback Inter)
  - Tags
  - Vote control (horizontal at bottom)
  - Action row: bookmark, share, report, edit (if author)
- Answer section header: "N Answers"
- Answer sort selector: Top / Recent
- Answer cards: each with author meta, body, vote, accept toggle (if asker), endorsement chip if faculty-endorsed, action menu, comments below
- Composer at bottom: "Write your answer" (visible if eligible per Dynamic Seniority Engine; else explanation of why not)
- Comments thread under question (collapsed by default if many)

**Layout (desktop):**
- Centered single-column max 800px (reading width)
- Vote control on left rail (sticky as you scroll)
- Right rail (300px): related questions, asker mini-profile
- Same content blocks otherwise

**Primary actions:** Vote, write answer, accept answer (asker), endorse answer (faculty), comment, bookmark, share, report.

**States:**
- **Anonymous question:** asker shown as "Anonymous Student" with persona-tinted avatar but no name; asker still sees their own posts identified.
- **Question with no answers:** "Be the first to answer" prompt below the question (if eligible).
- **Question where user not eligible to answer:** explanation visible: "You'll be eligible to answer this asker once you reach semester 5."
- **Archived question:** read-only banner, no answers can be added.
- **Question deleted:** 404-style state.

### B4. Ask Question (`/questions/ask`)

**Purpose:** Compose and submit a new question.

**Layout (mobile):** Stepped or progressive form. Single page: title input → body markdown editor → tag picker → anonymous toggle (clearly labeled) → visibility scope (institution/department) → Submit.

**Duplicate detection:** As user types title (debounced 500ms), show "Similar questions" panel with up to 3 matches; user can navigate to existing or continue.

**Help text under tag picker:** "Tags help others find your question. Add 1-5 tags."

**Help text under anonymous toggle:** "Your name won't be shown to other users. Admins still see you for moderation. Use this when needed."

**Submit:**
- "Post Question" button.
- After submit: redirect to question detail.

**States:**
- **Draft auto-saved:** small indicator "Saved" (timestamp).
- **Validation errors:** inline.
- **Rate-limited:** banner "You've reached your hourly post limit. Try again at HH:MM."

### B5. Edit Question (`/questions/:id/edit`)

**Layout:** Same form as Ask, pre-filled. Submit becomes "Save changes." Edit count is incremented; an "edited" indicator appears on the question.

---

## C. Posts (Experience Feed)

### C1. Post List (`/posts`)

**Layout:** Similar to Question List but cards are Post Cards. Filter by category (Internship, Project, etc.), tags, branch.

**Pinned faculty announcements** appear at top regardless of sort.

### C2. Post Detail (`/posts/:id`)

**Layout:** Reading-width column with author meta, title, body (longer than questions, supports more formatting), tags, vote/upvote control, comments. No "answers" — posts get comments only.

### C3. Create Post (`/posts/new`)

**Layout:** Form with title, body (markdown editor), category (select), tags, expiry date (only if Faculty Announcement).

---

## D. Resources

### D1. Resource Library (`/resources`)

**Purpose:** Browse vetted resources.

**Layout:**
- Tabs: Library (default) / Pending
- Filter: category (chip row), tags (selector)
- Sort: Most popular (default for Library), Recent
- Grid (desktop) or list (mobile) of Resource Cards

**Library tab:** only Resources with status=LIBRARY.

**Pending tab:** all submissions, sorted Recent.

### D2. Resource Detail (`/resources/:id`)

**Layout:**
- Submitter meta + timestamp
- Title (linked to URL with external icon and `nofollow`)
- Description
- Tags
- Endorsements section (faculty avatars who endorsed + count)
- Vote control
- Comments
- Action: Report broken link

**For pending resources:** banner "This resource is pending promotion. It needs more endorsements or upvotes to enter the Library."

### D3. Submit Resource (`/resources/submit`)

**Layout:** URL input → server fetches OG → Title pre-filled (editable) → Description → Category → Tags → Submit.

**OG fetch state:** "Fetching info…" spinner; if fails, manual entry note.

---

## E. People & Profiles

### E1. People Browse (`/people`)

**Purpose:** Find people to follow or connect with.

**Layout:**
- Search input + filters: persona, branch, batch, expertise tags
- Sort: by relevance (matching expertise tags), by activity
- Grid of mini profile cards (avatar, name, persona, expertise tags, "Follow" button)

### E2. User Profile (`/people/:id`)

**Layout (mobile):**
- Profile header (avatar xl, name, persona, bio, stats row)
- Action row: Follow / Connect / More menu
- Tab strip: Activity / Questions / Answers / Posts / Resources / Badges
- Selected tab content

**Layout (desktop):**
- Two-column: left (300px) profile sidebar with header + meta + stats + badges; right (flex) tabbed content

**Anonymous-asked questions** are not visible on the asker's profile (consistent with anonymity promise).

**Privacy:** if user has `hideActivity=true`, hide the stats row and tabs other than profile basics.

### E3. Edit Profile (`/profile/me/edit`)

**Layout:** Form with all editable fields (name, bio, expertise tags, persona-specific fields). Tabs for sections if many: Basics / Expertise / Privacy.

---

## F. Connections & Messages

### F1. Connections List (`/connections`)

**Purpose:** Manage active connections, view requests.

**Layout:**
- Tabs: Active (default) / Sent / Received
- Active tab: list of connection cards (avatar, name, persona, "Message" button)
- Sent tab: list of pending sent requests with status; cancel option for pending
- Received tab: list of received requests with Accept / Decline / Decline silently buttons

**Empty states per tab.**

### F2. Send Connection Request (modal from a profile)

**Layout:** Modal (or full-screen on mobile) with:
- Recipient meta at top
- Topic input (required, brief reason for connecting; max 120 char)
- Note textarea (required, 50-500 chars)
- Quota indicator: "You have N of 5 outstanding requests."
- Send button

**States:**
- Recipient blocks requests: form not shown; explanation: "This member isn't accepting new connections right now."
- Already connected: form not shown; "Message" link instead.
- At quota: form disabled; explanation.

### F3. Decline Connection (modal from received request)

**Layout:**
- "Decline (with reason)" — input for reason (optional but encouraged), sender sees reason
- "Decline silently" — sender just sees "Request expired" eventually, no notification of decline
- Cancel

### F4. Messages List (`/messages`)

**Layout:**
- Header: "Messages"
- Search messages input
- List of thread items: counterparty avatar, name, latest message preview, timestamp, unread indicator
- Tap thread → thread view

**Empty state:** "No messages yet. Connect with members from their profiles to start a conversation."

### F5. Message Thread (`/messages/:threadId`)

**Layout:**
- Header: counterparty avatar, name, persona; "..." menu (Disconnect, Block, Report)
- Scrollable message list (newest at bottom; auto-scroll on new message)
- Composer at bottom (textarea, send button)

**Behaviors:**
- Pull-to-refresh loads older messages.
- Send via keyboard Enter (mobile) or Cmd/Ctrl+Enter (desktop).
- Failed send: retry button on the message.
- Other party typing: subtle indicator below latest message.

**Empty state (new thread):** Just the composer; no messages yet.

---

## G. Notifications

### G1. Notifications List (`/notifications`)

**Layout:**
- Header: "Notifications" + "Mark all as read" button
- Tabs: All / Unread (badge count)
- List of Notification List Items grouped by day

**Behaviors:**
- Tap notification → navigate to target + mark as read.
- Long-press (mobile) or right-click (desktop) → quick actions: Mark as read/unread, Mute this thread.

**Empty state:** "You're all caught up." (matter-of-fact, not enthusiastic).

### G2. Notification Preferences (`/notifications/preferences`)

**Layout:**
- Matrix view (rows: notification categories; columns: In-app, Email, Push)
- Each cell is a toggle switch
- Sections: Activity, Connections, Reputation, Moderation, Digest, Account

**Mobile:** rows stacked, each row is "Category" + 3 toggle switches in a sub-row.

---

## H. Search

### H1. Search Results (`/search?q=...`)

**Layout (mobile):**
- Search input at top (sticky)
- Tab strip: All / Questions / Posts / Resources / People / Tags
- Filter button → bottom sheet
- Results list, scoped to selected tab

**Layout (desktop):**
- Search input full-width at top
- Two-column: filters (left, 240px), results (main)

**"All" tab:**
- Top 3 from each category, with "See all in [category]" links to switch to that tab.

**Per-category tabs:**
- Paginated results.

**Sort:** Relevance (default), Recent, Top.

**Empty states:** "No results for '[query]'. Try different keywords or remove filters."

---

## I. Tags

### I1. Tags Browse (`/tags`)

**Layout:** Grid of tag cards. Each card: tag name, follower count, recent activity count. Search input for filtering by name. Group by category if helpful.

### I2. Tag Detail (`/tags/:slug`)

**Layout:** Tag header (name, description, follow button, follower count). Tabs: Questions / Posts / Resources. Content scoped to that tag.

---

## J. Bookmarks

### J1. Bookmarks (`/bookmarks`)

**Layout:** Tabs (Questions / Posts / Resources). List of bookmarked items with the same card type as their source.

**Sort:** Recently bookmarked.

**Per-item action:** Remove bookmark (toast confirms removal with "Undo").

---

## K. Badges

### K1. My Badges (`/badges/me`)

**Layout:** Earned badges as a grid; "All possible badges" link.

**Each badge:** prominent display with date earned, description of how earned.

### K2. All Badges (`/badges/all`)

**Layout:** All badge types, with explanation of criteria. Earned ones marked with "Earned" pill; unearned shown grayed.

---

## L. Settings

All settings pages share a common layout: sidebar (desktop) or list (mobile) with active item highlighted; main area with form.

### L1. Account (`/settings/account`)

Email (display only; change via email-change flow), name, basic profile fields.

### L2. Notifications (`/settings/notifications`)

Same as G2.

### L3. Privacy (`/settings/privacy`)

- Hide activity from others (toggle)
- Don't allow connection requests (toggle)
- Block list link
- Anonymous question toggle default (preference)

### L4. Connections (`/settings/connections`)

Quota status, default acceptance behavior, link to manage active.

### L5. Blocked Users (`/settings/blocked`)

List of blocked users with unblock action.

### L6. Sessions (`/settings/sessions`)

List of active sessions with device/IP info; "Sign out" per session; "Sign out all other sessions."

### L7. Security (`/settings/security`)

- Change password
- MFA: enable/disable
- Recovery codes (regenerate)

### L8. Data & Privacy (`/settings/data`)

- Export my data (request → email when ready)
- Delete account (lead to confirmation flow)
- Privacy policy version + acknowledged date

### L9. Admin Activity (`/settings/admin-activity`)

List of admin actions on the user's account: verifications, content removals, suspensions, with dates and reasons.

### L10. Account Deletion Flow

Multi-step:
1. Reason for leaving (optional select)
2. Choose mode: Anonymize content / Hard delete
3. Confirm by typing "DELETE"
4. Final confirmation
5. 14-day grace period banner; user logged out

---

## M. Admin

### M1. Admin Dashboard (`/admin`)

**Layout:** Cards summarizing pending actions:
- Pending verifications (count + link)
- Open reports (count + link, severity breakdown)
- Pending tag suggestions (count)
- Recent flagged content (count)
- Activity metrics (signups today, content removed this week)

### M2. Verifications Queue (`/admin/verifications`)

**Layout:**
- Filters: branch, batch year, registration date
- Sortable list of pending users with key info (name, branch, batch, evidence summary)
- Bulk actions toolbar (select multiple → approve/reject)
- Per-row: Approve / Reject buttons

### M3. User Verification Detail (modal or `/admin/verifications/:id`)

Full submitted details, LinkedIn link, internal notes section, Approve/Reject with reason.

### M4. Reports Queue (`/admin/reports`)

**Layout:**
- Filters: status, severity, target type, age
- List of reports with target preview + reason + reporter (collapsed)
- Per-row action: Resolve

### M5. Resolve Report (modal)

Action select (None, Warned, Content removed, Suspend X, Ban), Resolution notes, Apply.

### M6. Users Admin (`/admin/users`)

Search, list with persona, status, actions (suspend, ban, change persona).

### M7. User Admin Detail (`/admin/users/:id`)

Full user details, action history, content history, suspension/ban controls.

### M8. Tags Admin (`/admin/tags`)

List of all tags. Create new tag form. Per-tag: edit, merge, deprecate.

### M9. Tag Suggestions (`/admin/tag-suggestions`)

Pending suggestions with approve (with optional rename) / reject.

### M10. Audit Log (`/admin/audit`)

Filterable, paginated list of audit entries. Filters: actor, action, target type, date range.

### M11. Calendar (`/admin/calendar`)

Active semester display + form to add new + list of past.

### M12. Admins (`/admin/admins`)

List of current admins with grant/revoke.

---

## N. Help & Static

### N1. Help Index (`/help`)

Card grid of help topics.

### N2. Help Article (`/help/:slug`)

Article-style reading layout (max-width 720px), Source Serif body, table of contents on right rail (desktop).

### N3. Privacy Policy (`/privacy`)
### N4. Terms (`/terms`)
### N5. About (`/about`)

Static informational pages with same layout as help articles.

---

## O. Error & Edge Pages

### O1. 404 (Not Found)

Centered illustration (TBD) + "We couldn't find that page" + "Go to Home" + recent visited list (if available).

### O2. 403 (Forbidden)

"You don't have access to this page." + brief explanation if known + "Go to Home."

### O3. Account Suspended (`/account-status`)

"Your account is suspended until [date]" + reason summary + appeal contact.

### O4. Maintenance Mode

Full-page banner: "Ascend is updating. We'll be back shortly." + ETA if known.

---

## Screen Count Summary

- **Auth:** 12 screens
- **Home/Feeds:** 5 screens
- **Posts:** 3 screens
- **Resources:** 3 screens
- **People:** 3 screens
- **Connections/DM:** 5 screens
- **Notifications:** 2 screens
- **Search:** 1 screen
- **Tags:** 2 screens
- **Bookmarks:** 1 screen
- **Badges:** 2 screens
- **Settings:** 10 screens
- **Admin:** 12 screens
- **Help:** 5+ screens (article count grows)
- **Errors:** 4 screens

**Total: ~70 distinct screens.**

This is the build inventory. The visual designer creates mockups for each (high-fidelity for the most-used ~25, lower fidelity for the rest, especially admin). Each screen also has empty / loading / error variants — see State Catalog doc.
