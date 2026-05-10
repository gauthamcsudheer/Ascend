# Ascend — Interaction Patterns

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers |
| Purpose | The behavioral patterns shared across the product. How things move, when feedback appears, what happens on errors. |

---

## 1. Loading Patterns

Loading is a UX problem. We use different patterns for different waiting situations.

### 1.1 Skeleton Loaders
Used when the *shape* of the eventual content is known and predictable. Match the actual content layout closely so the transition into real content is barely perceptible.

**Use for:** feed cards, profile pages, list views, comments, message threads.

**Don't use for:** fast loads (< 300ms — flash of skeleton is worse than nothing), unknown-shape content (search results before query, forms).

**Behavior:** appear immediately on navigation; replace with content when ready; subtle pulse animation respects `prefers-reduced-motion`.

### 1.2 Spinners
Used for short, indeterminate waits inside other UI.

**Use for:** button loading states, in-line refresh indicators, "Loading more…" at end of infinite scroll, modal-loading.

**Don't use for:** initial page loads (skeleton is better) or loads exceeding ~3s (escalate to progress or status message).

### 1.3 Progress Bars
Used for determinate operations.

**Use for:** file processing (data export), multi-step flows showing position.

### 1.4 Optimistic Updates
For actions that rarely fail and where instant feedback matters: votes, follow/unfollow, bookmark, comment-post.

**Pattern:**
1. Update UI immediately as if the action succeeded.
2. Send the request.
3. If server rejects, revert with brief inline message ("Couldn't save — try again").
4. If network fails, queue for retry; show subtle "Pending" state.

**Don't use optimistic updates for:** destructive actions (delete content, send message), state changes other users will see immediately and need to be synchronized.

### 1.5 Stale-While-Revalidate
For data we have cached: show cached version immediately, fetch fresh in background, swap when ready.

**Use for:** feed on tab return, profile pages on revisit.

**Indicator:** subtle "Updated" toast or no indicator if change is invisible.

### 1.6 Long-Running Background
For operations exceeding 5 seconds:
- Show progress where possible
- Allow user to navigate away (operation continues server-side)
- Notify on completion via toast or notification

**Examples:** Data export (notify on email when ready), batch admin actions.

---

## 2. Form Interaction

### 2.1 When to Validate

- **On blur:** field-level format validation (email format, URL format, length).
- **On submit:** form-level validation; server-side validation feedback.
- **NOT on every keystroke** for most fields. Exceptions: password strength meter (visual feedback while typing), character counters within 20% of cap.

### 2.2 Error Surfacing

- **Inline below field:** primary error display.
- **Field outline turns error-red:** secondary signal.
- **Form-level error summary:** only at the top if multiple fields invalid AND form is long; clicking a summary item scrolls to and focuses the offending field.

### 2.3 Recovery After Error

- After server error on submit: form retains all entered data; helpful error message at top; submit button re-enabled.
- Drafts of long-form content (questions, posts, answers) auto-save to localStorage during typing; survive page reload.

### 2.4 Field Helpers

- **Help text** appears below the field, always visible (not on hover) for fields where users need persistent guidance.
- **Tooltip on label** for explanations that don't always need to be visible.
- **Examples within placeholders** are fine but don't substitute for labels.

### 2.5 Disabled vs Hidden

- **Disabled** when an action is currently impossible but the user should know it exists (e.g., "Submit" before form valid).
- **Hidden** when the action is irrelevant to the user's role or state (e.g., admin actions for non-admins).

### 2.6 Submit Behavior

- Submit button shows loading state on click.
- Pressing Enter in any single-line input submits the form (where appropriate).
- Multi-line textareas don't submit on Enter; they require explicit click or Cmd/Ctrl+Enter.
- After successful submit: navigate to result, show confirmation toast, or both.

---

## 3. Confirmation Patterns

Per Design Principle 4 (Reversibility by Default), we minimize confirmations.

### 3.1 No Confirmation
Routine actions where the user can undo:
- Vote (toggle off retracts)
- Bookmark (toggle off removes)
- Follow / unfollow
- Comment (can edit/delete after)
- Question / answer / post submission (can edit; for some, delete)

### 3.2 Inline Confirmation with Undo
Actions that affect others or are slightly more impactful:
- Removing a bookmark of someone's content (toast: "Removed. Undo")
- Marking notification as read (no confirmation; "Mark unread" available in menu)

### 3.3 Modal Confirmation
Genuinely irreversible or high-stakes:
- Delete account (multi-step modal with type-to-confirm)
- Block a user (modal explaining what blocking means + Confirm/Cancel)
- Disconnect from a connection (modal: "This will end your DM thread access. Continue?")
- Admin actions: ban user, hard-delete content (modal with reason field)

### 3.4 Type-to-Confirm
For the most destructive actions (account deletion):
- Modal asks user to type a specific phrase ("DELETE") to enable Confirm button.
- Confirmation reduces accidental destruction.

### 3.5 Confirmation Copy

- Use plain language. "Delete this question?" not "Are you sure you want to delete this question?"
- State what happens. "This will remove the question and all its answers permanently."
- Affirmative button matches verb. ("Delete" not "OK".)
- Cancel uses neutral verb. ("Cancel" or "Keep")

---

## 4. Real-Time Updates

When new data arrives via WebSocket while user is on a page:

### 4.1 Notifications
- Bell icon increments badge count.
- New notification slides in if notifications panel is open.
- Optional system push notification (per user pref, when app backgrounded).

### 4.2 Direct Messages
- If thread is open: new message slides in with subtle animation.
- If thread is not open: thread list updates (preview + timestamp + unread indicator), bell increments.
- If user is the sender (sent from another tab): updates without sound.

### 4.3 Vote / Comment / Answer on Open Question
- Vote count increments smoothly (number bump animation).
- New comments appear at end of comment list.
- New answers do NOT auto-insert into the rendered list (avoids jumping content). Instead, a banner appears: "[N new answer(s)]" — clicking refreshes the list.

### 4.4 Live Indicators
- "Other party typing" indicator in DM threads (appears 1s after typing detected, disappears 5s after typing stops).
- Online/presence indicators: NOT in v1. Privacy-sensitive; defer.

### 4.5 Sync on Reconnection
After network drop: silently re-sync content; if content has materially changed, show "Updated" indicator.

---

## 5. Transitions Between Views

### 5.1 List → Detail
- Tap card → fade transition (mobile) or instant nav (desktop).
- Subtle slide-from-right animation on mobile (200ms).
- Detail page receives focus on the heading for screen readers.

### 5.2 Modal Open / Close
- Backdrop fades in (150ms ease-out).
- Modal scales from 0.96 to 1.0 + fades in (200ms ease-out).
- Focus traps to first focusable element.
- Close: reverse, 150ms ease-in.

### 5.3 Drawer Slide
- 250ms ease-out from edge.
- Backdrop fade synced.

### 5.4 Tab Switch
- Content swap is instant (no slide animation).
- Active indicator slides between tabs (150ms ease-standard).

### 5.5 Page Navigation (Top-Level)
- Fade transition between top-level routes (Home → Q&A) at 150ms.
- No transition between pages within the same section (Q&A list → Q&A detail) on desktop; subtle slide on mobile.

### 5.6 Reduced Motion
When `prefers-reduced-motion: reduce`, all of the above become near-instant (50ms instead of 200-250ms). No springs. No bumps.

---

## 6. Keyboard Navigation

### 6.1 Universal Shortcuts

| Key | Action |
|---|---|
| `Escape` | Close modal, drawer, popover, dropdown |
| `Tab` / `Shift+Tab` | Move focus forward/backward |
| `Enter` | Activate focused button or link |
| `Space` | Toggle focused checkbox/switch; activate button |
| `/` | Focus search bar |
| `?` | Show keyboard shortcuts overlay |

### 6.2 In-Page Shortcuts (Power Users)

| Key | Action | Context |
|---|---|---|
| `j` / `k` | Next/previous item in feed | Feed views |
| `g` then `h` | Go home | Anywhere |
| `g` then `q` | Go to questions | Anywhere |
| `g` then `n` | Go to notifications | Anywhere |
| `c` | Compose (ask question, write post — context-dependent) | Anywhere |
| `b` | Bookmark current item | On detail page |
| `u` | Upvote current item | On detail page |

These are documented in a shortcuts overlay (`?`) but never required.

### 6.3 Composer Shortcuts

| Key | Action |
|---|---|
| `Cmd/Ctrl + Enter` | Submit |
| `Cmd/Ctrl + B` | Bold |
| `Cmd/Ctrl + I` | Italic |
| `Cmd/Ctrl + K` | Insert link |

### 6.4 Focus Management

- Focus visible (3px ring) on all interactive elements when keyboard-navigating.
- After modal closes, focus returns to the element that opened it.
- After form submit and navigation, focus moves to the page heading.
- Skip-to-content link at top of every page (visible on focus).

---

## 7. Touch Gestures

### 7.1 Standard Gestures

| Gesture | Action |
|---|---|
| Tap | Click equivalent |
| Long press | Context menu (e.g., on notification: mark unread; on message: react/copy) |
| Swipe down (top of page) | Pull-to-refresh |
| Swipe horizontal (DM threads) | NOT used in v1; reserve for archive in future |
| Pinch | Browser default (zoom); not overridden |

### 7.2 Touch Target Sizes
- Minimum 44x44 px (per WCAG 2.5.5).
- Icon-only buttons get padding to reach this; the icon itself can be smaller.
- Stacked tap targets need at least 8px between them to prevent mis-tap.

### 7.3 Avoiding Common Touch Issues
- No hover-only affordances. Anything available on hover (desktop) is also available on tap (mobile).
- No tooltips required for understanding. Tooltips supplement, never replace.
- Tap delay removed via `touch-action: manipulation` CSS.

---

## 8. Notifications & Toasts

### 8.1 Toast Types

| Type | When | Duration |
|---|---|---|
| Success | Action completed | 4s |
| Info | Neutral info | 4s |
| Warning | Soft caution | 6s |
| Error | Action failed | 8s, dismissable |
| Persistent | Critical, requires user action | until dismissed |

### 8.2 Toast Position

- **Mobile:** bottom-center (above bottom nav), slide up from edge.
- **Desktop:** top-right, slide from right.

### 8.3 Toast Stacking

- Maximum 3 visible.
- Beyond 3: queue; new toasts appear as old ones dismiss.
- Same-type rapid-fire toasts (e.g., "Voted") are debounced — show one with summary count.

### 8.4 Toast Content

- Brief: 1-2 sentences max.
- Action where appropriate (Undo, Retry).
- Never include critical information that would be lost on dismiss.

---

## 9. Empty State Patterns

When a list, search, or page has no content:

### 9.1 First-Time Empty
User has never had content here. Show illustration + heading + description + primary CTA (e.g., "Follow tags").

### 9.2 Filtered Empty
User filtered down to nothing. Show "No results match your filters." + "Clear filters" or "Adjust filters" actions.

### 9.3 Cleared Empty
User cleared their content (e.g., deleted bookmarks). Acknowledge the cleared state without judgment.

### 9.4 Quiet Empty
The list could have content but is currently quiet (no new notifications, no recent activity). Use understated copy ("All caught up.", "Nothing new.")

(Detailed copy and visual treatment in State Catalog doc.)

---

## 10. Error Recovery

### 10.1 Network Errors
- Caught at fetch layer.
- Show inline retry where the affected action lives, not as a global error.
- For navigation errors: full-page error state with retry.

### 10.2 Validation Errors
- Inline at field; never modal.
- Form retains entered data.
- Focus moves to first invalid field on submit attempt.

### 10.3 Server Errors (500)
- Generic-but-honest message: "Something on our end isn't working. We've been notified. Try again in a moment."
- Sentry captures details automatically; user doesn't see them.
- Retry option for idempotent actions.

### 10.4 Permission Errors (403)
- "You don't have access to this." with brief reason if knowable.
- Suggest alternative if available.
- Don't reveal the existence of resources the user doesn't have access to (no "exists but you can't see it" hints).

### 10.5 Not Found (404)
- "We couldn't find that." with suggestion ("Maybe it was removed. [Browse questions]")
- Don't blame user.

### 10.6 Rate Limited (429)
- "You've hit a limit. You can try again in [time]."
- Show what limit and when it resets.
- Sometimes appropriate to allow Cancel & explain instead of just blocking.

---

## 11. Permissions Prompts

For browser permissions (notifications, etc.):

### 11.1 Don't Ask Cold
Never trigger the browser's native prompt without first explaining why we want the permission via a custom UI.

### 11.2 The Two-Step Flow
1. Custom prompt: "Get notified about new answers and connection requests? (You can change this anytime in settings.)" with Yes/No.
2. Only on Yes: trigger browser native prompt.

### 11.3 Honor Denial
If user denies, don't re-prompt for at least 30 days (and only on a meaningful trigger, e.g., a new feature). Never on every visit.

---

## 12. Undo Patterns

Where used (per § 3 above), undo follows this pattern:

- After action, toast appears with action description + "Undo" button.
- Undo available for 5 seconds (visible in toast lifetime).
- Clicking Undo reverts the action and shows brief acknowledgement.

**Server-side handling:**
- For purely client-side state: revert instantly.
- For server actions: send reversal API call; on success, show "Restored."
- Some actions can't truly be undone (notifications already delivered, etc.); design copy carefully.

---

## 13. Multi-Step Flows

For flows with multiple steps (signup, onboarding, account deletion):

### 13.1 Indicator
Step indicator at top: "Step 2 of 4" or progress bar.

### 13.2 Navigation
Back button to previous step. Cancel option clearly visible (returns to previous page or context).

### 13.3 State Preservation
If user navigates away and returns within session, restore progress. Beyond session, prompt to resume or restart.

### 13.4 Final Confirmation
For destructive flows, last step is a summary of what's about to happen + final confirm.

---

## 14. Search Interaction

### 14.1 Typeahead
- Debounced 200ms after last keystroke.
- Min 2 chars.
- Loading indicator inside input.
- Suggestions grouped by type.
- Keyboard-navigable (arrow keys, Enter).

### 14.2 Search History
- Recent searches stored in localStorage (max 10).
- Shown in typeahead when input is empty.
- "Clear" link to wipe.

### 14.3 No Results
- Suggest: "Try fewer keywords" / "Check spelling" / "Remove filters."
- Offer to search related terms if we have synonyms.

---

## 15. Patterns to Avoid

These are common in other products but contradict Ascend's principles:

- **Modal interrupting onboarding mid-task** ("Take our survey!"). Never.
- **"You've been here for X minutes — take a break" prompts.** Patronizing.
- **Achievement pop-ups when user earns badges** that block interaction. Use a discreet toast and the badge appears on profile.
- **Skeuomorphic confirmations** (e.g., red flashing). Calm UI even when something fails.
- **Auto-playing video or motion** anywhere.
- **Carousels on landing pages.** None.
- **Dark patterns:** No "Are you sure you want to skip our amazing offer?" double-confirms. No pre-checked unrelated checkboxes. No hidden pricing. No artificial scarcity.

---

## 16. Patterns to Test

These are decisions we'll validate during design phase:

- Pull-to-refresh on home: useful or confusing?
- Long-press for context menus on mobile: discoverable?
- "g + key" shortcut sequences: too obscure for institutional users?
- Optimistic updates on votes: is the rare revert experience confusing?
- Notification badge as "earned attention" vs "noise": calibrate threshold via user feedback.
