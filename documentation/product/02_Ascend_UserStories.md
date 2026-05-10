# Ascend — User Stories & Acceptance Criteria

**Companion to PRD v1.0**

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Format | INVEST stories with Given/When/Then ACs |

---

## How to Read This Document

Stories are grouped by Epic, numbered `US-<epic>.<story>`. Each story:
- Names the persona, action, and benefit
- Links back to PRD functional requirement IDs (e.g., F2.5)
- Specifies acceptance criteria in Given/When/Then form
- Lists dependencies on other stories where applicable

**Definition of Ready:** A story is ready for sprint planning when ACs are unambiguous, dependencies are noted, and any UX mocks are linked.

**Definition of Done:** Code merged with tests passing, ACs verified by QA, accessibility check passed, audit log instrumented, telemetry instrumented for KPI tracking.

---

## Epic 1: Identity, Verification & Onboarding

### US-1.1: Tabbed Registration Page
*As any prospective user, I want to clearly identify my persona at registration so I see only the relevant fields.* (F1.1)

**Acceptance Criteria:**
- **Given** I land on the registration page, **then** I see three tabs: Student, Faculty, Alumni
- **Given** I select a tab, **then** the form shows only fields relevant to that persona
- **Given** I switch tabs, **then** previously entered data on the prior tab is preserved (until form submission or page leave)
- **Given** I submit, **then** validation errors are clearly shown in-context with each field

### US-1.2: Student Sign-Up
*As a current RSET student, I want to sign up using my institutional email so I can access the platform without manual approval.* (F1.2)

**AC:**
- **Given** I have an email ending in `@rajagiri.edu.in`, **when** I submit, **then** my account is created and auto-tagged "Student"
- **Given** I'm signing up as a student, **then** required fields are: name, branch, current semester, batch year
- **Given** my entered batch year is greater than the current academic year + 4, **then** validation rejects with helpful message
- **Given** I use a non-`@rajagiri.edu.in` email on the Student tab, **then** I see "Use your RSET student email or sign up via Alumni tab"
- **Given** I sign up successfully, **then** I receive a verification email within 1 minute
- **Given** I click the verification link, **then** my account is activated and I'm redirected to first-time tour

### US-1.3: Faculty Sign-Up
*As a faculty member, I want to sign up using my institutional email so I'm auto-recognized.* (F1.3)

**AC:**
- **Given** I have an email ending in `@rajagiritech.edu.in`, **when** I submit, **then** my account is created and auto-tagged "Faculty"
- **Given** I'm signing up as faculty, **then** required fields are: name, department, email, password
- **Given** I use the wrong email domain on the Faculty tab, **then** I see "Use your RSET faculty email"
- **Given** verification email + activation flow same as US-1.2

### US-1.4: Alumni Sign-Up Submission
*As an RSET alumnus, I want to register with my personal email and submit verification details.* (F1.4)

**AC:**
- **Given** I'm on the Alumni tab, **then** required fields are: name, batch year, branch, current role, current company, LinkedIn URL, email, password
- **Given** the LinkedIn URL is invalid format (not a linkedin.com/in/ profile URL), **then** validation rejects with clear message
- **Given** I submit successfully, **then** I receive a verification email and my account enters Pending state
- **Given** my account is Pending, **then** I see only the "Verification in progress" screen with no platform access
- **Given** the screen, **then** it explains: typical turnaround, what to expect, how to contact support if waiting more than the user-facing SLA window

### US-1.5: Google SSO Sign-Up / Sign-In
*As any user, I want to sign in via Google for convenience.* (F1.6)

**AC:**
- **Given** I click "Continue with Google", **then** I'm redirected through Google OAuth
- **Given** I authenticate with a `@rajagiri.edu.in` Google account, **then** I'm signed in or signed up as Student
- **Given** I authenticate with a `@rajagiritech.edu.in` Google account, **then** I'm signed in or signed up as Faculty
- **Given** I authenticate with another Google account, **then** I'm prompted to choose Alumni sign-up flow
- **Given** SSO sign-up, **then** email verification step is skipped

### US-1.6: Password Reset
*As a user, I want to reset my password if I forget it.* (F1.9)

**AC:**
- **Given** I click "Forgot password" on login, **then** I'm prompted for my email
- **Given** I submit a registered email, **then** I receive a reset link valid for 1 hour
- **Given** I use the link, **then** I can set a new password meeting requirements (≥8 chars, letters + numbers)
- **Given** I submit unregistered email, **then** UI shows generic confirmation (no information leakage)

### US-1.7: Admin Verifies Pending Alumnus
*As an admin, I want to review pending alumni and approve or reject them efficiently.* (F1.10, F1.11, F1.12)

**AC:**
- **Given** I'm on the admin dashboard, **then** I see a "Pending Alumni" queue sorted by oldest first with SLA countdown
- **Given** I open a pending record, **then** I see: name, batch year, branch, current role, company, LinkedIn URL (clickable), registration date, any internal notes from prior reviewers
- **Given** filtering options, **then** I can filter by batch year, branch, registration date range, and status
- **Given** I approve, **then** the user receives in-app + email notification "Verification approved" and gains full platform access
- **Given** I reject (first time), **then** the user receives a notification with reason and can re-submit once
- **Given** I reject (second time), **then** the account is locked; user must email admin for appeal
- **Given** I take any action, **then** an audit log entry is created identifying me as the actor

### US-1.8: First-Time User Tour
*As a new user landing for the first time, I want a brief orientation so I understand the platform.* (F1.18)

**AC:**
- **Given** I'm logging in for the first time after verification, **then** I see a 4-5 step interactive overlay
- **Given** the tour, **then** each step highlights a key feature (Q&A, Experience Feed, Resource Library, Reputation, Connection)
- **Given** any step, **then** I can dismiss with a clear "Skip tour" affordance
- **Given** I dismiss, **then** the tour does not auto-show again (but is accessible via Help menu)
- **Given** I complete the tour, **then** I'm prompted (gentle nudge) to add expertise tags

### US-1.9: Profile Completion Prompt
*As a new user, I want a gentle prompt to add optional profile details after onboarding.* (F1.16)

**AC:**
- **Given** I land on home after tour, **then** a dismissible card prompts: "Tell us what you know — pick up to 5 expertise tags so others can find you"
- **Given** I dismiss, **then** the card disappears and doesn't return
- **Given** I add tags, **then** they're saved to my profile and influence notification routing

### US-1.10: Manual Verification for Old Alumni Without LinkedIn
*As a long-ago alumnus without LinkedIn, I want a path to verify even without LinkedIn.* (F1.4 special case)

**AC:**
- **Given** I'm on the Alumni signup form and have no LinkedIn URL, **then** I see a help link: "No LinkedIn? Email admin@rajagiritech.edu.in for alternative verification"
- **Given** the form requires LinkedIn URL, **then** I cannot submit the form via the standard flow without it (the manual flow is out-of-product)
- **Given** I email admin, **then** the admin can manually create my account post-verification (operations playbook)

---

## Epic 2: Q&A

### US-2.1: Ask a Question
*As a student, I want to ask a question with proper context so I get useful answers.* (F2.1, F2.2)

**AC:**
- **Given** I'm logged in, **when** I click "Ask Question", **then** I see a form with title, markdown body, tag picker, anonymity toggle, visibility selector
- **Given** I type a title ≥10 chars, **then** duplicate detection runs and shows up to 3 similar questions with "View" links
- **Given** I select 0 tags, **then** submit is disabled with "Pick at least 1 tag"
- **Given** I select more than 5 tags, **then** the picker prevents adding more
- **Given** body exceeds 5,000 chars, **then** counter turns red and submit is disabled
- **Given** I toggle "Ask anonymously", **then** a tooltip explains: "Anonymous to community, identifiable to admins"
- **Given** I select "Department-only" visibility, **then** my question is visible only to my dept

### US-2.2: Answer Eligibility Display
*As a senior user, I want clear feedback on whether I can answer a question.* (F2.7, §5.1)

**AC:**
- **Given** I'm a verified alumnus or faculty, **when** I open any question, **then** I see the answer composer enabled
- **Given** I'm a 2nd-sem student opening a question from a 4th-sem student, **then** the composer is replaced with: "You'll be eligible to answer questions from juniors after you reach 4th semester."
- **Given** the asker is faculty or alumnus, **then** any verified user can answer
- **Given** the asker is anonymous, **then** I see a generic persona/dept attribution (e.g., "Anonymous Student — CSE 2nd year"), not their name

### US-2.3: Submit an Answer
*As an eligible user, I want to provide a useful answer to a question.* (F2.8)

**AC:**
- **Given** I'm eligible and viewing a question, **then** I can compose an answer using markdown
- **Given** body exceeds 10,000 chars, **then** counter turns red and submit is disabled
- **Given** I have already posted an answer to this question, **then** the composer is disabled with "You've already answered. Edit your existing answer."
- **Given** I submit, **then** my answer appears below the question and the asker is notified

### US-2.4: Edit Answer/Question
*As an author, I want to edit my content if I made a mistake.* (F2.14, F2.15)

**AC:**
- **Given** I'm the author of a question or answer, **then** I see an "Edit" affordance
- **Given** I edit, **then** the content shows an "edited" indicator with timestamp
- **Given** I view edit history, **then** prior versions are accessible (admin and author only for question authors; public for accepted answers)
- **Given** I edit an answer that was accepted, **then** an "edited after acceptance" notice appears if the edit is substantial

### US-2.5: Accept an Answer
*As the question asker, I want to mark the most useful answer as accepted.* (F2.9, F2.10)

**AC:**
- **Given** I'm the question author, **then** each answer shows an "Accept" button
- **Given** I click Accept, **then** that answer pins to the top, awards +25 rep to answerer, and other answers' Accept buttons disappear
- **Given** I want to change my pick, **then** I can un-accept; -25 rep reverses for the previously accepted answerer
- **Given** I accept a different answer, **then** +25 rep awards to the new answerer
- **Given** I'm anonymous, **then** I can still accept; the answerer's notification still attributes "Anonymous Student/etc."

### US-2.6: Vote on Q&A
*As any user, I want to vote on questions and answers.* (F2.11)

**AC:**
- **Given** I'm logged in, **when** I click upvote, **then** the count increments and the icon shows my state
- **Given** I downvote, **then** I see a tooltip: "Consider commenting why"
- **Given** the content is my own, **then** voting is disabled
- **Given** I'm voting on an anonymous question, **then** voting works normally (but anonymous question doesn't earn rep)

### US-2.7: Comment for Clarification
*As any user, I want to comment on a question or answer for clarification.* (F2.12)

**AC:**
- **Given** I view a question or answer, **then** I see a "Comment" affordance
- **Given** I post a comment, **then** the original author is notified
- **Given** I try to nest beyond one level, **then** the UI prevents it (can only comment on Q or A, not on a comment)
- **Given** my comment is posted, **then** I earn no reputation

### US-2.8: Faculty Endorses an Answer
*As a faculty member, I want to endorse a great answer to signal quality.* (F2.13)

**AC:**
- **Given** I'm faculty viewing any answer, **then** I see an "Endorse" action
- **Given** I endorse, **then** a "Faculty Endorsed" ribbon appears on the answer; the answerer is notified; the answer ranks higher
- **Given** I endorse an answer in another department, **then** the endorsement is allowed (cross-department signal)
- **Given** I un-endorse, **then** the ribbon is removed; answerer is not notified again

### US-2.9: Admin Archives a Question
*As an admin, I want to archive outdated questions.* (F2.16)

**AC:**
- **Given** I'm admin viewing a question, **then** I see an "Archive" action
- **Given** I archive, **then** the question becomes read-only; answers cannot be added; the question still appears in search and direct links
- **Given** archived, **then** the question shows an "Archived" indicator with archive date

---

## Epic 3: Experience Feed

### US-3.1: Post an Experience
*As any verified user, I want to share an experience post.* (F3.1, F3.3)

**AC:**
- **Given** I click "Share Experience", **then** I see a category picker (without "Faculty Announcement" if I'm not faculty), markdown editor, optional tags
- **Given** I save without picking a category, **then** submit is disabled
- **Given** body exceeds 15,000 chars, **then** counter turns red and submit is disabled
- **Given** I save successfully, **then** the post appears in the feed and on my profile

### US-3.2: Faculty Announcement
*As faculty, I want to post a department-wide announcement.* (F3.15, F3.16, F3.17)

**AC:**
- **Given** I'm faculty, **then** "Faculty Announcement" appears as a category option
- **Given** I post a Faculty Announcement, **then** I'm prompted to set an optional expiry date (default 30 days)
- **Given** the post is published, **then** it pins at the top of the Experience Feed for users in my department
- **Given** non-department users view the feed, **then** the post appears unpinned in chronological position
- **Given** my department has 3+ active announcements, **then** only the 3 most recent show pinned at top; older ones collapse to "View more pinned"
- **Given** the expiry date passes, **then** the post unpins for all users but remains visible in feed

### US-3.3: Engage with a Feed Post
*As any user, I want to engage with posts.* (F3.5, F3.6, F3.7, F3.8)

**AC:**
- **Given** I see a post, **when** I click upvote, **then** the count increments
- **Given** the post does not have downvote affordance, **then** only upvote and comment are visible interactions
- **Given** I bookmark, **then** the post is added to my private collection
- **Given** I comment, **then** the post author is notified
- **Given** I share-internal, **then** a deep link is copied to clipboard

### US-3.4: Filter and Sort Feed
*As any user, I want to filter the feed.* (F3.10)

**AC:**
- **Given** I'm in the feed, **then** I see filter affordances: persona, category, department
- **Given** I apply a filter, **then** the feed reloads and the URL preserves filter state

### US-3.5: Follow Users and Tags
*As any user, I want to follow people and topics.* (F3.11, F3.12)

**AC:**
- **Given** I view a user profile, **then** I see a "Follow" button
- **Given** I follow a user, **then** they receive a notification (unless they've turned off follower notifications)
- **Given** I follow a tag/category, **then** I can filter feed by "Following" to see those posts prioritized
- **Given** I unfollow, **then** no notification is sent

### US-3.6: Edit and Delete Posts
*As an author, I want to manage my posts.* (F3.13)

**AC:**
- **Given** I authored a post, **then** I can edit it; an "edited" indicator shows
- **Given** I delete my post and it has comments, **then** a tombstone shows: "This post was deleted by the author"
- **Given** I delete my post with no comments, **then** the post is removed entirely (no tombstone)

---

## Epic 4: Resource Library

### US-4.1: Submit a Resource
*As any verified user, I want to submit a useful resource.* (F4.2, F4.3)

**AC:**
- **Given** I'm submitting, **then** required fields are: URL (HTTPS), Title (auto-pulled from Open Graph metadata, editable), Description (≤500 chars), 1-5 Tags, Category
- **Given** the URL fails Open Graph fetch, **then** I'm prompted to enter title manually
- **Given** the URL is malformed or non-HTTPS, **then** validation rejects with clear message
- **Given** I submit, **then** the resource enters "Pending" status
- **Given** Pending, **then** the resource is visible only on my profile and in the Pending tab

### US-4.2: Browse Library and Pending Tabs
*As any user, I want to browse promoted and pending resources separately.* (F4.1, F4.9)

**AC:**
- **Given** I'm in Resource Library, **then** I see two tabs: Library (default) and Pending
- **Given** Library tab, **then** I can filter by category, tag, dept, popularity, recency
- **Given** Pending tab, **then** I see all unpromoted submissions; I can upvote them; I cannot downvote
- **Given** search, **then** results pull only from Library (Pending is excluded)

### US-4.3: Promote Resource via Upvotes
*As a community member, I want my upvotes on quality pending resources to promote them.* (F4.5, F4.6)

**AC:**
- **Given** a Pending resource reaches 5 community upvotes, **then** it auto-promotes to Library
- **Given** promotion happens, **then** submitter is notified
- **Given** I'm in Pending tab, **then** I can only upvote (no downvote affordance)

### US-4.4: Faculty Endorses a Resource
*As faculty, I want to endorse a resource to instantly promote it.* (F4.5, F4.7)

**AC:**
- **Given** I'm faculty viewing any resource (Pending or Library), **then** I see "Endorse" action
- **Given** I endorse a Pending resource, **then** it auto-promotes to Library; submitter receives +15 rep (only for first endorsement) and notification
- **Given** I endorse a Library resource that already has endorsements, **then** the visual increments ("Endorsed by N faculty") but no additional rep
- **Given** I un-endorse, **then** if endorsements drop to 0 AND upvotes < 5, resource demotes to Pending

### US-4.5: Edit and Delete Resources
*As a submitter, I want to manage my resources.* (F4.10, F4.11)

**AC:**
- **Given** I'm the submitter, **then** I can edit title, description, tags
- **Given** I want to change URL, **then** I must contact admin (URL not user-editable)
- **Given** I delete a resource with no upvotes/endorsements, **then** it's removed entirely
- **Given** I delete a resource with upvotes/endorsements, **then** a tombstone replaces it

### US-4.6: Report a Broken Link
*As any user, I want to flag broken or moved resources.* (F4.13, F4.14)

**AC:**
- **Given** I view a resource, **then** I see a "Report broken" affordance
- **Given** I click it, **then** the resource enters admin review queue with reason
- **Given** automated link-check runs monthly and detects 404s, **then** flagged resources also enter admin queue

---

## Epic 5: Connection & DM

### US-5.1: Send Connection Request
*As any user, I want to request a connection with another user.* (F5.1, F5.2, F5.7)

**AC:**
- **Given** I view another user's profile, **then** I see "Request Connection" (unless I have 5 outstanding requests, am blocked, or recipient has "no connection requests" toggle on)
- **Given** I have 5 outstanding requests, **then** the action is disabled with: "You have 5 open requests; close one to send another"
- **Given** I send, **then** I must enter 50-500 char personalized note and a topic
- **Given** I submit, **then** the recipient receives a notification

### US-5.2: Recipient Handles Connection Request
*As a recipient, I want to accept, decline, or silently decline.* (F5.3, F5.4, F5.5)

**AC:**
- **Given** I have pending requests, **then** I see them in my Connections inbox
- **Given** I click Accept, **then** DM unlocks for both parties; sender is notified
- **Given** I click Decline, **then** I'm prompted with options: provide a reason (sent to sender) OR decline silently (no notification)
- **Given** I decline silently, **then** sender sees no immediate update; request expires at 30 days normally
- **Given** I block the sender instead, **then** the request is silently rejected and the user is added to my block list

### US-5.3: Connection Request Expires
*As a sender, I want clarity when my request goes stale.* (F5.6)

**AC:**
- **Given** my request has been pending 30 days, **then** it auto-expires
- **Given** expiry, **then** I receive a notification: "Your connection request to [User] has expired. You can resend if needed."
- **Given** I want to resend, **then** I can submit a new request with the same or different note

### US-5.4: Direct Messaging
*As connected users, we want to chat.* (F5.4, F5.10)

**AC:**
- **Given** I'm connected with someone, **then** a DM thread is accessible from my Connections page
- **Given** I send a message, **then** it appears in real time (or near-real-time) for the recipient and triggers their notification preferences
- **Given** the recipient is online, **then** they see the message immediately
- **Given** the recipient is offline, **then** they see it on next login + via push/email per their preferences

### US-5.5: Disconnect or Block
*As any user, I want to manage problematic connections.* (F5.8, F5.9)

**AC:**
- **Given** I'm in a DM thread, **then** I see "Disconnect" and "Block" actions
- **Given** I disconnect, **then** the DM becomes read-only for both parties; either party can request a new connection later
- **Given** I block, **then** all interaction stops: no DM, no connection requests, no content visibility between us
- **Given** I unblock later, **then** the user can attempt connection again normally

### US-5.6: Report a DM
*As a user, I want to report harassing or inappropriate DMs.* (F5.10)

**AC:**
- **Given** I'm in a DM thread, **then** I see "Report" action
- **Given** I report, **then** the specific message thread becomes visible to admin for review
- **Given** report submitted, **then** I'm notified when admin takes action

---

## Epic 6: Reputation & Badges

### US-6.1: View Profile and Reputation
*As any user, I want to view profiles and see reputation.* (F6.13)

**AC:**
- **Given** I view any profile, **then** I see persona, name, branch, semester/batch, Expertise Score, badges, activity stats
- **Given** I hover/tap a badge, **then** I see how it was earned and the date earned

### US-6.2: Earn Reputation Through Contribution
*As a contributor, I want my activity to translate to reputation.* (F6.6)

**AC:**
- **Given** my answer is upvoted, **then** I gain +10 rep (with audit log entry)
- **Given** my answer is accepted, **then** I gain +25 rep
- **Given** my content is downvoted, **then** I lose 2 (Q) or 5 (A) rep
- **Given** my content is removed, **then** I lose 50 rep
- **Given** rep events older than 18 months exist, **then** they decay 10%/year on a daily-running basis
- **Given** my Expertise Score, **then** it always reflects post-decay total

### US-6.3: Earn a Badge
*As a contributor, I want recognition when I hit a badge threshold.* (F6.10, F6.11)

**AC:**
- **Given** I cross a badge threshold (e.g., 10 accepted answers), **then** I'm notified: "You earned the Helpful badge!"
- **Given** I'm awarded, **then** the badge appears on my profile and post bylines
- **Given** my underlying content drops below threshold (e.g., answers removed), **then** the badge is automatically revoked
- **Given** Subject Specialist, **then** I can earn it multiple times for different tags (each shows separately)

### US-6.4: Badge Display Across the Platform
*As any user, I want to see badges in context.* (F6.13)

**AC:**
- **Given** I see a question/answer/post byline, **then** the author's most prestigious badge displays inline
- **Given** I see Class of [Year], **then** it's displayed as identity-context (not on the prestige ladder)

---

## Epic 7: Faculty Functions

### US-7.1: Faculty Cross-Surface Endorsement
*As faculty, I want to endorse content across the platform.* (F7.1, F7.2, F7.4)

**AC:**
- **Given** I'm Faculty, **then** "Endorse" is available on individual answers and on resources (Pending or Library)
- **Given** I endorse, **then** the visible signal applies as defined in F2.13 / F4.7
- **Given** I endorse cross-department, **then** the action succeeds without warning

### US-7.2: Faculty Asks a Question
*As faculty, I want to ask questions like any user.* (F7.5)

**AC:**
- **Given** I'm Faculty, **then** I can ask a question with full feature parity (anonymity allowed if I want)
- **Given** I ask a question, **then** any verified user can answer (Dynamic Seniority Engine treats faculty-authored questions as open-eligibility)

---

## Epic 8: Search

### US-8.1: Global Search
*As any user, I want to search across the platform.* (F8.1, F8.2, F8.3, F8.6)

**AC:**
- **Given** I type ≥3 chars in global search, **then** I see typeahead with sections: Questions, Posts, Resources, People, Tags
- **Given** I press enter, **then** I see a results page with categorized sections and a "type" filter
- **Given** I filter by type, **then** results scope to the selected type
- **Given** the search includes a tag name, **then** matching tag-tagged content boosts in relevance

### US-8.2: Filter and Sort Search Results
*As any user, I want to refine search results.* (F8.4, F8.5)

**AC:**
- **Given** I'm on the search results page, **then** I see filters: type, department, date range, persona, tag
- **Given** sorts available, **then** I can sort by relevance (default), most recent, most upvoted, most accepted answers (Q&A only)
- **Given** I select sort/filter, **then** results update and URL preserves state

### US-8.3: Anonymous and Tombstone Behavior in Search
*As any user, I want anonymity respected and removed content excluded.* (F8.7, F8.8, F8.9)

**AC:**
- **Given** an anonymous question matches my query, **then** it appears with anonymous attribution
- **Given** content has been removed/tombstoned, **then** it does not appear in search
- **Given** a Pending resource matches my query, **then** it does not appear in search

---

## Epic 9: Notifications

### US-9.1: Notification Preferences
*As any user, I want granular control over my notifications.* (F9.1, F9.2)

**AC:**
- **Given** I'm in Settings → Notifications, **then** I see a matrix of categories × channels
- **Given** I toggle any cell, **then** the preference saves immediately
- **Given** in-app channel, **then** it cannot be turned off (always on)

### US-9.2: Push Notification Permission
*As a mobile user, I want a sensible permission ask.* (F9.3)

**AC:**
- **Given** I just completed the first-time tour, **then** I'm prompted for push permission with clear explanation
- **Given** I deny, **then** the platform doesn't ask again (per browser policy); permission can be re-requested via Settings link
- **Given** I allow, **then** push notifications work for enabled categories

### US-9.3: Aggregated Notifications
*As an active user, I don't want notification spam.* (F9.4)

**AC:**
- **Given** I receive 5 upvotes within an hour, **then** I receive one aggregated notification: "Your answer received 5 upvotes"
- **Given** I receive 3 comments on a post, **then** they aggregate similarly

### US-9.4: Weekly Digest
*As an occasional user, I want a weekly summary.* (F9.5, F9.6)

**AC:**
- **Given** I opt in to digest, **then** I receive an email Sunday 9am IST
- **Given** the digest, **then** it includes: top questions in tagged areas, posts from followed users, new resources in followed categories, weekly stats, unanswered questions in my dept

### US-9.5: Personalized Acceptance Notification
*As an answerer, I want to feel my answer's impact.* (F9.7)

**AC:**
- **Given** my answer is accepted, **then** I receive a notification: "[Aarav, 1st year CSE] accepted your answer"
- **Given** the asker was anonymous, **then** the notification reads: "An anonymous student (CSE 2nd year) accepted your answer"

---

## Epic 10: Moderation

### US-10.1: Report Content
*As any user, I want to report problematic content.* (F10.1, F10.2, F10.3)

**AC:**
- **Given** I view any user-generated content, **then** I see a "Report" affordance
- **Given** I open report, **then** I select from 8 categories + Other (free-text required for "Other")
- **Given** I report my own content, **then** the action is unavailable
- **Given** I submit, **then** I receive confirmation; the content is added to admin queue

### US-10.2: Admin Triages Reports
*As admin, I want to handle reports efficiently.* (F10.4, F10.5, F10.6, F10.7)

**AC:**
- **Given** I open the reports queue, **then** I see entries sorted by SLA priority (severe first)
- **Given** a report of content with multiple reporters, **then** the queue shows one entry with reporter count
- **Given** I open a report, **then** I see: content, reporter list, target user history (prior reports against them, prior content removals), reason
- **Given** I take action (Dismiss/Warn/Remove/Suspend/Ban), **then** the appropriate notifications send and audit log records me as actor
- **Given** I suspend a user, **then** I select duration (24h, 7d, 30d) per the penalty ladder

### US-10.3: Removed Content Tombstone
*As any user, I want transparency about moderation.* (F10.8)

**AC:**
- **Given** content has been removed by admin, **then** I see a public tombstone: "This [content type] was removed by moderators"
- **Given** I'm the original author, **then** I receive a private notification with reason for removal
- **Given** the tombstone, **then** no specifics about why are publicly visible

### US-10.4: Frivolous Reporter
*As admin, I want to deprioritize bad-faith reporters.* (F10.11)

**AC:**
- **Given** I review reports from a user, **then** I can flag them as "Frivolous Reporter"
- **Given** flagged, **then** their future reports go to a lower-priority queue (admin still reviews, just slower)

---

## Epic 11: Privacy & Data

### US-11.1: Privacy Policy at Signup
*As a new user, I want to understand and accept terms.* (F11.1)

**AC:**
- **Given** I'm signing up, **then** acceptance of Privacy Policy and Community Guidelines is required (checkbox not pre-checked)
- **Given** I haven't accepted, **then** signup submit is disabled

### US-11.2: Profile Visibility Toggles
*As any user, I want to control my visibility.* (F11.2, F11.3, F11.4)

**AC:**
- **Given** I'm in Settings → Privacy, **then** I see toggles for "Hide my activity history" and "Don't allow connection requests"
- **Given** I enable "hide activity", **then** other users see my profile, name, persona, badges — but no activity history
- **Given** I enable "no connection requests", **then** other users do not see "Request Connection" on my profile

### US-11.3: Account Deletion
*As any user, I want a clear deletion flow.* (F11.5, F11.6, F11.7)

**AC:**
- **Given** I click "Delete my account" in Settings, **then** I'm shown the consequences (anonymization vs hard-delete) and the 14-day grace period
- **Given** I confirm, **then** my account is immediately hidden from the platform; I can recover by logging in within 14 days
- **Given** 14 days pass, **then** anonymization runs (default): my content is preserved as "Deleted User"; personal data purged within 30 additional days
- **Given** I requested hard-delete, **then** all my content is removed; threads with my content show tombstones

### US-11.4: Data Export
*As any user, I want my data per DPDP rights.* (F11.8)

**AC:**
- **Given** I request data export from Settings, **then** the system queues the export
- **Given** export is ready (async, can take time), **then** I receive an email with a 7-day download link
- **Given** I download, **then** I receive a JSON file + human-readable HTML summary

### US-11.5: Right to Know (DPDP)
*As any user, I want to see admin actions on my account.* (F11.14)

**AC:**
- **Given** I'm in Settings → Privacy → Account Activity, **then** I see all admin actions on my account: persona changes, content removals on me, suspensions, etc., with timestamp and reason
- **Given** an admin viewed but did not act, **then** that view is not surfaced (only actions are)

---

## Epic 12: Tags

### US-12.1: Suggest a New Tag
*As any user, I want to suggest a missing tag.* (F12.5)

**AC:**
- **Given** I'm in the tag picker (Q&A, post, resource), **then** I see "Don't see your topic? Suggest a tag"
- **Given** I submit a suggestion, **then** it enters admin queue with my user ID
- **Given** admin approves my suggestion, **then** the tag is created and I'm notified

### US-12.2: Admin Manages Taxonomy
*As admin, I want full control of the taxonomy.* (F12.4, F12.6)

**AC:**
- **Given** I'm in admin → Tag Management, **then** I can create new tags, edit descriptions, merge duplicates, retire unused tags
- **Given** I merge two tags, **then** all content tagged with either is reassigned to the merged tag; Subject Specialist badges merge accordingly
- **Given** I retire a tag, **then** content keeps the tag (read-only); the tag no longer appears in pickers

---

## Epic 13: Lifecycle Transitions

### US-13.1: Graduation Transition
*As a final-year student, I want a smooth transition to alumni status.* (F14.1, F14.2)

**AC:**
- **Given** my expected graduation date passes, **then** I see a one-time prompt: "Confirm your transition to Alumni"
- **Given** I confirm, **then** I provide current role + LinkedIn URL (required); my persona updates to Alumni
- **Given** transition complete, **then** my profile, content, reputation, and badges all carry forward; I get the Class of [Year] badge auto-assigned
- **Given** I delay confirmation 6+ months, **then** my account is flagged for admin review

### US-13.2: Drop-Out / Transfer
*As admin, I want to handle students who leave RSET.* (F14.4)

**AC:**
- **Given** I'm admin and need to update a user, **then** I can change their persona to "Former Student"
- **Given** Former Student persona, **then** the user has browse-only access; cannot post answers, ask questions, post experiences, submit resources, or earn rep
- **Given** the user appeals, **then** persona can be restored at admin discretion

---

## Epic 14: Admin Functions

### US-14.1: Admin Dashboard
*As admin, I want a single dashboard for all my work.* (F13.7)

**AC:**
- **Given** I log in as admin, **then** I see the dashboard with sections: Verification Queue, Reports Queue, Audit Log, Tag Management, User Search, Tag Suggestions
- **Given** verification or reports past SLA, **then** they show a visual SLA-overdue indicator

### US-14.2: Multi-Admin Management
*As an admin, I want to add/remove other admins.* (F13.1, F13.3, F13.4)

**AC:**
- **Given** I'm admin viewing a user, **then** I can grant the admin role
- **Given** I want to revoke another admin, **then** I can do so (system enforces ≥1 admin remaining)
- **Given** I'm the last admin, **then** the system prevents me from removing my own admin role
- **Given** any admin grant/revoke, **then** an audit log entry is created

### US-14.3: User Persona Override
*As admin, I want to manually adjust personas.* (F1.4 alumni manual flow, F14.4)

**AC:**
- **Given** I'm admin viewing a user profile, **then** I see "Override persona" action
- **Given** I change persona, **then** the change is logged in audit trail with reason; user is notified
