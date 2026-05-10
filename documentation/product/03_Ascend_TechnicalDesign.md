# Ascend — Technical Design & Data Model

**Companion to PRD v1.0**

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Audience | Engineering team |

> This document covers system architecture, data model, key flows, and technical considerations. It is **not** a deployment guide — engineering will produce that separately. The intent here is to ensure the PRD's requirements are technically grounded and to surface architecture decisions for engineering buy-in.

---

## 1. System Architecture (High-Level)

### 1.1 Architectural Style
A conventional **client-server web application** with a Progressive Web App (PWA) frontend and a stateless backend API. No microservices; a single backend service is sufficient at expected scale.

### 1.2 Component Overview

```
┌─────────────────────────────────────────────────┐
│         PWA Client (Web + Mobile via PWA)       │
│  - Responsive UI, offline read, push receiver   │
└──────────────────┬──────────────────────────────┘
                   │ HTTPS / WSS
                   │
┌──────────────────▼──────────────────────────────┐
│              Backend API Service                │
│  - REST/GraphQL endpoints                       │
│  - Auth, business logic, validation             │
│  - WebSocket for DM (real-time)                 │
└──────┬───────────┬──────────┬──────────┬────────┘
       │           │          │          │
   ┌───▼───┐  ┌────▼───┐  ┌──▼────┐  ┌──▼────────┐
   │ DB    │  │ Search │  │ Object│  │ Email/Push│
   │ (Pri- │  │ Index  │  │ Store │  │ Provider  │
   │ mary) │  │        │  │ (logs)│  │           │
   └───────┘  └────────┘  └───────┘  └───────────┘
       │
   ┌───▼─────────────────────────────────────────┐
   │ Background Workers                          │
   │ - Rep decay job (daily)                     │
   │ - Link-rot check job (monthly)              │
   │ - Notification dispatcher                   │
   │ - Data export generator                     │
   │ - Account deletion finalizer (14-day jobs)  │
   └─────────────────────────────────────────────┘
```

### 1.3 Hosting & Infrastructure
- **Cloud region:** Indian region (AWS Mumbai, Azure India Central, or GCP Mumbai) — DPDP data residency
- **Service runtime:** Containerized (Docker) deployable on managed Kubernetes or simpler container service depending on scale needs
- **Database:** PostgreSQL (relational primary) — chosen for ACID, JSONB support for flexible fields, mature tooling
- **Search:** Postgres full-text search at MVP scale; can graduate to Meilisearch or OpenSearch if scale demands
- **Cache:** Redis for session storage, rate limiting, real-time presence
- **Object store:** S3-compatible store for audit logs, exported data files (no user uploads — only system-generated artifacts)
- **Email:** Transactional email provider (e.g., AWS SES Mumbai, SendGrid)
- **Push:** Web Push protocol via VAPID

### 1.4 Tech Stack Recommendations (Indicative, Engineering's Final Call)
- **Frontend:** React or similar; PWA-ready framework; component library that supports WCAG 2.1 AA out of the box
- **Backend:** Node.js (Express/NestJS) or Python (FastAPI/Django) or Go — engineering's choice based on team familiarity
- **API style:** REST is sufficient; GraphQL optional if engineering prefers
- **Realtime:** WebSocket for DMs and live notification updates

### 1.5 Non-Negotiables Regardless of Stack Choice
- HTTPS everywhere; HSTS enabled
- All sensitive data at rest encrypted (database-level encryption)
- Audit log writes are append-only and immutable
- Email verification tokens single-use, time-limited
- Password storage: bcrypt or Argon2 with appropriate work factor
- Rate limiting at gateway layer (not just application layer)
- Database backups daily with 30-day point-in-time recovery
- Indian region only — no cross-border data flows

---

## 2. Data Model

### 2.1 User & Identity

```
User
─────
id              UUID (PK)
email           VARCHAR (unique, indexed)
password_hash   VARCHAR (nullable if SSO-only)
auth_provider   ENUM (password | google_sso)
persona         ENUM (student | faculty | alumnus | former_student)
verification_status ENUM (pending | verified | rejected | locked)
name            VARCHAR
branch          VARCHAR (for student/alumni/former)
department      VARCHAR (for faculty)
semester        INT (current sem, nullable for alumni/faculty)
batch_year      INT (graduation year for alumni/student)
current_role    VARCHAR (for alumni)
current_company VARCHAR (for alumni)
linkedin_url    VARCHAR (for alumni)
bio             TEXT (≤280 chars)
expertise_tags  UUID[] (FK to Tag)
profile_visibility_hide_activity   BOOLEAN
profile_visibility_no_requests     BOOLEAN
mfa_enabled     BOOLEAN
created_at      TIMESTAMPTZ
deleted_at      TIMESTAMPTZ (nullable, marks soft-delete)
hard_deleted_at TIMESTAMPTZ (nullable, marks anonymization)
```

```
AdminRole
─────────
user_id     UUID (PK, FK to User)
granted_by  UUID (FK to User)
granted_at  TIMESTAMPTZ
revoked_at  TIMESTAMPTZ (nullable)
```

### 2.2 Q&A

```
Question
────────
id              UUID (PK)
author_id       UUID (FK to User)
title           VARCHAR (≤120)
body            TEXT (≤5000 chars markdown)
tags            UUID[] (1-5 FK to Tag)
anonymous_flag  BOOLEAN
visibility_scope ENUM (institution | department)
accepted_answer_id UUID (nullable, FK to Answer)
archived_at     TIMESTAMPTZ (nullable)
created_at      TIMESTAMPTZ
edited_at       TIMESTAMPTZ (nullable)
edit_count      INT
```

```
Answer
──────
id          UUID (PK)
question_id UUID (FK to Question)
author_id   UUID (FK to User)
body        TEXT (≤10000 chars markdown)
vote_score  INT (denormalized: upvotes - downvotes)
accepted_at TIMESTAMPTZ (nullable)
faculty_endorsed_by UUID[] (array of FK to User where User.persona='faculty')
created_at  TIMESTAMPTZ
edited_at   TIMESTAMPTZ (nullable)
edit_count  INT
```

```
Comment
───────
id          UUID (PK)
parent_type ENUM (question | answer | post | resource)
parent_id   UUID
author_id   UUID (FK to User)
body        TEXT (≤2000 chars)
created_at  TIMESTAMPTZ
```

### 2.3 Experience Feed

```
Post
────
id          UUID (PK)
author_id   UUID (FK to User)
title       VARCHAR (≤120)
body        TEXT (≤15000 chars markdown)
category    ENUM (internship | project | hackathon | career | course_reflection | faculty_announcement)
tags        UUID[] (0-5 FK to Tag)
pinned      BOOLEAN (true for active faculty announcements)
expiry_date DATE (nullable, only for faculty announcements)
upvote_count INT (denormalized)
created_at  TIMESTAMPTZ
edited_at   TIMESTAMPTZ (nullable)
deleted_at  TIMESTAMPTZ (nullable, tombstone)
```

### 2.4 Resource Library

```
Resource
────────
id              UUID (PK)
submitter_id    UUID (FK to User)
url             VARCHAR (validated, HTTPS)
title           VARCHAR (≤120)
description     VARCHAR (≤500)
tags            UUID[] (1-5 FK to Tag)
category        ENUM (course_material | tools | reference | career | higher_studies | inspiration)
status          ENUM (pending | library | tombstone)
endorsement_count INT (denormalized count of faculty endorsements)
endorsed_by     UUID[] (array of faculty user IDs)
upvote_count    INT (denormalized)
created_at      TIMESTAMPTZ
last_link_check_at TIMESTAMPTZ (nullable, for monthly automated check)
link_status     ENUM (ok | broken | unchecked)
```

### 2.5 Connections & DMs

```
ConnectionRequest
─────────────────
id              UUID (PK)
sender_id       UUID (FK to User)
recipient_id    UUID (FK to User)
note            TEXT (50-500 chars)
topic           VARCHAR (≤120)
status          ENUM (pending | accepted | declined | silently_declined | expired | cancelled)
expires_at      TIMESTAMPTZ (sender created_at + 30 days)
decided_at      TIMESTAMPTZ (nullable)
decline_reason  TEXT (nullable, only if recipient provided one)
created_at      TIMESTAMPTZ
```

```
DMThread
────────
id          UUID (PK)
user_a_id   UUID (FK to User)  -- canonical: lower UUID
user_b_id   UUID (FK to User)  -- canonical: higher UUID
status      ENUM (active | read_only)
created_at  TIMESTAMPTZ (when first connection accepted)
disconnected_at TIMESTAMPTZ (nullable)
disconnected_by UUID (nullable, FK to User)
```

```
Message
───────
id        UUID (PK)
thread_id UUID (FK to DMThread)
sender_id UUID (FK to User)
body      TEXT
created_at TIMESTAMPTZ
read_at   TIMESTAMPTZ (nullable)
```

```
Block
─────
id          UUID (PK)
blocker_id  UUID (FK to User)
blocked_id  UUID (FK to User)
created_at  TIMESTAMPTZ
unique constraint (blocker_id, blocked_id)
```

### 2.6 Voting & Reputation

```
Vote
────
id          UUID (PK)
voter_id    UUID (FK to User)
target_type ENUM (question | answer | post | resource | resource_pending)
target_id   UUID
direction   SMALLINT (+1 or -1; -1 invalid for post and resource_pending)
created_at  TIMESTAMPTZ
unique constraint (voter_id, target_type, target_id)
```

```
ReputationEvent
───────────────
id          UUID (PK)
user_id     UUID (FK to User)
delta       INT (signed)
source_type ENUM (q_upvote | a_upvote | a_accepted | q_downvote | a_downvote | resource_endorsed | content_removed | other)
source_id   UUID (nullable, points to the source action)
created_at  TIMESTAMPTZ
decay_factor NUMERIC (computed daily, 0.0-1.0)
effective_value NUMERIC (delta * decay_factor — denormalized for fast aggregation)
```

```
Badge
─────
id          UUID (PK)
user_id     UUID (FK to User)
badge_type  ENUM (helpful | connector | curator | storyteller | welcomer | reliable | subject_specialist | sage | pillar | open_door | elder | catalyst | class_of)
sub_tag     UUID (nullable, FK to Tag — only for subject_specialist)
sub_year    INT (nullable, for class_of)
earned_at   TIMESTAMPTZ
revoked_at  TIMESTAMPTZ (nullable, when underlying content drops below threshold)
unique constraint (user_id, badge_type, sub_tag, sub_year)
```

### 2.7 Tags

```
Tag
───
id          UUID (PK)
name        VARCHAR (canonical, unique)
description TEXT (one-line)
created_by  UUID (FK to User, must be admin)
merged_into UUID (nullable, FK to Tag — for retired tags pointing to canonical)
created_at  TIMESTAMPTZ
```

```
TagSuggestion
─────────────
id          UUID (PK)
suggester_id UUID (FK to User)
proposed_name VARCHAR
context     TEXT (where they wanted to use it)
status      ENUM (pending | approved | rejected)
reviewed_by UUID (FK to User, nullable)
reviewed_at TIMESTAMPTZ (nullable)
created_at  TIMESTAMPTZ
```

### 2.8 Reports & Moderation

```
Report
──────
id              UUID (PK)
reporter_id     UUID (FK to User)
target_type     ENUM (question | answer | post | comment | resource | dm_message | profile)
target_id       UUID
reason          ENUM (spam | harassment | hate_speech | off_topic | misinformation | plagiarism | inappropriate | impersonation | other)
free_text       TEXT (nullable, required if reason='other')
status          ENUM (open | resolved | dismissed)
resolved_by     UUID (FK to User, nullable)
resolved_at     TIMESTAMPTZ (nullable)
action_taken    ENUM (none | warned | content_removed | user_suspended_24h | user_suspended_7d | user_suspended_30d | user_banned)
severity_level  ENUM (severe | standard) -- determined by reason category
created_at      TIMESTAMPTZ
```

```
ReportConsolidation
───────────────────
target_type, target_id           -- composite key
report_ids   UUID[]               -- all reports against this target
first_reported_at TIMESTAMPTZ
last_reported_at  TIMESTAMPTZ
status       ENUM (open | resolved | dismissed)
```

```
PenaltyRecord
─────────────
id          UUID (PK)
user_id     UUID (FK to User)
type        ENUM (warning | suspension_24h | suspension_7d | suspension_30d | permanent_ban)
related_report_id UUID (FK to Report)
reason      TEXT
issued_by   UUID (FK to User, admin)
issued_at   TIMESTAMPTZ
expires_at  TIMESTAMPTZ (nullable, NULL for permanent ban)
```

### 2.9 Audit & Notifications

```
AuditLogEntry
─────────────
id          UUID (PK)
actor_id    UUID (FK to User, must be admin)
action      VARCHAR (e.g., 'verify_alumnus', 'remove_content', 'suspend_user', 'change_persona', 'merge_tags')
target_type VARCHAR
target_id   UUID (nullable)
metadata    JSONB
created_at  TIMESTAMPTZ
-- Index on (actor_id, created_at), (target_id, created_at)
```

```
Notification
────────────
id          UUID (PK)
user_id     UUID (FK to User)
type        ENUM (answer_received | comment | answer_accepted | answer_endorsed | new_follower | followed_post | badge_earned | connection_request | connection_accepted | connection_declined | connection_expired | new_dm | mention | dept_announcement | report_outcome | content_removed | verification_approved | verification_rejected | digest)
content     JSONB (e.g., { 'question_id': '...', 'asker_persona': '...' })
channel     ENUM (in_app | email | push)
read_at     TIMESTAMPTZ (nullable)
delivered_at TIMESTAMPTZ
created_at  TIMESTAMPTZ
```

```
NotificationPreference
──────────────────────
user_id   UUID (FK to User)
category  ENUM (matching Notification.type categories)
in_app    BOOLEAN (always true, cannot be turned off)
email     BOOLEAN
push      BOOLEAN
unique constraint (user_id, category)
```

### 2.10 Follows & Bookmarks

```
Follow
──────
id          UUID (PK)
follower_id UUID (FK to User)
target_type ENUM (user | tag | category)
target_id   UUID (for tag/user) or VARCHAR (for category enum value)
created_at  TIMESTAMPTZ
unique constraint (follower_id, target_type, target_id)
```

```
Bookmark
────────
id          UUID (PK)
user_id     UUID (FK to User)
target_type ENUM (question | answer | post | resource)
target_id   UUID
created_at  TIMESTAMPTZ
unique constraint (user_id, target_type, target_id)
```

---

## 3. Key Flows (Sequence Outlines)

### 3.1 Alumni Verification Flow
1. User submits Alumni signup form
2. Backend creates User row with `verification_status='pending'`
3. Email verification link sent
4. User clicks link → email confirmed
5. Account remains in pending state; pending screen displayed
6. Admin opens dashboard, sees user in queue
7. Admin reviews LinkedIn URL + registration data, takes action
8. Approve: `verification_status='verified'` + audit log + notification
9. Reject (1st time): `verification_status='rejected'` + reason + can re-submit
10. Reject (2nd time): `verification_status='locked'` + appeal-via-email guidance

### 3.2 Asking and Answering a Question
1. User submits Ask form; client sends to API
2. Backend validates, performs duplicate detection (search query against existing question titles), runs anonymity check, creates Question row
3. Notifications dispatched to followers of asker / tags
4. Eligible users see question; backend computes eligibility per Dynamic Seniority Engine for each viewer
5. Eligible answerer submits Answer; Answer row created
6. Asker is notified via in-app/email/push per their preferences
7. Asker accepts an answer: Question.accepted_answer_id updated, ReputationEvent created (+25), Notification dispatched to answerer
8. Personalized accept-notification crafted with asker's persona context (anonymity preserved if applicable)

### 3.3 Connection Request Lifecycle
1. Sender submits request with note and topic
2. Backend checks: sender has <5 outstanding, recipient hasn't blocked sender, recipient doesn't have "no requests" toggle
3. ConnectionRequest row created with `status='pending', expires_at=now()+30d`
4. Recipient receives notification
5. Recipient acts:
   - **Accept:** status='accepted', DMThread created, both parties notified
   - **Decline (with reason):** status='declined', sender notified with reason
   - **Decline silently:** status='silently_declined', no sender notification
   - **Block:** silently_declined + Block row created
6. If 30 days pass with no decision: background job marks status='expired', notifies sender
7. On disconnect: DMThread.status='read_only'; either party can request anew

### 3.4 Reputation Decay Flow (Daily Background Job)
1. Job runs daily at off-peak time
2. For each ReputationEvent older than 18 months:
   - Compute new decay_factor based on age (10%/year linear)
   - Update effective_value
3. User.rep_score recomputed as SUM(effective_value) for all events
4. Badges recomputed: any badge whose threshold is no longer met → revoked

### 3.5 Account Deletion Flow
1. User clicks "Delete account"; sees consequence dialog
2. User confirms; User.deleted_at = now()
3. Account immediately hidden from all platform views (user can still log in to recover)
4. Background job runs daily: for users with deleted_at older than 14 days:
   - Run anonymization (default) or hard-delete (if user requested)
   - Anonymization: replace name/bio/email; preserve content as "Deleted User"; purge personal data
   - Hard-delete: remove all user content; threads with their content show tombstones
   - User.hard_deleted_at = now()
5. Personal data fully purged within 30 additional days

### 3.6 Notification Dispatch Flow
1. Trigger event occurs (e.g., answer accepted)
2. Backend creates Notification row(s) per recipient × per enabled channel
3. In-app: immediately visible via user's notification feed
4. Email: queued to email provider; respects aggregation window for high-frequency types
5. Push: queued to Web Push service; sent to user's registered subscriptions
6. Aggregation: for upvote/comment notifications, batch within 1-hour windows

---

## 4. APIs (High-Level)

Detailed OpenAPI/GraphQL spec to be produced by engineering. The following lists the major endpoint groups:

### 4.1 Auth
- POST /auth/signup (per-persona)
- POST /auth/login
- POST /auth/sso/google
- POST /auth/verify-email
- POST /auth/forgot-password
- POST /auth/reset-password
- POST /auth/logout

### 4.2 Users & Profiles
- GET /users/me
- PATCH /users/me
- GET /users/:id
- POST /users/:id/follow
- DELETE /users/:id/follow
- POST /users/:id/block
- DELETE /users/:id/block
- GET /users/:id/badges
- GET /users/:id/activity (respects privacy toggles)

### 4.3 Q&A
- POST /questions
- GET /questions/:id
- PATCH /questions/:id (edit)
- POST /questions/:id/answers
- PATCH /answers/:id (edit)
- POST /answers/:id/accept (asker only)
- DELETE /answers/:id/accept (un-accept)
- POST /questions/:id/comments, POST /answers/:id/comments
- POST /votes (any target)
- POST /answers/:id/endorse (faculty only)

### 4.4 Experience Feed
- POST /posts
- GET /posts (with filters)
- PATCH /posts/:id
- DELETE /posts/:id
- POST /posts/:id/comments
- POST /posts/:id/bookmark

### 4.5 Resources
- POST /resources
- GET /resources?status=library|pending
- PATCH /resources/:id (submitter)
- POST /resources/:id/endorse (faculty)
- POST /resources/:id/report-broken

### 4.6 Connections & DM
- POST /connections (send request)
- POST /connections/:id/accept
- POST /connections/:id/decline (with optional reason or silent flag)
- POST /connections/:id/cancel
- GET /threads
- GET /threads/:id/messages
- POST /threads/:id/messages
- POST /threads/:id/disconnect

### 4.7 Search
- GET /search?q=...&type=...&filters=...

### 4.8 Notifications
- GET /notifications
- PATCH /notifications/:id/read
- GET /notifications/preferences
- PATCH /notifications/preferences

### 4.9 Reports
- POST /reports
- GET /admin/reports (admin)
- POST /admin/reports/:id/resolve (admin)

### 4.10 Admin
- GET /admin/verifications/pending
- POST /admin/verifications/:user_id/approve
- POST /admin/verifications/:user_id/reject
- POST /admin/users/:id/persona (override)
- POST /admin/users/:id/suspend
- POST /admin/users/:id/ban
- POST /admin/admins (grant role)
- DELETE /admin/admins/:user_id (revoke role)
- POST /admin/tags (create)
- PATCH /admin/tags/:id (edit/merge)
- GET /admin/audit-log

### 4.11 Privacy
- POST /privacy/data-export (request export)
- POST /privacy/account-delete (initiate)
- POST /privacy/account-recover (within 14d)
- GET /privacy/account-activity (admin actions on me)

---

## 5. Critical Cross-Cutting Concerns

### 5.1 Authentication & Authorization
- Session tokens via secure HTTP-only cookies; CSRF protection via tokens
- Per-request authorization middleware computes effective permissions based on persona, admin role, and target ownership
- Dynamic Seniority Engine implemented as a pure function: `canAnswer(viewer, question) -> bool`

### 5.2 Anti-Abuse & Rate Limits
- Rate limiting at gateway layer:
  - Posts (Q/A/Post/Resource): max 10 per hour per user
  - Connection requests sent: max 10 per day per user
  - Comments: max 30 per hour per user
  - Votes: max 200 per hour per user
- IP-based rate limits on auth endpoints
- CAPTCHA fallback on auth on suspected abuse

### 5.3 Search Implementation
- Postgres full-text search at MVP scale using `tsvector` + GIN indexes
- Tag-aware boost: queries match against `title || body || tags` with weighted scoring
- Typeahead via simple prefix search on tags and user names
- Excluded from index: tombstoned content, pending resources

### 5.4 Real-Time Features
- WebSocket connection per logged-in user
- Used for: DM message delivery, live notification badge updates
- Reconnection with exponential backoff on disconnects
- Fallback to polling if WebSocket unavailable

### 5.5 Background Jobs
- Daily: reputation decay computation, badge re-evaluation, account deletion finalization
- Monthly: link-rot check on Resource Library
- Weekly: digest email composition and dispatch (Sunday 9am IST)
- On-demand: data export generation, email sending, push notification delivery

### 5.6 Audit Log Integrity
- Append-only table; no UPDATE or DELETE permitted by application
- Periodic exports to immutable object storage (write-once-read-many)
- Audit log queryable by admin via dashboard

### 5.7 PWA Specifics
- Service worker for offline read of recently viewed content
- Web Push for notifications (VAPID keys)
- Installable on mobile home screen; appears as native-like
- Cache strategy: stale-while-revalidate for content pages, network-first for fresh data

### 5.8 Accessibility (WCAG 2.1 AA)
- Semantic HTML throughout
- Keyboard navigation tested for every interactive element
- ARIA attributes where semantic HTML insufficient
- Focus indicators visible
- Color contrast ≥4.5:1 for text, ≥3:1 for UI components
- Form labels properly associated
- Error messages announced via live regions
- Tested with screen readers (NVDA, VoiceOver) before launch

---

## 6. Data Migrations & Lifecycle

### 6.1 Initial Data Seeding
- Tag taxonomy populated from PRD §6 list at deployment
- First admin account bootstrapped via deployment script
- No user data migrated (greenfield)

### 6.2 Reputation Recalculation
- On schema change to reputation events, full recompute is supported via background job
- Idempotent: re-running produces same result

### 6.3 Tag Merge Operation
- Atomic transaction: update all content references, recompute Subject Specialist badges, mark old tag as merged
- Old tag remains queryable but redirects to canonical

---

## 7. Security Considerations

- **OWASP Top 10 awareness throughout development**
- **Input validation:** all user input validated server-side; markdown rendering uses safe parser (escapes HTML)
- **XSS prevention:** content security policy (CSP) headers; sanitize markdown output
- **CSRF prevention:** SameSite cookies + CSRF tokens on state-changing requests
- **SQL injection:** parameterized queries only (ORM-mediated)
- **Sensitive data:** passwords hashed (Argon2 or bcrypt with strong work factor); MFA TOTP secrets encrypted at rest
- **Email links:** time-limited, single-use tokens
- **Rate limiting:** at gateway and application layers
- **Audit:** all admin actions logged; external log retention
- **Dependency management:** automated vulnerability scanning (e.g., Dependabot, Snyk)
- **Penetration testing:** at least one external pen test before launch

---

## 8. Performance & Scalability Notes

### 8.1 Expected Scale (Year 1)
- ~3,000 concurrent users at peak (institutional scale)
- ~5,000-10,000 verified alumni over time
- ~10,000-20,000 active users overall

### 8.2 Hot Paths
- Feed render: paginated, indexed by created_at; cache-warm common queries
- Q&A view: read-heavy; consider CDN/edge caching for non-personalized parts
- Notification badge counter: cache aggressively; invalidate on new notification

### 8.3 Bottleneck Risk Areas
- Reputation aggregation: pre-compute User.rep_score on event write rather than recompute on read
- Search: monitor index size; graduate to dedicated search engine if Postgres FTS becomes inadequate
- Notification dispatch: high fan-out events (e.g., faculty announcement to 500 students) must use queue-based delivery

---

## 9. Open Engineering Decisions

These are explicitly left to engineering discretion at implementation time:

- Specific framework and language choice (within stack constraints)
- ORM vs raw SQL
- Specific managed services for hosting
- Specific email and push providers
- Specific monitoring and alerting tooling (Sentry, DataDog, etc.)
- CI/CD pipeline tooling
- Specific testing framework
- Specific design system / component library

---

## 10. Out-of-Scope (Engineering Should Not Build)

To make scope explicit:

- File or image upload functionality
- Native mobile apps
- Public API for third parties
- Webhooks
- Federated identity beyond Google SSO
- Cross-institutional features
- Recommendation engine / ML-driven feed ranking
- Voice/video DM
- Live events or video streaming
- Marketplace or transaction features
