# Ascend — State Catalog

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers, QA |
| Purpose | The states everyone forgets. Every list, every page, every form has variants beyond "the happy path." This is the catalog. |

> Most products are designed for the populated, working state. Then production reality hits: empty lists, slow connections, dropped requests, edge cases. This document inventories those states for every meaningful surface so design and engineering treat them as first-class, not afterthoughts.

---

## 1. State Categories

Every interactive surface has variants of these states:

| Category | When |
|---|---|
| **Default / Populated** | Happy path with content |
| **Loading** | Initial load, in-flight request |
| **Empty (first-time)** | User has never had content |
| **Empty (filtered)** | User filtered to no results |
| **Empty (cleared)** | User removed their content |
| **Empty (quiet)** | Could have content; currently doesn't |
| **Error (network)** | Connection failed |
| **Error (server)** | 500-level response |
| **Error (permission)** | 403 |
| **Error (not found)** | 404 |
| **Error (rate limited)** | 429 |
| **Error (validation)** | Form-specific |
| **Stale** | Cached content while refetching |
| **Offline** | No connectivity |
| **Partial** | Some data loaded, some failed |
| **Permission denied** | User lacks access at component level |
| **Restricted** | User account suspended/limited |

Not every surface has every variant. The catalog below lists which apply per surface and what the experience should be.

---

## 2. Auth Screens

### 2.1 Login (`/auth/login`)

| State | Treatment |
|---|---|
| Default | Form visible, focus on email field |
| Submitting | Button shows spinner, "Signing in…" label, fields disabled |
| Invalid credentials | Inline error: "Email or password is incorrect" (generic, no enumeration) |
| Account locked | Inline error: "Too many failed attempts. Try again at HH:MM." |
| Account pending verification | Successful sign-in but redirect to `/pending-verification` |
| Account suspended | Successful sign-in but redirect to `/account-status` with details |
| MFA required | Form replaced by MFA challenge, focus on code input |
| Network error | Inline error: "We couldn't reach the server. Check your connection." Retry button. |
| Server error (500) | Toast: "Something on our end isn't working. Try again in a moment." |

### 2.2 Signup (any persona)

| State | Treatment |
|---|---|
| Default | Empty form |
| Submitting | Button loading; fields disabled |
| Validation errors | Per-field inline (email format, password strength, etc.) |
| Email already exists | Inline on email field: "An account already uses this email. [Sign in instead]" |
| Wrong domain (student/faculty) | Inline: "Students sign up with `@rajagiri.edu.in` email. Use the alumni form if you've graduated." |
| Server error | Form retained; toast for retry |
| Privacy not accepted | Cannot submit; checkbox highlighted |

### 2.3 Email Verification

| State | Treatment |
|---|---|
| Verifying | Spinner + "Verifying your email…" |
| Verified | Success card + "Continue to Ascend" CTA |
| Token expired | Card: "This link has expired. [Request a new one]" |
| Token invalid | Card: "This link doesn't work. Try signing in or requesting a new verification email." |
| Already verified | Card: "Already verified. [Continue to Ascend]" |

### 2.4 Pending Verification (`/pending-verification`)

| State | Treatment |
|---|---|
| Pending (default) | Card with explanation, ETA, browse/edit profile actions |
| Verified (race condition; checked while on this page) | Auto-redirect to home with welcome toast |
| Rejected | Card explaining what's needed, "Update profile" link |

---

## 3. Home Feed (`/`)

| State | Treatment |
|---|---|
| Loading | Skeleton cards (3-5 visible) |
| Default (populated) | Mixed feed cards |
| Empty (first-time, no follows) | Illustration placeholder + "Your feed is quiet right now" + body + "Browse tags" CTA |
| Empty (has follows, no recent activity) | Brief: "Nothing new from your follows. [Browse all]" |
| Loading more (infinite scroll) | Spinner at bottom of list |
| End of results | Quiet text: "You're caught up." |
| Network error on initial load | Error state: "We couldn't load your feed. [Try again]" |
| Network error on infinite scroll | Inline retry button at bottom of list |
| Stale (cached, refetching) | Existing content visible; subtle "Updating…" indicator |
| Offline | Cached content shown if available; banner: "You're offline. Some things may not work." |

### 3.1 For You / Following / Department Tabs

Each tab has its own empty state if applicable:

- **For You empty:** "Your For You feed needs a few signals. Follow some tags or people."
- **Following empty (no follows):** "You're not following anyone yet. [Browse people] or [Browse tags]."
- **Following empty (follows but quiet):** "Nothing new from who you follow."
- **Department empty:** "Quiet in [Department] right now. [Ask a question]."

---

## 4. Question List (`/questions`)

| State | Treatment |
|---|---|
| Loading | Skeleton question cards |
| Populated | Sorted list of question cards |
| Filtered to empty | "No questions match these filters. [Clear filters]" |
| All filters cleared, still empty | (Shouldn't happen; if it does, show generic empty.) |
| Loading more | Spinner |
| End of results | Quiet text: "End of results" |
| Network error | Standard error state with retry |

### 4.1 Question Detail (`/questions/:id`)

| State | Treatment |
|---|---|
| Loading | Skeleton: title placeholder, body placeholder, vote placeholder, answer count placeholder |
| Populated, no answers | Question shown; below it: "No answers yet. [Be the first to answer]" (if eligible) or "No answers yet. Watch for replies." |
| Populated with answers | Standard layout |
| Question deleted (soft) | "This question was removed by its author or an admin." |
| Question deleted (hard, e.g., wrong ID) | 404 page |
| Question archived | Banner: "This question is archived. Read-only." |
| User not eligible to answer | Composer hidden; explanation: "You'll be eligible to answer when you reach semester X" or "Verified faculty/alumni can answer." |
| User is question author | Composer hidden; "You can edit your question if you'd like to clarify." |
| Anonymous question (other viewers) | Asker shown as "Anonymous Student" with persona-tinted avatar, no name |
| Anonymous question (asker viewing own) | Asker sees their identity normally |
| Question with new answers (real-time arrival) | Banner above answer list: "[N] new answer(s). [Refresh]" |

### 4.2 Ask Question (`/questions/ask`)

| State | Treatment |
|---|---|
| Empty form | Default with prompts (placeholder in title, etc.) |
| Typing title | Debounced duplicate detection panel appears with similar questions if found |
| Tag picker open | Suggestions appear; "Suggest a new tag" link if query has no match |
| Validation errors | Per-field inline |
| Rate limit hit | Banner: "You've reached your hourly post limit. You can post again at HH:MM." Form disabled. |
| Submitting | Button loading |
| Draft auto-saved | Subtle "Saved" indicator next to title |
| Server error on submit | Toast retry; form retains all entered data including draft |
| Successfully posted | Redirect to question detail with "Question posted" toast |

---

## 5. Posts (`/posts`)

Same state patterns as Questions, with these specifics:

| State | Treatment |
|---|---|
| Empty (filtered to category, no posts) | "No posts in [category] yet. [Create one]" if user is faculty creating announcements; otherwise just the empty state |
| Faculty announcement expired | Card shows "Expired [date]" indicator |
| Pinned faculty announcement | Visual treatment with pin icon; appears at top of category feeds |

---

## 6. Resources (`/resources`)

### 6.1 Library Tab

| State | Treatment |
|---|---|
| Loading | Skeleton resource cards |
| Populated | Cards with optional endorsement chips |
| Empty (no library yet) | "The Library is starting out. [Browse pending] or [Submit a resource]" |
| Resource with broken link | Card shows warning chip: "Link may be broken" |
| Resource pending | Not in this tab (in Pending tab) |

### 6.2 Pending Tab

| State | Treatment |
|---|---|
| Empty | "Nothing pending. [Submit a resource]" |
| Resource needs more endorsements | Card shows "Needs N more endorsement(s) or M more upvotes" |

### 6.3 Submit Resource

| State | Treatment |
|---|---|
| URL entered | Server fetches OG; "Fetching info…" spinner |
| OG fetch success | Title and description pre-filled (editable) |
| OG fetch failed | Manual entry: "We couldn't fetch info from this URL. Add a title and description." |
| Validation errors | Per-field inline |
| Rate limit | "You've reached your hourly submission limit." |
| Submitted | Redirect to detail with toast: "Submitted. It'll appear in the Pending tab." |

---

## 7. People & Profile

### 7.1 People Browse (`/people`)

| State | Treatment |
|---|---|
| Loading | Skeleton person cards |
| Populated | Grid of cards |
| Empty (filtered) | "No one matches these filters." |

### 7.2 User Profile (`/people/:id`)

| State | Treatment |
|---|---|
| Loading | Skeleton header + tab placeholders |
| Default | Header + tabs |
| User has hideActivity=true | Header shown without stats; tabs hidden except "About" / basic info |
| User blocked you | "You can't view this profile." (Generic; doesn't reveal it's a block.) |
| You blocked this user | Header shown with "You've blocked this user. [Unblock]" banner |
| Pending alumnus | Header shows pending indicator; some actions disabled |
| Suspended user | "This user's account is currently suspended." (To other viewers.) |
| Deleted user (anonymized) | Profile shows "Deleted User" with no contributions linked |
| Deleted user (hard delete) | 404 |

### 7.3 Profile Tabs (Activity / Questions / Answers / Posts / Resources / Badges)

Per tab:

| Tab | Empty state |
|---|---|
| Activity | "No recent activity." |
| Questions | "No questions yet." |
| Answers | "No answers yet." |
| Posts | "No posts yet." |
| Resources | "No resources submitted." |
| Badges | "No badges yet. [How to earn badges]" |

### 7.4 Edit Profile (`/profile/me/edit`)

| State | Treatment |
|---|---|
| Loading | Skeleton form |
| Populated | Pre-filled form |
| Validation errors | Per-field inline |
| Saving | Button loading |
| Saved | Toast: "Profile updated." |
| Save failed | Toast retry; form retains data |

---

## 8. Connections & Messages

### 8.1 Connections List (`/connections`)

| Tab | Empty state |
|---|---|
| Active | "No connections yet. [Browse people]" |
| Sent | "No pending requests sent." |
| Received | "No requests waiting." |

### 8.2 Send Connection Request (modal)

| State | Treatment |
|---|---|
| Default | Form with topic + note |
| Recipient blocks requests | Modal not shown; profile shows "[name] isn't accepting new connections." |
| Already connected | Modal not shown; "Message" link instead |
| At quota | Form disabled: "You have 5 outstanding requests. Wait for a response or cancel one." |
| Submitting | Button loading |
| Sent | Modal closes; toast: "Request sent to [name]." |
| Validation error (e.g., note too short) | Per-field inline |
| Server error | Toast retry |

### 8.3 Messages List (`/messages`)

| State | Treatment |
|---|---|
| Loading | Skeleton thread items |
| Empty | "No messages yet. Connect with members from their profiles to start a conversation." |
| Network error | Error state with retry |

### 8.4 Message Thread (`/messages/:threadId`)

| State | Treatment |
|---|---|
| Loading | Skeleton message bubbles |
| Empty (new thread) | Just the composer; no bubbles |
| Populated | Standard message list |
| Sending | Bubble appears with "Sending…" indicator |
| Send succeeded | Bubble updates to normal state with timestamp |
| Send failed | Bubble shows red border + retry button |
| Other party typing | Subtle indicator below latest message |
| Other party offline | (We don't show online status in v1.) |
| Thread disconnected by other | System message: "[name] disconnected. You can no longer message each other." Composer disabled. |
| Thread disconnected by you | Same; composer disabled. |
| Recipient blocked you | Thread becomes read-only with: "You can no longer message this person." |
| You blocked recipient | Same; "[name] is blocked. [Unblock]" |
| Loading older messages | Spinner at top |

---

## 9. Notifications

### 9.1 Notifications List (`/notifications`)

| State | Treatment |
|---|---|
| Loading | Skeleton notification items |
| Empty (default) | "All caught up." (matter-of-fact) |
| Populated | List grouped by day |
| All read filter, none unread | "No unread notifications." |

### 9.2 Notification Preferences

| State | Treatment |
|---|---|
| Loading | Skeleton matrix |
| Populated | Matrix of toggles |
| Saving (per-toggle) | Toggle in mid-state briefly |
| Save failed | Toast: "Couldn't save. Try again." Toggle reverts. |

---

## 10. Search

### 10.1 Search Typeahead (Inline)

| State | Treatment |
|---|---|
| Input empty, focused | Recent searches (max 3); "Browse all tags" link |
| Input < 2 chars | Hidden |
| Input ≥ 2 chars, loading | Suggestions area shows "Searching…" |
| Suggestions populated | Grouped by type: tags, people, "Search for '[query]'" |
| No suggestions | "No suggestions. [Search anyway]" |

### 10.2 Search Results (`/search?q=...`)

| State | Treatment |
|---|---|
| Loading | Skeleton results |
| Populated | Tabbed results |
| Empty (no results in any category) | "No results for '[query]'. Try different keywords or fewer filters." |
| Empty (no results in selected tab, results in others) | "No [type] for '[query]'. There are results in other categories: [pivots]" |
| Filtered to empty within tab | "No matches with these filters. [Clear filters]" |

---

## 11. Tags

### 11.1 Tag Browse (`/tags`)

| State | Treatment |
|---|---|
| Loading | Skeleton tag cards |
| Populated | Tag grid |
| Empty (filtered by name) | "No tags match." |

### 11.2 Tag Detail (`/tags/:slug`)

| State | Treatment |
|---|---|
| Loading | Skeleton header + skeleton list |
| Populated (per tab) | Standard list |
| Empty per tab | "No questions tagged [tag-name] yet" / "No posts" / "No resources" |
| Deprecated tag (merged into another) | Banner: "This tag is now [canonical-tag]. [Go there]" |

---

## 12. Bookmarks (`/bookmarks`)

| Tab | State | Treatment |
|---|---|---|
| Questions | Empty | "No bookmarked questions." |
| Posts | Empty | "No bookmarked posts." |
| Resources | Empty | "No bookmarked resources." |
| All tabs | Removed bookmark | Toast: "Removed. [Undo]" |

---

## 13. Badges (`/badges/me`, `/badges/all`)

| State | Treatment |
|---|---|
| My badges, none earned | "No badges yet. Engage with the community to earn them. [How badges work]" |
| My badges, some earned | Grid + "View all possible badges" link |
| All badges | Grid showing earned (color) and unearned (grayed) |

---

## 14. Settings

### 14.1 Each Settings Page

| State | Treatment |
|---|---|
| Loading | Skeleton form |
| Populated | Pre-filled form |
| Saving | Button loading; toggles in mid-state |
| Saved | Toast: "Saved." |
| Save failed | Toast retry; form data retained |

### 14.2 Sessions (`/settings/sessions`)

| State | Treatment |
|---|---|
| Loading | Skeleton session items |
| Populated | List of sessions; current session marked "This device" |
| Single session | "This is your only active session." |
| Sign out other | Confirmation; on success, that row removes |
| Sign out all | Confirmation; user kept on this device |

### 14.3 Account Deletion (`/settings/data` → multi-step flow)

| Step | State | Treatment |
|---|---|---|
| Step 1: Reason | Default | Optional select; Continue |
| Step 2: Mode | Default | Anonymize / Hard delete options with explanation |
| Step 3: Confirm | Default | "Type DELETE to confirm" input |
| Step 3: Confirm typed correctly | Default | Submit enabled |
| Submitting | Button loading | "Deleting…" |
| Submitted | Confirmation page | "Account scheduled for deletion. You have 14 days to undo. You'll be signed out now." |
| Recovery window (returning user during 14-day) | Login redirects | "Your account is scheduled for deletion. Recover now?" |

### 14.4 Data Export

| State | Treatment |
|---|---|
| Default | "Export my data" button |
| Requested | Banner: "Export requested. We'll email you when it's ready." |
| Ready | Banner: "Your export is ready. [Download]" |
| Expired | Banner: "Previous export link expired. [Request again]" |

---

## 15. Admin Surfaces

### 15.1 Admin Dashboard (`/admin`)

| State | Treatment |
|---|---|
| Loading | Skeleton cards |
| All quiet (no pending) | Cards show zeros; "Nothing waiting" |
| Pending items | Cards show counts and link to queues |

### 15.2 Verifications Queue

| State | Treatment |
|---|---|
| Loading | Skeleton list |
| Empty | "No pending verifications." |
| Populated | List with bulk-action toolbar |
| Approving (per item) | Item shows loading; on success, removes from list |
| Approve failed | Item retains; inline error |

### 15.3 Reports Queue

| State | Treatment |
|---|---|
| Loading | Skeleton |
| Empty | "No open reports." |
| Populated | List sorted by severity then age |
| Resolving | Item state changes to "Resolved" |

### 15.4 Other Admin Pages

Same patterns: loading → populated/empty → action states → success/failure handling.

---

## 16. Help & Static Pages

| State | Treatment |
|---|---|
| Loading | Spinner (these load fast; usually no skeleton needed) |
| Default | Article content rendered |
| Article not found | 404 |

---

## 17. Error Pages

### 17.1 404 (Not Found)

```
[Illustration placeholder]
We couldn't find that.

Maybe it was removed, or the link is wrong.

[Go to home]
```

### 17.2 403 (Forbidden)

```
You don't have access to this.

If you think this is a mistake, [contact support].

[Go to home]
```

Note: 403 doesn't reveal whether the resource exists.

### 17.3 500 (Server Error)

```
Something on our end isn't working.

We've been notified and we're looking at it. Try again in a moment.

[Try again]   [Go to home]
```

### 17.4 Account Suspended (`/account-status`)

```
Your account is suspended.

Until: [date]
Reason: [admin reason]

You can read content but can't post, comment, vote, or message.

If you think this is a mistake, [contact support].

[Sign out]
```

### 17.5 Account Banned

```
Your account has been disabled.

Reason: [admin reason]

If you believe this is a mistake, [contact support].

[Sign out]
```

### 17.6 Maintenance

```
Ascend is updating.

We'll be back shortly.

[Optional: estimated duration]
```

### 17.7 Rate Limited (Inline, not full page)

```
You've hit a limit.

You can [action] again at [time].

[Optional: explanation of the limit]
```

---

## 18. Loading State Hierarchy

When deciding which loading pattern to use:

| Time to load | Pattern |
|---|---|
| < 100ms | None (just show the result) |
| 100-300ms | Existing UI stays; subtle indicator if any |
| 300ms-3s | Skeleton matching content shape |
| 3s-10s | Skeleton + "Still loading…" message after 3s |
| > 10s | Progress indicator if determinate; otherwise "This is taking longer than usual" + cancel option |

---

## 19. Network Edge Cases

### 19.1 Slow Connection (3G, 2G)

- Skeletons stay visible longer; that's fine.
- Above-the-fold content prioritized; below-the-fold can stream in.
- No timeout that fails fast — give the request room.
- After 30s with no response, show: "This is taking longer than usual. [Cancel and try again]"

### 19.2 Intermittent Connection

- Failed requests show inline retry where they live.
- Existing content stays visible; we don't blank the page on error.
- "Reconnected" indicator briefly when connection returns.

### 19.3 Lost Connection Mid-Action

| Action | Behavior |
|---|---|
| Posting question | Draft saved locally; retry on reconnect |
| Voting | Optimistic update; reverts if server rejects on reconnect |
| Sending DM | Bubble shows "Sending…" → "Failed [retry]" |
| Loading list | Existing loaded items stay; "Couldn't load more [retry]" |

### 19.4 Offline (no connection at all)

- Cached pages remain visible.
- Banner: "You're offline. Some things may not work."
- Composers allow drafting; submit queues for reconnect.

---

## 20. Permission Edge Cases

### 20.1 Component-Level Permissions

When a user views a page with components they can't all use:

- **Eligible to view, ineligible to act:** action button hidden or disabled with tooltip explaining why.
- **Eligible to view some, not others:** restricted items omitted from list, not shown grayed.

Examples:
- Student in semester 3 viewing a question from semester 4: composer shows explanation, no answer button.
- Faculty viewing a peer faculty's profile: connection request button absent (faculty-faculty connections undefined; clarify in PRD).
- Pending alumnus viewing People Browse: results shown; "Connect" button replaced with: "Available once verified."

### 20.2 Resource-Level Permissions

| Situation | Treatment |
|---|---|
| Try to access another user's settings page | Redirect to own settings |
| Try to access admin URL as non-admin | 403 page |
| Try to access archived question | Read-only view with banner |
| Try to act on suspended user's profile | Action disabled with brief explanation |

---

## 21. Edge Cases Often Missed

### 21.1 Single-Character / Whitespace Inputs

- Search query of just a space: treat as empty, don't search.
- Comment of "   ": rejected with validation error.
- Tag input with trailing whitespace: trimmed silently.

### 21.2 Very Long Inputs

- Title hitting max-length: hard stop at limit; counter visible.
- Body approaching max: counter visible from 80% of limit.
- Pasted content exceeding limit: truncate with notice ("Pasted content was truncated to fit the limit").

### 21.3 Special Characters

- Emojis in content: supported; rendered as Unicode.
- Names with diacritics or non-Latin scripts: supported.
- HTML/JS in content: sanitized server-side; rendered as text.

### 21.4 Time Zones

- All timestamps stored UTC; displayed in user's local time.
- "Today," "Yesterday" calculated against user's local midnight.
- Calendar dates (academic semester boundaries) are India-time-anchored regardless of user location.

### 21.5 Race Conditions

- Two browser tabs of same user, both posting questions simultaneously: both succeed independently.
- User accepts an answer, another user upvotes the same answer at the same time: both succeed.
- User deletes a question while someone is reading it: reader's screen shows "This question was removed" on next refetch.

### 21.6 Stale Sessions

- Cookie expired but tab is open: next request returns 401; UI redirects to login with `?next=`.
- Password changed in another tab: existing tab gets 401 next request; redirects to login.
- Session manually revoked by admin: same.

---

## 22. Success States

When something works, acknowledge briefly. Don't over-celebrate.

| Action | Acknowledgement |
|---|---|
| Vote cast | Visual tick on icon + count bumps |
| Bookmark added | Icon fills + brief toast |
| Question posted | Redirect + toast |
| Connection accepted | Toast + "Message" button now visible |
| Badge earned | In-app notification (not blocking modal) |
| Answer accepted (by asker) | Visual mark on accepted answer + toast |
| Faculty endorsement | Endorsement chip appears on answer |
| Profile saved | Toast |

We avoid:
- Confetti
- Modal "Yay!" celebrations
- Sound effects
- Streaks, points-multipliers, achievement-unlocked overlays

---

## 23. The Forgotten States Checklist

Before considering any feature done, walk this list:

- [ ] First-time empty state
- [ ] Filtered empty state
- [ ] Loading skeleton
- [ ] Loading more (if paginated)
- [ ] Network error
- [ ] Server error
- [ ] Permission denied
- [ ] Stale data
- [ ] Offline
- [ ] Validation errors (each rule)
- [ ] Rate limit hit
- [ ] Successful action acknowledgement
- [ ] Optimistic update (if applicable) and revert path
- [ ] Race condition (two clients, same target)
- [ ] Mobile rendering at 320px width
- [ ] Keyboard-only navigation
- [ ] Screen reader announcement on state change
- [ ] Reduced-motion behavior

---

## 24. Documentation Practice

When a new feature is designed:

1. Designer documents the populated state (the happy path).
2. Designer + engineer enumerate the variants from this catalog that apply.
3. Each variant gets a design treatment (or note of "uses default empty state component").
4. Engineer implements all variants — tests cover each.
5. QA verifies each variant before sign-off.

This catalog is the prompt that ensures we don't ship a feature with only the happy path designed.
