# Ascend — Product Requirements Document

**For: Rajagiri School of Engineering and Technology (RSET) community**

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Author | Product Management |
| Last updated | May 2026 |
| Related docs | User Stories & ACs, Technical Design, Admin Operations Playbook, Launch Operations Plan, Brand & Voice Guidelines |

---

## 1. Vision & Problem Statement

### 1.1 Vision
Ascend is the trusted knowledge-and-mentorship platform for the RSET community. It is a place where authority is earned through verified academic seniority and institutional trust — not follower counts, not algorithmic noise, not external prestige.

### 1.2 The Problem
RSET students currently navigate academic and career decisions through fragmented, low-signal channels: ad-hoc WhatsApp groups, LinkedIn cold-DMs to alumni, faculty office hours that bottleneck, and corridor conversations that vanish. Critical institutional knowledge — internship pipelines, course experiences, project archives, faculty research, career transitions — lives with seniors and alumni, but it is not durable, not searchable, and not connected to those who would benefit. Alumni are willing to give back but lack a high-signal channel to do so.

### 1.3 Why Now
- Post-COVID acceleration of digital initiatives at RSET
- Alumni network has reached critical mass for a verified network to be valuable
- Generic platforms (LinkedIn, Reddit, WhatsApp) have proven inadequate for institution-specific, verifiable mentorship

### 1.4 Strategic Differentiator
The **Dynamic Seniority Engine**: a rule-based authority model that ensures advice flows from those who have walked the path. Combined with admin verification and a unified reputation ladder that students climb through their entire RSET life, this creates a defensible moat against generic alternatives.

---

## 2. Goals & Non-Goals

### 2.1 Goals
- Become the default knowledge surface for RSET students for academic and early-career questions
- Reactivate verified alumni as monthly contributors
- Create a durable institutional memory across courses, projects, and internships
- Reduce duplicate questions semester-over-semester for high-traffic courses
- Provide a strategic positioning advantage for RSET as a digitally-connected institution

### 2.2 Non-Goals
- Replacing the official LMS, grading systems, or attendance tooling
- Public-internet visibility — Ascend is a closed RSET community
- Recruiter-facing job board or talent-scouting features
- Mental health, wellness, or personal-struggle support — these explicitly route to college counseling
- Multi-institutional rollout
- Live video, events, or AMA features
- Content monetization

---

## 3. Personas

### 3.1 Primary Persona — Student (Customer)
- **Profile:** Currently enrolled at RSET, semesters 1 through 8, across all engineering branches
- **Wants:** Clear answers to academic and career questions; visibility into the experiences of seniors and alumni; a path to connect with people who have walked the journey
- **Pain:** Fragmented information channels; cold-DM rejection on LinkedIn; senior friends inconsistent on WhatsApp; corridor conversations don't scale or persist
- **Win condition:** Receives an accepted answer within 24 hours of asking; finds at least one alumnus willing to mentor on a specific topic; develops a sense of belonging in the broader RSET community

### 3.2 Primary Supply Persona — Alumnus
- **Profile:** Verified RSET alumnus across any batch; varying levels of professional experience; geographically distributed
- **Wants:** A low-friction way to give back; a way to maintain identity within the RSET community; recognition for contribution
- **Pain:** WhatsApp is too noisy; LinkedIn is for professional brand-building; existing channels feel transactional
- **Win condition:** Answers questions in their domain monthly; mentors at least one junior; sees clear feedback that contributions land

### 3.3 Secondary Supply Persona — Senior Student
- **Profile:** RSET students in semesters 5+ who can speak to recent academic and project experience
- **Wants:** Recognition for being knowledgeable; pre-graduation reputation that carries forward; peer status
- **Pain:** No structured way to be recognized as someone-who-knows-things
- **Win condition:** Builds Expertise Score that carries forward into alumni status; earns badges that establish standing within the community

### 3.4 Anchor Persona — Faculty
- **Profile:** Teaching faculty, HoDs, placement cell staff, and other institutional staff
- **Wants:** Amplify announcements; validate quality content; share trusted resources; preserve institutional memory
- **Pain:** Same questions repeat semester after semester; no surface for institutional memory
- **Win condition:** Endorses high-quality answers and resources; posts impactful department announcements; appears as a trusted anchor without unsustainable workload
- **Note:** Faculty are a passive prestige layer — present, valued, but not expected to contribute regularly

### 3.5 Operational Persona — Admin
- **Profile:** A small trusted team of 2-4 individuals from development and RSET operations
- **Wants:** Efficient verification; clean moderation; audit traceability
- **Pain:** Manual verification doesn't scale infinitely; moderation requires judgment
- **Win condition:** Verification turnaround under 3 days typically; no unresolved reports past SLA; audit log shows clean accountability

### 3.6 Out-of-Scope Personas
- Recruiters and industry partners
- Prospective students or parents
- External researchers or journalists

---

## 4. Functional Requirements

### 4.1 Identity & Verification

| ID | Requirement |
|---|---|
| F1.1 | Tabbed registration page with three tabs: Student, Faculty, Alumni |
| F1.2 | Student sign-up via institutional email (`@rajagiri.edu.in`); auto-verified; auto-tagged Student |
| F1.3 | Faculty sign-up via institutional email (`@rajagiritech.edu.in`); auto-verified; auto-tagged Faculty |
| F1.4 | Alumni sign-up via personal email; admin manual verification required |
| F1.5 | Email verification step for password-based signups (skipped for SSO) |
| F1.6 | Google SSO available as alternative auth method |
| F1.7 | Optional MFA for any user; recommended for admins |
| F1.8 | Password requirements: minimum 8 characters, must contain letters and numbers |
| F1.9 | Standard forgot-password flow via email reset link |
| F1.10 | Pending alumni see only "verification pending" screen with no platform access |
| F1.11 | Admin dashboard shows alumni verification queue with filters (batch year, branch, registration date, status) |
| F1.12 | Rejected alumni can re-submit once; second rejection locks account; appeals via email |
| F1.13 | Student profile fields (required): name, branch, current semester, batch year |
| F1.14 | Faculty profile fields (required): name, department, email |
| F1.15 | Alumni profile fields (required): name, batch year, branch, current role, current company, LinkedIn URL |
| F1.16 | Profile fields (optional, all personas): bio (≤280 chars), expertise tags (up to 5) |
| F1.17 | Profile pictures: initials or persona-icon avatars only (no image upload) |
| F1.18 | First-time user tour: 4-5 step interactive overlay, dismissible |
| F1.19 | Help / Getting Started page accessible from main navigation |

### 4.2 Q&A

| ID | Requirement |
|---|---|
| F2.1 | Ask question form: title (≤120 chars), markdown body (≤5,000 chars), 1-5 tags (from curated taxonomy), optional anonymity toggle, visibility (institution-wide / department-only) |
| F2.2 | Duplicate detection runs on title input (≥10 chars); surfaces up to 3 similar questions before submit |
| F2.3 | Department-only questions visible to users in the asker's department only |
| F2.4 | Anonymous questions display as "Anonymous Student/Alumnus — Branch + Sem/Year"; admin sees real identity |
| F2.5 | Anonymous questions cannot earn or lose reputation |
| F2.6 | Anonymous askers can still accept answers on their own questions |
| F2.7 | Answer eligibility gated by Dynamic Seniority Engine (§5.1) |
| F2.8 | One answer per user per question; markdown body (≤10,000 chars); editable |
| F2.9 | Asker can mark one answer as "Accepted"; pinned at top; awards rep |
| F2.10 | Un-acceptance reverses rep cleanly; re-acceptance awards rep to new accepted answer |
| F2.11 | Upvote/downvote on questions and answers; equal vote weight regardless of voter persona |
| F2.12 | Comments on Q and A; threaded one level deep; intended for clarification; no rep impact |
| F2.13 | Faculty endorsement on individual answers (Faculty Endorsed ribbon) |
| F2.14 | Edit allowed on questions and answers (with edit history and "edited" indicator) |
| F2.15 | Edit allowed after answer acceptance; "edited after acceptance" notice appears if substantial |
| F2.16 | Admin can archive outdated questions (read-only, still searchable) |

### 4.3 Experience Feed

| ID | Requirement |
|---|---|
| F3.1 | Anyone verified can post |
| F3.2 | Six categories: Internship, Project, Competition/Hackathon, Career Journey, Course Reflection, Faculty Announcement (faculty-only — others don't see this category in their picker) |
| F3.3 | Post structure: title (≤120 chars), markdown body (≤15,000 chars), required category, optional tags (1-5) |
| F3.4 | No cover images or media uploads (external link embedding supported in body) |
| F3.5 | Upvote-only on Experience Feed (no downvotes) |
| F3.6 | Comments allowed; one level deep; no rep impact |
| F3.7 | Bookmark to private personal collection |
| F3.8 | Internal share generates a deep link |
| F3.9 | Hybrid feed ranking: pinned faculty announcements first, then chronological with engagement-and-freshness boost for recent high-engagement posts |
| F3.10 | Filters: persona, category, department |
| F3.11 | Follow individual users; follow categories/tags |
| F3.12 | New follower triggers notification (default-on, toggleable) |
| F3.13 | Edit own posts (with edited indicator); delete own posts (tombstone if commented) |
| F3.14 | Admin can delete posts for moderation (tombstone shown) |
| F3.15 | Faculty Announcement specifics: pinned in Experience Feed for users in faculty's department; non-department users see post unpinned in their feed |
| F3.16 | Faculty Announcements have optional expiry date (default 30 days); after expiry, post unpins but remains visible |
| F3.17 | Multiple active Faculty Announcements pin in reverse chronological order; max 3 visible at top, others collapse to "View more pinned" |

### 4.4 Resource Library

| ID | Requirement |
|---|---|
| F4.1 | Two-tab structure: Library (promoted resources) and Pending (community curation) |
| F4.2 | Anyone verified can submit |
| F4.3 | Required fields: URL (validated, HTTPS preferred), Title (≤120 chars, auto-pulled from Open Graph metadata, editable), Description (≤500 chars), 1-5 Tags, required Category |
| F4.4 | Six categories: Course Material, Tools, Reference, Career, Higher Studies, Inspiration |
| F4.5 | Promotion: 1 faculty endorsement OR 5 community upvotes from any verified user |
| F4.6 | Pending tab is upvote-only (no downvotes) |
| F4.7 | Multiple faculty can endorse same resource (visual: "Endorsed by N faculty"); +15 rep awarded only on first endorsement |
| F4.8 | Demotion: if faculty unendorses AND upvotes drop below 5, returns to Pending |
| F4.9 | Browse by category (default landing) + filter (tag, dept, popularity, recency) + full-text search (Library tab only) |
| F4.10 | Submitter can edit title/description/tags; URL change requires admin |
| F4.11 | Submitter can delete; tombstone if has upvotes/endorsements |
| F4.12 | Resources are reportable; stay visible during moderation review |
| F4.13 | Monthly automated link-check for 404s (admin queue review) |
| F4.14 | "Report broken" button on every resource (admin queue review) |
| F4.15 | Pending resources do not appear in search results |

### 4.5 Connection & DM

| ID | Requirement |
|---|---|
| F5.1 | Any verified user can send a connection request to any other verified user |
| F5.2 | Connection request includes 50-500 char personalized note + topic field |
| F5.3 | Recipient can Accept, Decline (with optional reason), or Decline Silently (no notification to sender) |
| F5.4 | Accepted requests unlock permanent DM between the two users |
| F5.5 | Declined requests notify sender (with reason if provided); silent decline sends nothing |
| F5.6 | Requests auto-expire after 30 days if neither accepted nor declined; sender notified on expiry; can re-send |
| F5.7 | Max 5 outstanding requests per sender at any time |
| F5.8 | Either party can disconnect: DM becomes read-only; re-connecting requires new request |
| F5.9 | Either party can block: prevents all interaction, hides content from each other |
| F5.10 | DMs are reportable (admin gets access to specific message thread on report) |
| F5.11 | DM thread persists for life of both accounts; deleted if either party deletes account |

### 4.6 Reputation & Badges

| ID | Requirement |
|---|---|
| F6.1 | Unified reputation scale across all personas |
| F6.2 | Pre-graduation reputation carries forward into alumni status on graduation transition |
| F6.3 | Equal vote weight (no persona-based weighting) |
| F6.4 | Moderate decay: rep events older than 18 months decay at 10%/year |
| F6.5 | Reputation is status-only (no functional privileges unlocked by score) |
| F6.6 | Reputation events: Q upvote +5, A upvote +10, A accepted +25, Q downvote −2, A downvote −5, faculty endorsement on resource +15 (first only), content removed −50 |
| F6.7 | Comments earn no reputation |
| F6.8 | Suspended user reputation persists but hidden during suspension; restored on return |
| F6.9 | Banned user reputation permanently lost |
| F6.10 | Badges recalculated dynamically based on current valid content; revoked if underlying content is removed |
| F6.11 | Badge tiers: Identity, Gold, Maroon |
| F6.12 | 13 total badges (see §5.2) |
| F6.13 | Badges visible on profile and post bylines; tooltip explains how earned |
| F6.14 | Subject Specialist is multi-instance (separate badge per qualifying tag); merged when admin merges underlying tags |

### 4.7 Faculty Role

| ID | Requirement |
|---|---|
| F7.1 | Faculty can endorse individual answers in Q&A |
| F7.2 | Faculty can endorse resources in the Library |
| F7.3 | Faculty can post Faculty Announcements (pinned in Experience Feed for their department) |
| F7.4 | Faculty can endorse cross-department (signals quality, not jurisdiction) |
| F7.5 | Faculty can ask questions in Q&A; anyone verified can answer |
| F7.6 | Faculty department change requires admin (not self-service) |
| F7.7 | All institutional staff treated as single "Faculty" persona |

### 4.8 Search

| ID | Requirement |
|---|---|
| F8.1 | Unified global search bar in header |
| F8.2 | Categorized results: Questions, Posts, Resources, People, Tags |
| F8.3 | Tag-aware full-text search (keyword matching with tag-match boost) |
| F8.4 | Filters: type, department, date range, author persona, tag |
| F8.5 | Sort options: relevance (default), most recent, most upvoted, most accepted answers (Q&A only) |
| F8.6 | Typeahead for tags and people on search input |
| F8.7 | Anonymous questions appear in search with anonymous attribution |
| F8.8 | Tombstones do not appear in search results |
| F8.9 | Pending resources do not appear in search results |

### 4.9 Notifications

| ID | Requirement |
|---|---|
| F9.1 | Three channels: in-app (always on), email (user-controlled), push via PWA (user-controlled) |
| F9.2 | Granular per-category × per-channel preferences |
| F9.3 | Push permission requested after first-time tour completes (not on initial landing) |
| F9.4 | Aggregation for high-frequency events (multiple upvotes/comments within an hour batch into one notification) |
| F9.5 | Opt-in weekly digest, default Sunday 9am IST |
| F9.6 | Digest content: top questions in tagged expertise areas, posts from followed users, new resources in followed categories, weekly stats (rep + badges), unanswered questions in user's department |
| F9.7 | Personalized accept-notifications include asker's persona/branch/semester (anonymous remains anonymous) |
| F9.8 | Triggers: new answer to your question, new comment on your content, your answer accepted, your answer endorsed by faculty, new follower, post from someone you follow, badge earned, connection request received, connection accepted/declined (non-silent), new DM, mention via @-tag, department announcement (for dept members), report outcome (for reporters), content removal (for content authors), alumni verification approved |

### 4.10 Moderation

| ID | Requirement |
|---|---|
| F10.1 | All user-generated content reportable: questions, answers, posts, comments, resources, DMs, profiles |
| F10.2 | Users cannot report their own content |
| F10.3 | Eight categories + Other: Spam, Harassment, Hate speech, Off-topic, Misinformation, Plagiarism, Inappropriate content, Impersonation, Other (free-text) |
| F10.4 | Multiple reports of same content consolidate into single queue entry with reporter count |
| F10.5 | Reported content stays visible during admin review |
| F10.6 | Admin actions: Dismiss / Warn / Remove content / Suspend user (24h, 7d, 30d) / Permanent ban |
| F10.7 | Penalty ladder: warning → 24h → 7d → 30d → permanent ban (over 6-month rolling window); severe violations skip ladder |
| F10.8 | Removed content shows public tombstone; reason given privately to author only |
| F10.9 | No content auto-moderation (no keyword filters, no AI classifiers, no auto-removals) |
| F10.10 | Basic rate limiting in place: max posts per hour, max connection requests per day (specific limits in technical design) |
| F10.11 | Admin can flag user as "frivolous reporter" (lowers their report priority) |
| F10.12 | Appeals via direct email to admin (out-of-product) |
| F10.13 | No public moderation log |
| F10.14 | User-facing SLA copy: "typically 3 days, severe issues prioritized" |
| F10.15 | Internal admin SLA targets: 24h severe / 72h standard |

### 4.11 Privacy & Data

| ID | Requirement |
|---|---|
| F11.1 | Privacy policy and community guidelines acceptance required at signup |
| F11.2 | Profile visibility default: public to all verified users |
| F11.3 | Optional toggle: "Hide my activity history" (profile, name, persona stay visible) |
| F11.4 | Optional toggle: "Don't allow connection requests" |
| F11.5 | Account deletion: 14-day soft-delete window (account hidden, recoverable via login) |
| F11.6 | After 14 days: anonymization runs (default) — content preserved as "Deleted User", personal data purged within 30 additional days |
| F11.7 | User can request hard-delete instead of anonymize at deletion time |
| F11.8 | Data export: JSON file + human-readable summary; async generation; 7-day download link via email |
| F11.9 | Audit log retention: minimum 1 year |
| F11.10 | DM retention: tied to account lifetime; deleted when either party deletes account |
| F11.11 | Reports retained 2 years for moderation history |
| F11.12 | DPDP Act 2023 compliance |
| F11.13 | Indian cloud region for data hosting |
| F11.14 | "Right to know who accessed my data": user can see admin actions on their account, not general queue activity |

### 4.12 Tags

| ID | Requirement |
|---|---|
| F12.1 | Curated/admin-managed taxonomy (not free-form user-created) |
| F12.2 | ~90-100 starter tags across all departments at launch (full list in §6) |
| F12.3 | Each tag has a one-line description (admin-curated, shown as tooltip) |
| F12.4 | Only admins can add new tags |
| F12.5 | Users can suggest tags via lightweight form (enters admin queue) |
| F12.6 | Admin can merge tags; Subject Specialist badges merge accordingly; rep events recompute |

### 4.13 Admin Functions

| ID | Requirement |
|---|---|
| F13.1 | Multi-admin model: individual accounts, no shared credentials |
| F13.2 | All admins have full role; operationally equivalent |
| F13.3 | Existing admin can grant or revoke admin role |
| F13.4 | System enforces ≥1 admin always exists (last admin cannot remove themselves) |
| F13.5 | First admin bootstrapped at deployment |
| F13.6 | Audit log records actor by user ID for every admin action |
| F13.7 | Admin dashboard: verification queue (with filters), reports queue (with SLA timers), user search, persona override, content takedown, archive question, audit log viewer, tag management, bulk-action support |

### 4.14 Lifecycle Transitions

| ID | Requirement |
|---|---|
| F14.1 | At expected graduation date, system prompts student to confirm transition to Alumni |
| F14.2 | On confirmation: persona Student → Alumni; current role + LinkedIn URL required; profile/history/rep retained; no re-verification |
| F14.3 | If student doesn't confirm within 6 months of expected graduation: account flagged for admin review |
| F14.4 | Admin can change persona to "Former Student" for drop-outs/transfers (browse-only access, no posting, no rep earning) |
| F14.5 | Class of [Year] identity badge auto-assigned at registration (alumni) or graduation transition (students) |

---

## 5. Behavioral Logic

### 5.1 Dynamic Seniority Engine
A user can answer a question if **at least one** of the following is true:
- User is a verified Alumnus, OR
- User is Faculty, OR
- User's semester ≥ asker's semester + 2 (cross-branch allowed)

**Edge cases:**
- Lateral-entry students: counted by current semester
- Asker is Faculty or Alumnus: any verified user can answer
- Asker is anonymous: persona/branch/semester still visible for context; engine treats it normally
- Asker is "Former Student": treated as student at semester-of-departure

### 5.2 Badge Catalog

**Identity Badge (1)**
- **Class of [Year]** — Auto-assigned to alumni based on batch year (e.g., "Class of 2018"). Students show as "Student, Batch of 20XX" and convert at graduation.

**Gold Tier (7)** — Mid-prestige, achievable through consistent contribution
- **Helpful** — 10 accepted answers
- **Connector** — 5 accepted connection requests
- **Curator** — 5 faculty-endorsed resources submitted
- **Storyteller** — Experience post crosses 50 upvotes
- **Welcomer** — 20 questions answered from 1st/2nd-sem students
- **Reliable** — 80%+ accepted-answer rate over 25+ answers
- **Subject Specialist** — 80%+ accepted rate on 15+ answers within a single tag (multi-instance per qualifying tag, e.g., "Subject Specialist: Data Structures")

**Maroon Tier (5)** — High-prestige, signals long-term pillar
- **Sage** — 1000+ reputation (post-decay)
- **Pillar** — 100 accepted answers
- **Open Door** — 25 accepted connection requests
- **Elder** — Active contributor across 4+ semesters
- **Catalyst** — Top-upvoted Experience post in a semester (one per semester, ties resolved by earlier posting time)

### 5.3 Reputation Events

| Event | Δ Rep |
|---|---|
| Question upvoted | +5 |
| Answer upvoted | +10 |
| Answer accepted | +25 |
| Question downvoted | −2 |
| Answer downvoted | −5 |
| Resource endorsed by faculty (first endorsement only) | +15 |
| Content removed by moderator | −50 |
| Comments | 0 (no rep impact) |

**Decay:** Reputation events older than 18 months decay at 10% per year on a daily-running basis. Computed value reflects post-decay total.

### 5.4 Anonymity Model
- Per-question toggle for anonymity (questions only — never on answers, posts, or comments)
- Display format: "Anonymous Student/Alumnus — Branch + Semester/Year"
- Identity always visible to admins
- Anonymous questions cannot earn or lose reputation
- Anonymous askers can still accept answers
- Notifications to answerers retain anonymity ("Anonymous Student — CSE 2nd year accepted your answer")

### 5.5 Lifecycle Transitions
- **Graduation:** System detects expected graduation date; prompts user; on confirmation, persona changes Student → Alumni; current role + LinkedIn URL captured; profile, content history, and reputation all retained.
- **6-month grace:** If user doesn't confirm transition within 6 months of expected graduation, account flagged for admin review.
- **Drop-out / Transfer:** Admin manually changes persona to "Former Student" upon discovery; reduces access to browse-only.
- **Question lifecycle:** No automatic closing; admin can archive outdated questions (read-only, still searchable).

---

## 6. Tag Taxonomy (Starter List)

Approximately 90-100 tags organized below for clarity. To users, tags appear flat and are picked via typeahead. Admin can add, merge, or retire tags over time.

**Academic Subjects — CSE:** Data Structures, Algorithms, Operating Systems, Computer Networks, DBMS, Theory of Computation, Compiler Design, Software Engineering, Computer Architecture, Discrete Mathematics, Object-Oriented Programming, Web Development, Mobile Development, Cloud Computing, Distributed Systems, AI/ML, Deep Learning, Cybersecurity, Blockchain

**Academic Subjects — Other Engineering Branches:** Digital Electronics, Analog Electronics, Signals & Systems, Communication Systems, VLSI, Embedded Systems, Power Electronics, Control Systems, Electrical Machines, Power Systems, Thermodynamics, Fluid Mechanics, Manufacturing, Machine Design, Strength of Materials, Structural Analysis, Geotechnical, Transportation Engineering, Environmental Engineering

**Foundational Subjects (Cross-Branch):** Mathematics, Physics, Chemistry, Engineering Drawing, Programming Fundamentals, English/Communication, Economics, Management

**Programming Languages & Tools:** Python, Java, C, C++, JavaScript, Go, Rust, SQL, Git, Linux, Docker, AWS, Azure, GCP

**Career & Placement:** Internships, Placements, Coding Interviews, System Design Interviews, HR Interviews, Resume, FAANG, Service Companies, Product Companies, Startups, Higher Studies, GRE, GATE, CAT, MS Abroad, MBA, PhD

**Project & Skill:** Final Year Project, Mini Project, Hackathons, Open Source, Research, Competitive Programming, Personal Projects

**Faculty & Course Logistics:** Course Selection, Electives, Exam Prep, Assignment Help, Lab Work, Attendance

**Life & Logistics:** Hostel Life, Time Management, Study Habits, Mental Wellness (general advice only — soul-searching is out of scope), Campus Life, Clubs

---

## 7. Non-Functional Requirements

| Area | Target |
|---|---|
| Availability | 99.5% during academic year, 99.0% during vacation periods |
| Performance | Time-to-first-byte < 500 ms; feed load < 2 s on 4G mobile |
| Concurrent users | 1,000 at launch; scalable to 5,000+ |
| Platform | Web + PWA (Progressive Web App with home-screen install, offline-read, push notifications) |
| Browser support | Latest 2 versions of Chrome, Safari, Firefox, Edge |
| Offline capability | Read-only access to recently viewed cached content |
| Accessibility | WCAG 2.1 AA conformance |
| Localization | English only at launch |
| Privacy | DPDP Act 2023 compliance |
| Hosting | Indian cloud region (data residency) |
| Authentication | Email/password with verification step + Google SSO option; MFA optional |
| Audit retention | Minimum 1 year |
| Backups | Daily database snapshots; 30-day point-in-time recovery |
| Media handling | External link embedding only (Open Graph metadata for previews); no platform-side image or file storage |

---

## 8. Data Model (High-Level)

Detailed schema in Technical Design document. Core entities:

- **User** (id, email, persona, branch/department, semester, batch_year, current_role, current_company, linkedin_url, verification_status, expertise_tags[], rep_score, profile_visibility_settings, created_at, deleted_at)
- **AdminRole** (user_id, granted_by, granted_at, revoked_at)
- **Question** (id, author_id, title, body, tags[], anonymous_flag, visibility_scope, accepted_answer_id, archived_at, created_at, edited_at)
- **Answer** (id, question_id, author_id, body, vote_score, accepted_at, faculty_endorsed_by[], created_at, edited_at)
- **Comment** (id, parent_type, parent_id, author_id, body, created_at)
- **Post** (id, author_id, body, title, category, tags[], pinned, expiry_date, created_at, edited_at)
- **Resource** (id, submitter_id, url, title, description, tags[], category, status (Pending/Library), endorsement_count, upvote_count, created_at)
- **ConnectionRequest** (id, sender_id, recipient_id, note, topic, status (Pending/Accepted/Declined/SilentlyDeclined/Expired), expires_at, decided_at, decline_reason)
- **DMThread** (id, user_a_id, user_b_id, status (Active/ReadOnly/Disconnected), created_at)
- **Message** (id, thread_id, sender_id, body, created_at)
- **Block** (id, blocker_id, blocked_id, created_at)
- **Vote** (id, voter_id, target_type, target_id, direction (+1/−1), created_at)
- **ReputationEvent** (id, user_id, delta, source_type, source_id, created_at, decayed_at)
- **Badge** (id, user_id, badge_type, sub_tag, earned_at, revoked_at)
- **Tag** (id, name, description, category_hint, created_by, created_at)
- **TagSuggestion** (id, suggester_id, name, status, reviewed_by, reviewed_at)
- **Report** (id, reporter_id, target_type, target_id, reason, status, resolved_by, resolved_at, action_taken)
- **AuditLogEntry** (id, actor_id, action, target_type, target_id, metadata, created_at)
- **Notification** (id, user_id, type, content, read_at, channel, created_at)
- **Follow** (id, follower_id, target_type, target_id, created_at)
- **Bookmark** (id, user_id, target_type, target_id, created_at)
- **PenaltyRecord** (id, user_id, action, reason, severity, expires_at, created_at)

---

## 9. Success Metrics & KPIs

### 9.1 North-Star Metrics
- Weekly Active Users / Monthly Active Users ratio > 0.4
- Median time-to-first-accepted-answer < 24 hours

### 9.2 Engagement Metrics
- % of new students with ≥1 accepted answer in their first 30 days
- Verified Alumni MAU as % of total verified alumni > 10%
- % of connection requests accepted within 7 days > 50%
- Average questions answered per active alumnus per month

### 9.3 Quality Metrics
- % of questions with at least one answer within 48 hours > 70%
- Resource Library: ≥80% of links unbroken (quarterly automated check)
- % of reports resolved within internal SLA: 95%
- Answer acceptance rate (across all answers)

### 9.4 Trust Metrics
- NPS (quarterly): ≥30 (students), ≥40 (alumni), ≥50 (faculty)
- % of users who have completed identity verification successfully on first try
- Number of moderation actions per 1000 active users (lower is better)

---

## 10. Roadmap & Phasing

Technical launch is a single cutover with the full product live. Audience exposure is sequenced via announcement timing.

### 10.1 Pre-Launch (≥2 weeks)
- QA and pre-launch testing in staging environment
- Pre-population of seed content (faculty Q&A pairs, alumni Experience posts, endorsed resources, full tag taxonomy)
- Admin team training on dashboard and operations playbook
- Privacy policy and community guidelines finalized
- Communication kits prepared for departmental announcements

### 10.2 Launch — CSE Announcement (Week 1)
- Public technical launch (platform live, full feature set, all RSET departments accessible)
- CSE department informed first via official RSET channels (department mailing lists, faculty announcements, alumni outreach)
- Admin verification load monitored; SLA upheld
- Health guardrails monitored daily

### 10.3 Sequential Department Announcements (Weeks 2-4)
- One department added to the announcement schedule at a time
- Health guardrails checked before each new announcement
- Time floor: minimum 4-7 days between department announcements
- Order TBD by RSET institutional preference

### 10.4 Open Operation (Week 5+)
- All departments aware
- Operating in steady-state
- Quarterly retrospectives to refine taxonomy, badges, and operational processes

---

## 11. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Cold-start ghost-town effect | Medium | High | Pre-launch content seeding by faculty and known alumni; full taxonomy ready from day one |
| Alumni inactivity | Medium | High | Recognition via badges; impact-loop notifications; weekly digest |
| Reputation gaming | Low | Medium | Decay function; admin review of suspicious patterns |
| Single point of admin failure | Low | High | Multi-admin model from day one; documented escalation paths |
| Sensitive content / harassment | Medium | High | Clear moderation policy; penalty ladder; no auto-moderation but rapid manual review |
| Faculty workload | Low | Medium | Endorsements opt-in; no SLAs on faculty actions; passive prestige model |
| Verification surge at announcement | High | Medium | Staged announcement schedule; admin pre-allocated time; honest user-facing SLA copy |
| DPDP non-compliance | Low | Critical | Privacy review pre-launch; lawyer consultation; built-in data export and deletion |
| Link rot in Resource Library | Medium | Low | Monthly automated check + community report-broken affordance |
| Tag taxonomy chaos | Low | Medium | Admin-only tag creation; user suggestion form + admin curation |

---

## 12. Glossary

- **Persona:** User type — Student, Faculty, Alumni (and operationally, Admin)
- **Seniority:** Position in academic progression (semester for students, year for alumni)
- **Expertise Score:** Cumulative reputation, post-decay
- **Maroon / Gold:** Tier labels for badges (high-prestige and mid-prestige respectively)
- **Endorsement:** Faculty-only quality signal on an answer or resource
- **Pending state:** Limited-access state for unverified alumni (no platform access)
- **Library / Pending tabs:** Resource Library subsections for promoted vs. community-curation resources
- **Class of [Year]:** Identity badge tied to graduation year
- **Subject Specialist:** Multi-instance Gold badge tied to demonstrated expertise within a specific tag
- **Dynamic Seniority Engine:** The rule set determining who can answer whose questions
- **DPDP Act:** India's Digital Personal Data Protection Act, 2023
