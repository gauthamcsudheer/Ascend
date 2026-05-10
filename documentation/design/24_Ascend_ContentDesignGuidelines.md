# Ascend — Content Design Guidelines

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, frontend engineers, content writers, anyone writing user-facing copy |
| Purpose | The microcopy layer. Extends the Brand Voice Guidelines (doc 06) into specific UI patterns. |

> Brand voice tells you *how to sound*. Content design tells you *what to write* in specific UI moments — buttons, errors, empty states, notifications, onboarding. This document gives concrete patterns and examples so the same situations get treated consistently.

---

## 1. Voice Recap

From the Brand Voice Guidelines, Ascend's voice is:

- **Quietly confident** — we know our craft, we don't perform it
- **Warm but not chummy** — friendly without forced familiarity
- **Direct** — say the thing; respect the reader's time
- **Respectful of intelligence** — explain when needed, never patronize

Apply that lens to every piece of copy below. When in doubt, read it aloud and ask: would a thoughtful, busy professor write this to a student?

---

## 2. Buttons

### 2.1 Principles

- **Verb-led.** Buttons describe what happens when clicked. "Post Question" not "OK." "Send Request" not "Submit."
- **Specific.** "Save Profile" beats "Save." "Delete Account" beats "Delete."
- **Sentence case.** Title Case Looks Bossy. Sentence case reads natural.
- **Same action, same words.** Don't say "Submit" on one form and "Send" on another for the same operation.
- **Short.** Most buttons fit in 1-3 words. "Sign in," "Post," "Verify alumnus."

### 2.2 The Vocabulary

**Approved primary verbs:**

| Verb | Use for |
|---|---|
| Sign in / Sign out | Auth |
| Sign up / Create account | New user registration |
| Post | Publishing a question, post, comment |
| Send | Outgoing message or request |
| Save | Persisting changes |
| Submit | Forms with explicit completion (verification request, report) |
| Apply | Filters, settings that take effect |
| Delete | Permanent removal |
| Remove | Reversible separation (remove from bookmarks, remove tag) |
| Verify | Admin action approving |
| Reject | Admin action denying |
| Endorse | Faculty action |
| Accept / Decline | Connection requests, answers |
| Connect | Initiate a connection |
| Disconnect | End a connection |
| Block / Unblock | Moderation by user |
| Follow / Unfollow | Tag, person |
| Bookmark / Remove bookmark | Save for later |
| Continue | Move to next step in a flow |
| Cancel | Abandon current operation |
| Close | Dismiss a modal/panel |
| Try again | Retry after failure |

**Verbs to avoid:**

- "OK" — what does it do? Be specific.
- "Click here" — never. The button itself is the link.
- "Go" — vague.
- "Confirm" — confirm what? Use the actual verb ("Delete account," "Post answer").
- "Done" — fine in narrow cases (closing a confirmation), but most actions have a more specific verb.

### 2.3 Button Pairs

When buttons appear together, the pair guides the user:

| Primary | Secondary |
|---|---|
| Post question | Save as draft |
| Send request | Cancel |
| Delete account | Keep account |
| Apply filters | Clear |
| Continue | Back |

Right-aligned on desktop, with the secondary action to the left of the primary. On mobile, primary action takes full width; secondary appears above it as a text button.

### 2.4 Destructive Actions

- Use the destructive style only for genuinely destructive actions.
- Be specific: "Delete this answer," not "Delete."
- Pair with a clear cancel: "Keep" or "Cancel."
- For irreversible actions, the modal text says exactly what will happen. The button confirms with the verb.

---

## 3. Form Labels and Helper Text

### 3.1 Labels

- One word or short phrase. Sentence case.
- No colons.
- Required fields marked with `*` after the label, color `text-error`.
- Optional fields marked with "(optional)" in muted text.

| Good | Bad |
|---|---|
| Email | EMAIL: |
| Current company | Where do you currently work? |
| LinkedIn URL (optional) | LinkedIn (Not Required) |
| Branch | Department/Branch |

### 3.2 Helper Text

Helper text supports the field. It's always visible (not hover-only). Keep it brief.

| Field | Good helper |
|---|---|
| Email (signup, student) | We'll send a verification link to this address. |
| Email (signup, faculty) | Use your `@rajagiritech.edu.in` email to auto-verify. |
| Password | At least 8 characters with letters and numbers. |
| LinkedIn URL | Helps our team verify your alumni status. |
| Anonymous toggle | Your name won't be shown to others. Admins still see you for moderation. |
| Tags | Add 1–5 tags. Helps others find your question. |
| Bio | Up to 280 characters. Skip the resume; focus on what you can help with. |

Avoid:
- "This field is required." (Don't repeat what the asterisk says.)
- "Please enter a valid email." (As helper. As error message it's fine, but not as proactive helper.)

### 3.3 Placeholders

Placeholders show *example* content, never the label.

| Good | Bad |
|---|---|
| Label: Email / Placeholder: alice@rajagiri.edu.in | Label: empty / Placeholder: Email |
| Label: LinkedIn URL / Placeholder: linkedin.com/in/your-name | Label: empty / Placeholder: LinkedIn URL |

Placeholders are gray (`text-tertiary`) and disappear when the user types. They're never the only place a label exists.

---

## 4. Error Messages

Per Design Principle 5: honesty in failure. Every error answers two questions: **what happened** and **what can the user do now**.

### 4.1 Field-Level Errors

| Situation | Message |
|---|---|
| Email blank | Email is required. |
| Email format | Please use a valid email address. |
| Email wrong domain (student signup) | Students sign up with a `@rajagiri.edu.in` email. Use the alumni form if you've graduated. |
| Email already registered | An account already uses this email. [Sign in instead] |
| Password too short | Use at least 8 characters. |
| Password too weak | Add a number and a letter. |
| URL not LinkedIn | This needs to be a LinkedIn profile URL. |
| Tag limit reached | Up to 5 tags. Remove one to add another. |
| Title too long | Titles fit in 120 characters. Try shortening. |

### 4.2 Form-Level Errors

After submit attempt:

| Situation | Message |
|---|---|
| Validation errors | Please fix the highlighted fields. |
| Server error | Something on our end isn't working. Try again in a moment. |
| Network error | We couldn't reach the server. Check your connection and try again. |
| Rate limited | You've reached the limit for this hour. You can try again at 4:30 PM. |
| Permission denied | This action isn't available right now. |

### 4.3 Page-Level Errors

| Situation | Message |
|---|---|
| 404 | We couldn't find that. Maybe it was removed, or the link is wrong. [Go to home] |
| 403 | You don't have access to this. [Go to home] |
| 500 | Something on our end isn't working. We've been notified. [Try again] |
| Offline | You're offline. Some things may not work until you're connected. |
| Maintenance | Ascend is updating. We'll be back shortly. |

### 4.4 What Errors Don't Do

- **Don't blame the user.** "Invalid email" not "You entered an invalid email."
- **Don't apologize repeatedly.** One acknowledgement is enough; "Sorry, we're sorry, apologies" reads insincere.
- **Don't reveal internals.** "Database connection refused" is not honesty; it's noise.
- **Don't be cute.** "Oopsie! 🙈" violates brand voice.
- **Don't dead-end.** Every error message offers a next step (retry, go elsewhere, contact help).

---

## 5. Empty States

Per Interaction Patterns § 9, empty states have variants. Each has its own copy pattern.

### 5.1 First-Time Empty (User Has Never Had Content)

**Tone:** orienting, helpful, calm.

| Surface | Heading | Body | Action |
|---|---|---|---|
| Home feed | Your feed is quiet right now. | Follow some tags or people to see content here. | Browse tags |
| Notifications | All caught up. | New activity will appear here. | — |
| Bookmarks | Nothing saved yet. | Bookmark questions, posts, or resources to find them later. | — |
| My questions | You haven't asked anything yet. | Got a question? Someone here probably has the answer. | Ask a question |
| My answers | You haven't answered anything yet. | When you're ready, your answers will appear here. | Browse questions |
| Connections | No connections yet. | Find people whose expertise interests you, and reach out. | Browse people |
| Messages | No messages yet. | Connect with members from their profiles to start a conversation. | — |

### 5.2 Filtered Empty (User Filtered to Nothing)

**Tone:** matter-of-fact, helpful nudge.

| Surface | Message |
|---|---|
| Filtered question list | No questions match these filters. [Clear filters] |
| Filtered search | No results for "[query]". Try different keywords or remove a filter. |
| Filtered people | No one matches. Try different filters. |

### 5.3 Cleared Empty (User Removed All)

**Tone:** acknowledge without judgment.

| Surface | Message |
|---|---|
| Bookmarks (after clearing) | No bookmarks. |
| Notifications (after clearing) | All clear. |

### 5.4 Quiet Empty (Could Have Content; Currently None)

**Tone:** understated.

| Surface | Message |
|---|---|
| Home (user follows things, but no recent activity) | Nothing new from your follows. [Browse all] |
| Notifications (caught up) | All caught up. |
| Unanswered questions in dept | All questions in your department have answers right now. |

---

## 6. Loading and Progress

Most loading states don't need words — skeletons or spinners are clear. When words are needed:

| Situation | Copy |
|---|---|
| Initial page load (rare; usually skeleton) | Loading… |
| Submit in progress | (Button shows spinner; text becomes "Posting…", "Sending…", "Saving…") |
| Long operation, indeterminate | This may take a moment. |
| Long operation with progress | Processing… 3 of 10 steps. |
| Background operation completed | Your data export is ready. [Download] |

---

## 7. Confirmations

### 7.1 Toast Confirmations

Brief, action-acknowledging.

| Action | Toast |
|---|---|
| Question posted | Question posted. |
| Answer posted | Answer posted. |
| Comment added | Comment added. |
| Vote cast | (no toast — instant visual feedback is enough) |
| Bookmark added | Bookmarked. |
| Bookmark removed | Removed from bookmarks. [Undo] |
| Followed | Following [tag/person]. |
| Connection sent | Request sent to [name]. |
| Connection accepted | Connected with [name]. |
| Connection declined | Declined. |
| Profile saved | Profile updated. |
| Settings saved | Saved. |
| Report submitted | Thanks. We'll review this. |
| Account deleted (initiated) | Account scheduled for deletion. You have 14 days to undo. |

### 7.2 Modal Confirmations (Destructive)

Format: heading (the action) + body (what happens) + buttons (verb + cancel).

**Delete account:**
- Heading: Delete your account?
- Body: Your content can be anonymized or fully removed. You'll have 14 days to change your mind. After that, this can't be undone.
- Buttons: Continue / Cancel

**Block user:**
- Heading: Block [name]?
- Body: They won't be able to see your content, message you, or send a connection request. You won't see theirs either. You can unblock anytime.
- Buttons: Block / Cancel

**Disconnect:**
- Heading: End your connection with [name]?
- Body: This will close your DM thread. They'll see "[name] disconnected." You can reconnect later if both agree.
- Buttons: Disconnect / Keep connection

**Admin: Suspend user (24h):**
- Heading: Suspend [name] for 24 hours?
- Body: They'll be able to read but not post, comment, vote, or message during this period. They'll see why.
- Reason field (required).
- Buttons: Suspend / Cancel

---

## 8. Notifications (In-App and Email)

### 8.1 Notification Strings

Format: actor + action + object (when relevant) + (timestamp comes separately from the data).

| Type | Copy |
|---|---|
| Answer received | [Name] answered your question. |
| Anonymous answer received | Someone answered your question. |
| Comment on your question | [Name] commented on your question. |
| Comment on your answer | [Name] commented on your answer. |
| Answer accepted | [Name] accepted your answer. |
| Answer endorsed (faculty) | [Faculty name] endorsed your answer. |
| New follower | [Name] is now following you. |
| Followed user posted | [Name] posted: "[truncated title]". |
| Badge earned | You earned the [badge name] badge. |
| Connection request | [Name] wants to connect: "[topic]". |
| Connection accepted | [Name] accepted your connection request. |
| Connection declined (visible) | [Name] declined: "[reason if given]". |
| Connection expired | Your connection request to [name] expired. |
| New DM | [Name] sent you a message. |
| Mention | [Name] mentioned you in a [question/answer/post/comment]. |
| Department announcement | [Faculty name]: [announcement title]. |
| Report outcome | We reviewed your report and took action. |
| Content removed (yours) | We removed your [content type] for [reason]. |
| Verification approved | Your alumnus account is verified. Welcome. |
| Verification rejected | Your alumnus verification needs more info. |
| Resource promoted | [Resource title] is now in the Library. |
| Digest (email subject line) | This week on Ascend |

### 8.2 Email Subject Lines

Match the in-app notification when meaningful; standalone subject lines for emails:

- Verification email: Verify your Ascend account
- Password reset: Reset your Ascend password
- Account suspended: Your Ascend account is suspended
- Data export ready: Your Ascend data export is ready

### 8.3 Email Body Patterns

- Open with the recipient's first name only.
- Mirror the in-app notification text.
- Include a clear primary CTA button to the relevant content.
- Include unsubscribe link (digests only) and notification preferences link.
- Sign off as "The Ascend team" — never with a fake person name.

---

## 9. Onboarding Copy

### 9.1 First-Time Tour Screens

**Welcome:**
- Heading: Welcome to Ascend.
- Body: This is where the RSET community asks, answers, and stays connected. A quick tour?
- Buttons: Skip / Continue

**What you can do (varies by persona):**

Student:
- Heading: Ask, learn, connect.
- Body: Get answers from seniors and faculty. Read what others are working on. Connect with alumni in the fields you're curious about.

Faculty:
- Heading: Stay close to students.
- Body: See what students are asking. Endorse the best answers. Share announcements with the right audiences.

Alumnus:
- Heading: Stay connected without the noise.
- Body: Help students with questions only you can answer. Share your journey. Build the network you wished you had.

**Notifications setup:**
- Heading: Stay informed without being interrupted.
- Body: Pick what you'd like to hear about. You can change this anytime in settings.
- (Default settings shown; user can adjust)

### 9.2 Empty State Onboarding

When a new user lands somewhere with no content (already covered in § 5.1), the copy is brief and points them somewhere useful.

---

## 10. Verification & Status Messages

### 10.1 Pending Verification Page

- Heading: Hang tight, [first name].
- Body: Your alumnus account is being verified. We typically respond within 3 days. While you wait, you can browse Ascend and ask questions. Answering and connecting unlock once you're verified.
- Actions: Browse Q&A / Edit profile / Sign out

### 10.2 Verification Approved (Email + In-App)

- Heading: You're verified. Welcome.
- Body: You can now answer questions, send connection requests, and use direct messages. Your Class of [year] badge is on your profile.

### 10.3 Verification Needs More Info

- Heading: We need a bit more to verify your account.
- Body: [Specific reason from admin]. Please update your profile with this info, and we'll review again.

### 10.4 Account Suspended

- Heading: Your account is suspended.
- Body: Until [date]. Reason: [admin reason]. You can read content but can't post, comment, vote, or message. If you think this is a mistake, [contact support].

### 10.5 Account Banned

- Heading: Your account has been disabled.
- Body: Reason: [admin reason]. If you believe this is a mistake, [contact support].

---

## 11. Microcopy Patterns

### 11.1 Counts and Quantities

- Use numerals: "12 answers," not "twelve answers."
- Pluralize correctly: "1 answer," "2 answers," "0 answers" (not "no answers" in counts).
- For "0," prefer the plural form when it's a count display: "0 answers." Use prose for empty states.

### 11.2 Time

- Recent: "Just now" (< 1 min), "5 min ago," "2 hr ago," "Yesterday," "3 days ago," "Mar 14," "Mar 14, 2025" (if not current year).
- Tooltip on hover shows full timestamp: "March 14, 2026 at 4:32 PM IST."
- Use "ago" form for activity timestamps; full dates for events.

### 11.3 Names and Identity

- Use first names where appropriate (notifications, greetings).
- Use full names where formality matters (admin lists, audit logs, profile headers).
- "Anonymous Student" / "Anonymous Faculty" / "Anonymous Alumnus" — capitalize "Anonymous" but lowercase the descriptor in some contexts; keep the full form together.

### 11.4 Numbers in Titles

When showing counts in headings: "12 Answers," "3 Pending Verifications" — title case for the noun, numeral first.

---

## 12. Tone in Difficult Moments

### 12.1 Account Issues

When telling someone something they don't want to hear (verification rejected, content removed, account suspended):

- Be direct. Avoid soft-pedaling that creates ambiguity.
- Be specific. "Reason: Off-topic content per community guidelines" not "Reason: Violations."
- Offer a path forward where there is one.
- Don't apologize for enforcing policy. Do explain reasoning.

### 12.2 Failure States

When something we built breaks:

- Acknowledge briefly. "Something on our end isn't working."
- Don't over-apologize.
- State what's being done. "We've been notified."
- Offer the user something to do. "Try again."

### 12.3 Sensitive Content

When users encounter difficult content (a question about academic stress, a post about career rejection):

- We don't add platform commentary or "we're here for you" messages on individual posts.
- We do provide a help link in account settings that includes mental health resources.
- We take reports of self-harm or distress seriously per the Admin Ops Playbook.

---

## 13. Anti-Patterns

Avoid these patterns regardless of context:

- **Cute or jokey error messages.** "Oops!" "Yikes!" "Houston, we have a problem!" — none of these. We are calm even when things break.
- **Excessive exclamation points.** A single, considered exclamation is acceptable for genuine celebration ("You earned the Mentor badge!"). Three exclamation points means the writer was anxious. Cut.
- **Marketing speak.** "Discover," "unlock," "amazing community," "best-in-class." None.
- **Forced enthusiasm.** "Welcome aboard!!! 🚀" violates voice on multiple counts.
- **Filler.** "Please be advised that..." → "..." . "We would like to inform you..." → "..." . "It's important to note..." → "..." .
- **Imperative bossiness without context.** "Click here." "Do this now." Bad on its own; worse without explanation.
- **Faux humility.** "We humbly request your feedback." We don't humbly request anything. We ask, when it makes sense to ask.
- **AI-generated voice.** Avoid the "I would be happy to" / "It's important to remember" cadence that betrays a generic LLM. Voice is human.

---

## 14. Localization Notes

We launch in English. Future Malayalam (or Hindi) localization considerations:

- All user-facing strings in a translation file (no string concatenation).
- Avoid English-isms ("at the end of the day," "back to square one") that don't translate.
- Date and number formatting via locale-aware libraries.
- Allow for text expansion — Indian languages can be 30-50% longer than English. Buttons and labels need to flex.
- RTL not relevant for our likely target languages, but logical CSS properties used anyway.

---

## 15. Voice Calibration: Side-by-Sides

Examples to internalize the voice. Each row is the same situation written wrong, then right.

| Wrong | Right |
|---|---|
| Oops! Something went wrong 😅 | Something on our end isn't working. Try again in a moment. |
| Welcome to the Ascend family! 🎉 | Welcome to Ascend. |
| Awesome! Your question has been posted! | Question posted. |
| You're awesome! 5 day streak! | (we don't do streaks) |
| Sorry, we couldn't find that 😞 | We couldn't find that. Maybe it was removed. |
| You're not allowed to do this. | You don't have access to this action. |
| Please be advised that the system is currently undergoing maintenance. | Ascend is updating. We'll be back shortly. |
| Click here to verify | (button text:) Verify email |
| Hi there! 👋 What's your question? | (placeholder:) What would you like to ask? |
| You rock! Thanks for posting! | Posted. |
| Hey, looks like you've been gone for a while! | (we don't say this) |
| Are you sure you really want to delete this question? This action is irreversible and cannot be undone. | Delete this question? Its answers and comments go too. |

---

## 16. Process

### 16.1 Who Writes Copy

- Designers draft.
- Engineers can write functional copy in code.
- Anyone with a sharp eye can revise.
- Final copy lands in a centralized strings file.

### 16.2 Review

- Copy reviewed alongside design (not after).
- Read aloud test: does this sound like the voice?
- Check against this document for patterns.
- Test in context — copy that reads fine in Figma can fall apart in a real layout.

### 16.3 Maintenance

- This document evolves with the product.
- New patterns get added when they emerge twice (once is a one-off; twice is a pattern).
- Existing patterns get revised when they prove wrong in usage.
