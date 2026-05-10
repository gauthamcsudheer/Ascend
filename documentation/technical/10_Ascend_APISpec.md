# Ascend — API Specification

| Field | Value |
|---|---|
| Version | 1.0 |
| Base URL | `/api/v1` |
| Content-Type | `application/json` (JSON only) |
| Authentication | Session cookie (HTTP-only, Secure, SameSite=Lax) |

> This document specifies the REST API contract. Engineering will produce an OpenAPI YAML during build for tooling integration; this is the human-readable source of truth. Routes are grouped by resource. Each entry gives method, path, auth requirements, request shape, and response shape (success and material errors).

---

## Conventions

### Authentication
- All authenticated endpoints require a valid session cookie. Missing/invalid → `401 Unauthorized`.
- Admin-only endpoints additionally check admin role. Non-admin → `403 Forbidden`.
- Special cases noted explicitly per endpoint.

### Standard Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": { "field": "title", "issue": "exceeds max length" }
  }
}
```

### Common Error Codes
| Status | Code | Meaning |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Request body or params invalid |
| 401 | `UNAUTHENTICATED` | Missing/invalid session |
| 403 | `FORBIDDEN` | Authenticated but not authorized |
| 404 | `NOT_FOUND` | Resource does not exist or not visible to caller |
| 409 | `CONFLICT` | State conflict (e.g., duplicate, already accepted) |
| 422 | `UNPROCESSABLE` | Business rule violation (e.g., max requests reached) |
| 429 | `RATE_LIMITED` | Too many requests; `Retry-After` header set |
| 500 | `INTERNAL_ERROR` | Generic server error |
| 503 | `UNAVAILABLE` | Dependency unavailable (DB, Redis) |

### Pagination
List endpoints accept `cursor` and `limit` query params.
```
GET /questions?cursor=abc123&limit=20
```
Response includes:
```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "def456",
    "hasMore": true
  }
}
```

### Validation
Request bodies validated with Zod. All string fields trimmed; empty strings rejected unless explicitly optional.

---

## 1. Authentication

### POST /api/v1/auth/signup/student
Public. Create a student account using `@rajagiri.edu.in` email.

**Request:**
```json
{
  "email": "alice@rajagiri.edu.in",
  "password": "min8chars+letters+numbers",
  "name": "Alice Roy",
  "branch": "CSE",
  "currentSemester": 3,
  "batchYear": 2027,
  "isLateralEntry": false,
  "acceptedPrivacyPolicy": true
}
```

**Success (201):**
```json
{
  "userId": "cuid...",
  "verificationStatus": "VERIFIED",
  "message": "Verification email sent. Click the link to activate your account."
}
```

**Errors:**
- `409 EMAIL_TAKEN` — email already registered
- `400 INVALID_DOMAIN` — email not `@rajagiri.edu.in`
- `400 PRIVACY_NOT_ACCEPTED` — required acceptance missing

### POST /api/v1/auth/signup/faculty
Public. Same shape, requires `@rajagiritech.edu.in` email and `department` field instead of `branch`/`currentSemester`/`batchYear`.

### POST /api/v1/auth/signup/alumnus
Public. Personal email allowed. Verification status is `PENDING` until admin approval.

**Request:**
```json
{
  "email": "alice@gmail.com",
  "password": "...",
  "name": "Alice Roy",
  "branch": "CSE",
  "batchYear": 2018,
  "currentRole": "Senior Engineer",
  "currentCompany": "Acme Corp",
  "linkedinUrl": "https://linkedin.com/in/alice-roy",
  "acceptedPrivacyPolicy": true
}
```

**Success (201):**
```json
{
  "userId": "cuid...",
  "verificationStatus": "PENDING",
  "message": "Account created. Verification typically takes up to 3 days."
}
```

### POST /api/v1/auth/verify-email
Public. Activate account using token from email.

**Request:**
```json
{ "token": "..." }
```

**Success (200):**
```json
{ "verified": true }
```

**Errors:**
- `400 TOKEN_INVALID` / `400 TOKEN_EXPIRED`

### POST /api/v1/auth/login
Public. Authenticate with email + password. Sets session cookie.

**Request:**
```json
{ "email": "...", "password": "..." }
```

**Success (200):** session cookie set; body:
```json
{
  "user": {
    "id": "cuid",
    "name": "...",
    "persona": "STUDENT",
    "verificationStatus": "VERIFIED",
    "mfaRequired": false
  }
}
```

**Errors:**
- `401 INVALID_CREDENTIALS` — generic, do not leak email existence
- `403 ACCOUNT_LOCKED` — too many failed attempts
- `403 ACCOUNT_PENDING` — alumnus pending verification (limited platform access)
- `403 ACCOUNT_SUSPENDED` — current penalty active; body includes `expiresAt`
- `403 ACCOUNT_BANNED`
- `200 MFA_REQUIRED` — when MFA enabled; body includes `mfaToken`; client follows up with `/auth/login/mfa`

### POST /api/v1/auth/login/mfa
Public. Complete MFA challenge.

**Request:**
```json
{ "mfaToken": "...", "code": "123456" }
```

**Success (200):** session cookie set; same shape as `/login`.

### POST /api/v1/auth/sso/google
Public. OAuth callback handler. Receives `code` from Google, exchanges for token, creates or signs in user.

### POST /api/v1/auth/forgot-password
Public.

**Request:** `{ "email": "..." }`

**Success (200):** Always returns `{ "ok": true }` (no email enumeration).

### POST /api/v1/auth/reset-password
Public. Reset using token from email.

**Request:** `{ "token": "...", "newPassword": "..." }`

### POST /api/v1/auth/logout
Authenticated. Invalidates session.

### GET /api/v1/auth/session
Authenticated. Returns current user.

```json
{
  "user": {
    "id": "...",
    "email": "...",
    "name": "...",
    "persona": "STUDENT",
    "branch": "CSE",
    "semester": 3,
    "verificationStatus": "VERIFIED",
    "isAdmin": false,
    "repScore": 145,
    "badges": [...]
  }
}
```

### POST /api/v1/auth/mfa/enable
Authenticated. Generate TOTP secret. Returns QR code data and recovery codes.

### POST /api/v1/auth/mfa/verify
Authenticated. Confirm TOTP setup with code.

### POST /api/v1/auth/mfa/disable
Authenticated. Requires current password.

---

## 2. Users & Profiles

### GET /api/v1/users/me
Authenticated. Returns own profile (full).

### PATCH /api/v1/users/me
Authenticated. Update editable profile fields.

**Request:** any subset of:
```json
{
  "name": "...",
  "bio": "...",
  "expertiseTagIds": ["tag1", "tag2"],
  "currentRole": "...",      // alumnus only
  "currentCompany": "...",   // alumnus only
  "linkedinUrl": "...",      // alumnus only
  "hideActivity": false,
  "noConnectionRequests": false
}
```

### GET /api/v1/users/:id
Authenticated. Public profile of another user. Respects visibility settings.

**Response:**
```json
{
  "id": "...",
  "name": "...",
  "persona": "ALUMNUS",
  "branch": "CSE",
  "batchYear": 2018,
  "currentRole": "...",
  "currentCompany": "...",
  "bio": "...",
  "expertiseTags": [...],
  "repScore": 1450,
  "badges": [...],
  "stats": {
    "questionsAsked": 12,
    "answersGiven": 87,
    "answersAccepted": 53,
    "postsShared": 4
  },
  "canRequestConnection": true,
  "isFollowing": false,
  "isBlocked": false
}
```

If `hideActivity` is true, `stats` is omitted. If `noConnectionRequests` is true, `canRequestConnection` is false.

### GET /api/v1/users/:id/activity
Authenticated. List of user's public content (questions, answers, posts, resources).

### POST /api/v1/users/:id/follow
Authenticated.

### DELETE /api/v1/users/:id/follow
Authenticated.

### POST /api/v1/users/:id/block
Authenticated. Cannot block self.

### DELETE /api/v1/users/:id/block
Authenticated.

---

## 3. Questions

### POST /api/v1/questions
Authenticated.

**Request:**
```json
{
  "title": "What's the best way to approach DSA prep?",
  "body": "I'm in 4th sem and ...",
  "tagIds": ["tag1", "tag2"],
  "anonymous": false,
  "visibilityScope": "INSTITUTION"
}
```

**Success (201):**
```json
{ "id": "qcuid", "title": "...", "createdAt": "..." }
```

**Errors:**
- `422 RATE_LIMIT_HOURLY` — hit hourly post cap

### GET /api/v1/questions
Authenticated. List questions with filters.

**Query params:**
- `tag` — tag ID
- `branch` — filter by author branch
- `unanswered` — boolean
- `cursor`, `limit`
- `sort` — `recent` | `top` | `unanswered` (default: `recent`)

### GET /api/v1/questions/:id
Authenticated. Single question with all answers, votes, comments.

Includes computed field `viewerCanAnswer` based on Dynamic Seniority Engine.

### PATCH /api/v1/questions/:id
Authenticated. Author only.

### DELETE /api/v1/questions/:id
Authenticated. Author only when no answers; admin always.

### POST /api/v1/questions/:id/duplicates
Authenticated. Duplicate detection on partial title (called during typing).

**Request:** `{ "title": "DSA prep" }`
**Response:** up to 3 similar questions with id, title, answer count.

### POST /api/v1/questions/:id/archive
Admin only.

---

## 4. Answers

### POST /api/v1/questions/:questionId/answers
Authenticated. Subject to Dynamic Seniority Engine.

**Request:** `{ "body": "..." }`

**Errors:**
- `403 NOT_ELIGIBLE` — fails seniority check; response includes reason
- `409 ALREADY_ANSWERED` — user already has an answer on this question

### PATCH /api/v1/answers/:id
Authenticated. Author only.

### DELETE /api/v1/answers/:id
Authenticated. Author only when not accepted; admin always.

### POST /api/v1/answers/:id/accept
Authenticated. Question author only.

### POST /api/v1/answers/:id/unaccept
Authenticated. Question author only.

### POST /api/v1/answers/:id/endorse
Authenticated. Faculty only.

### DELETE /api/v1/answers/:id/endorse
Authenticated. Faculty only (their own endorsement).

---

## 5. Comments

### POST /api/v1/comments
Authenticated.

**Request:**
```json
{
  "parentType": "QUESTION", // or ANSWER, POST, RESOURCE
  "parentId": "...",
  "body": "..."
}
```

### DELETE /api/v1/comments/:id
Authenticated. Author or admin.

---

## 6. Votes

### POST /api/v1/votes
Authenticated.

**Request:**
```json
{
  "targetType": "QUESTION",
  "targetId": "...",
  "direction": 1 // or -1
}
```

If existing vote in opposite direction, switches. If same direction, removes (toggle off).

**Errors:**
- `422 SELF_VOTE` — voting on own content
- `422 DOWNVOTE_NOT_ALLOWED` — target type doesn't allow downvotes

---

## 7. Posts (Experience Feed)

### POST /api/v1/posts
Authenticated.

**Request:**
```json
{
  "title": "...",
  "body": "...",
  "category": "INTERNSHIP",
  "tagIds": ["..."],
  "expiryDate": null  // only meaningful for FACULTY_ANNOUNCEMENT
}
```

Category `FACULTY_ANNOUNCEMENT` requires faculty persona.

### GET /api/v1/posts
Authenticated. Filtered feed.

**Query params:**
- `category`, `tag`, `branch`, `following` (boolean: only from followed users/tags)
- `cursor`, `limit`
- Default sort: hybrid pinned-then-chronological-with-freshness-boost

### GET /api/v1/posts/:id
### PATCH /api/v1/posts/:id (author only)
### DELETE /api/v1/posts/:id (author or admin)

### POST /api/v1/posts/:id/bookmark
### DELETE /api/v1/posts/:id/bookmark

---

## 8. Resources

### POST /api/v1/resources
Authenticated.

**Request:**
```json
{
  "url": "https://...",
  "title": "...",        // optional; server fetches OG if missing
  "description": "...",
  "category": "TOOLS",
  "tagIds": ["..."]
}
```

Server attempts OG fetch (with SSRF protection) for missing title.

### GET /api/v1/resources
Authenticated.

**Query params:**
- `tab` — `library` (default) | `pending`
- `category`, `tag`, `cursor`, `limit`
- `sort` — `recent` | `popular` (default: `popular` for library, `recent` for pending)

Search via `q` param applies only to `library` tab.

### GET /api/v1/resources/:id
### PATCH /api/v1/resources/:id (submitter; URL changes require admin)
### DELETE /api/v1/resources/:id (submitter; tombstone if has engagement)

### POST /api/v1/resources/:id/endorse
Authenticated. Faculty only.

### DELETE /api/v1/resources/:id/endorse

### POST /api/v1/resources/:id/report-broken
Authenticated.

---

## 9. Connections & DM

### POST /api/v1/connections
Authenticated.

**Request:**
```json
{
  "recipientId": "...",
  "note": "Hi Alice, I'm a 3rd-sem CSE student looking to learn about cloud careers...",
  "topic": "Cloud career path"
}
```

**Errors:**
- `422 RECIPIENT_BLOCKED_REQUESTS` — recipient toggled `noConnectionRequests`
- `422 OUTSTANDING_LIMIT` — sender has 5 outstanding requests
- `403 BLOCKED` — sender or recipient is blocked
- `409 ALREADY_CONNECTED`
- `409 EXISTING_PENDING`

### GET /api/v1/connections
Authenticated. List own connection requests (sent and received) and active connections.

**Query params:** `direction` (`sent`|`received`), `status`

### POST /api/v1/connections/:id/accept
Authenticated. Recipient only.

### POST /api/v1/connections/:id/decline
Authenticated. Recipient only.

**Request:** `{ "reason": "..." }` (optional) or `{ "silent": true }`

### POST /api/v1/connections/:id/cancel
Authenticated. Sender only.

### GET /api/v1/threads
Authenticated. List active DM threads.

### GET /api/v1/threads/:id/messages
Authenticated. Paginated messages in a thread.

### POST /api/v1/threads/:id/messages
Authenticated.

**Request:** `{ "body": "..." }`

(Also delivered via Socket.IO; HTTP fallback for unreliable connections.)

### POST /api/v1/threads/:id/disconnect
Authenticated. Either party.

---

## 10. Search

### GET /api/v1/search
Authenticated.

**Query params:**
- `q` — query string (required)
- `type` — `all` | `questions` | `posts` | `resources` | `people` | `tags` (default `all`)
- `branch`, `tag`, `persona`, `dateRange`
- `sort` — `relevance` | `recent` | `top`
- `cursor`, `limit`

**Response:**
```json
{
  "results": {
    "questions": [...],
    "posts": [...],
    "resources": [...],
    "people": [...],
    "tags": [...]
  },
  "pagination": {...}
}
```

For `type=all`, top-N from each category. For specific `type`, paginated full list.

### GET /api/v1/search/typeahead
Authenticated. Lightweight prefix search for tags and people.

**Query:** `q` (min 2 chars), `type` (`tags`|`people`|`all`)

---

## 11. Notifications

### GET /api/v1/notifications
Authenticated.

**Query params:** `unreadOnly` (boolean), `cursor`, `limit`

### POST /api/v1/notifications/:id/read
Authenticated.

### POST /api/v1/notifications/read-all
Authenticated.

### GET /api/v1/notifications/preferences
Authenticated. Returns matrix of category × channel.

### PATCH /api/v1/notifications/preferences
Authenticated.

**Request:**
```json
{
  "preferences": [
    { "category": "ANSWER_RECEIVED", "channel": "EMAIL", "enabled": true },
    ...
  ]
}
```

### POST /api/v1/notifications/push/subscribe
Authenticated. Register push subscription.

**Request:** Web Push API subscription object.

### DELETE /api/v1/notifications/push/subscribe

---

## 12. Reports

### POST /api/v1/reports
Authenticated.

**Request:**
```json
{
  "targetType": "QUESTION",
  "targetId": "...",
  "reason": "HARASSMENT",
  "freeText": "..." // required if reason='OTHER'
}
```

Cannot report own content.

---

## 13. Tags

### GET /api/v1/tags
Authenticated. Full list.

### GET /api/v1/tags/:id
Authenticated.

### POST /api/v1/tag-suggestions
Authenticated.

**Request:** `{ "proposedName": "...", "context": "..." }`

---

## 14. Lifecycle

### POST /api/v1/lifecycle/confirm-graduation
Authenticated. Triggered by user from prompt.

**Request:**
```json
{
  "currentRole": "...",
  "currentCompany": "...",
  "linkedinUrl": "..."
}
```

Persona transitions to ALUMNUS; Class of [Year] badge auto-assigned.

---

## 15. Privacy & Data

### POST /api/v1/privacy/data-export
Authenticated. Queues async export.

**Response (202):** `{ "exportId": "...", "estimatedReadyAt": "..." }`

### GET /api/v1/privacy/data-export/:id
Authenticated. Status check; returns signed S3 URL if ready.

### POST /api/v1/privacy/account-delete
Authenticated.

**Request:**
```json
{
  "mode": "ANONYMIZE", // or HARD_DELETE
  "confirmation": "DELETE"
}
```

Initiates 14-day grace period. Account immediately hidden.

### POST /api/v1/privacy/account-recover
Authenticated. Available during grace period via standard login.

### GET /api/v1/privacy/account-activity
Authenticated. Returns admin actions on this user's account.

---

## 16. Admin Endpoints

All require admin role.

### GET /api/v1/admin/verifications/pending
Filter by branch, batchYear, registration date range.

### POST /api/v1/admin/verifications/:userId/approve
**Request:** `{ "internalNote": "..." }` (optional)

### POST /api/v1/admin/verifications/:userId/reject
**Request:** `{ "reason": "...", "internalNote": "..." }`

### GET /api/v1/admin/reports
Filter by status, severity, target type, age.

### POST /api/v1/admin/reports/:id/resolve
**Request:**
```json
{
  "action": "CONTENT_REMOVED", // see ReportAction enum
  "resolutionNotes": "...",
  "userPenaltyType": null // or PENALTY_TYPE if user action taken
}
```

### POST /api/v1/admin/users/:id/suspend
**Request:** `{ "duration": "SUSPENSION_24H", "reason": "..." }`

### POST /api/v1/admin/users/:id/ban
**Request:** `{ "reason": "..." }`

### POST /api/v1/admin/users/:id/unban
### POST /api/v1/admin/users/:id/persona
**Request:** `{ "newPersona": "FORMER_STUDENT", "reason": "..." }`

### POST /api/v1/admin/users/:id/flag-frivolous-reporter
### DELETE /api/v1/admin/users/:id/flag-frivolous-reporter

### POST /api/v1/admin/admins
**Request:** `{ "userId": "..." }`

### DELETE /api/v1/admin/admins/:userId
Cannot remove the last admin.

### GET /api/v1/admin/audit-log
Filter by actor, target, action, date range.

### POST /api/v1/admin/tags
**Request:** `{ "name": "...", "description": "..." }`

### PATCH /api/v1/admin/tags/:id
### POST /api/v1/admin/tags/:id/merge-into
**Request:** `{ "canonicalTagId": "..." }`

### POST /api/v1/admin/tag-suggestions/:id/approve
**Request:** `{ "canonicalName": "..." }` (admin can adjust the name)

### POST /api/v1/admin/tag-suggestions/:id/reject

### POST /api/v1/admin/questions/:id/archive
### POST /api/v1/admin/posts/:id/delete
### POST /api/v1/admin/answers/:id/delete
### POST /api/v1/admin/resources/:id/delete

### GET /api/v1/admin/calendar
### POST /api/v1/admin/calendar
**Request:** `{ "semesterLabel": "Spring 2026", "startsAt": "...", "endsAt": "...", "active": true }`

---

## 17. Health & Operations

### GET /api/v1/health
Public. Liveness probe.
**Response:** `{ "status": "ok" }`

### GET /api/v1/ready
Public. Readiness probe (checks DB, Redis).
**Response:** `{ "status": "ok", "checks": { "db": "ok", "redis": "ok" } }`

---

## 18. WebSocket Events (Socket.IO)

Connection requires valid session cookie. Server validates on handshake.

### Client → Server Events

#### `join:thread`
Join a DM thread room.
```json
{ "threadId": "..." }
```

#### `message:send`
Send a DM message (also persisted via REST).
```json
{ "threadId": "...", "body": "..." }
```

#### `message:typing`
Indicate typing in a thread.
```json
{ "threadId": "..." }
```

### Server → Client Events

#### `message:new`
New message in a thread the user is in.

#### `notification:new`
New notification for the connected user.

#### `connection:request`
New connection request received.

---

## 19. Rate Limits

Enforced at gateway with Redis-backed counters. Headers returned: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

| Endpoint Group | Limit |
|---|---|
| Auth (login, signup, forgot) | 10 / hour / IP |
| Content creation (Q, A, post, resource) | 10 / hour / user |
| Comments | 30 / hour / user |
| Votes | 200 / hour / user |
| Connection requests | 10 / day / user |
| Search | 60 / minute / user |
| Generic authenticated | 1000 / hour / user |

Exceeding limit returns `429` with `Retry-After` header.

---

## 20. CORS Policy

API allows credentialed requests only from configured frontend origin (production domain). Local development allows `localhost:3000`.
