# Ascend — Async Architecture (Jobs + Real-time)

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Audience | Engineering team |

This document covers two related concerns: **background job processing** (BullMQ on Redis) and **real-time event delivery** (Socket.IO with Redis adapter).

---

## Part A — Background Jobs (BullMQ)

## 1. Why BullMQ

We need durable, scheduled, retryable async work. Options considered:
- **In-process `setInterval`:** Loses jobs on restart; not viable.
- **AWS SQS + scheduler:** Adds AWS lock-in; needs separate scheduler service.
- **Plain Postgres-backed queue (e.g., pg-boss):** Workable but tying jobs to DB couples failures.
- **BullMQ:** Industry standard for Node, Redis-backed, mature, supports cron and priorities, has admin UI (Bull Board).

Decision: **BullMQ on the same Redis cluster as cache/sessions.**

---

## 2. Queue Catalog

We define explicit queues per concern. Mixing unrelated jobs in one queue makes prioritization and observability worse.

| Queue Name | Purpose | Concurrency | Priority |
|---|---|---|---|
| `notifications` | Email/push delivery for user notifications | 10 | High |
| `digest` | Weekly digest composition | 2 | Low |
| `rep-decay` | Daily reputation decay batch | 1 | Low |
| `link-check` | Monthly link-rot scan for resources | 1 | Low |
| `data-export` | User-requested data exports | 2 | Medium |
| `account-deletion` | 14-day finalization of account deletions | 1 | Medium |
| `og-fetch` | Open Graph metadata fetcher (with SSRF guards) | 5 | Medium |
| `badge-eval` | Re-evaluate badges after relevant events | 5 | Medium |
| `audit-archive` | Daily audit log export to S3 | 1 | Low |

---

## 3. Job Definitions

### 3.1 `notifications` queue

**Purpose:** Deliver email and push notifications. In-app notifications are written synchronously during the originating action; only out-of-band channels (email, push) go through this queue.

**Job types:**
- `email-notification` — single notification email
- `push-notification` — single push notification

**Payload:**
```typescript
{
  userId: string;
  notificationId: string; // links to Notification table row
  channel: 'EMAIL' | 'PUSH';
}
```

**Worker logic:**
1. Load Notification + User.
2. Check user's NotificationPreference for this category × channel.
3. If disabled, mark notification `deliveredAt = now()`, exit.
4. If enabled, render template (email) or build push payload.
5. Send via SES (email) or web-push (push).
6. On success: mark `deliveredAt`.
7. On failure: BullMQ retry with exponential backoff (1m, 5m, 30m); after 3 failures, mark `deliveredAt` with failure flag, alert admin if rate exceeds threshold.

**Aggregation:**
For high-frequency events (upvotes), the application enqueues to a dedupe queue (`notifications-dedupe`) with a 1-hour debounce window. After window closes, a single aggregated notification is dispatched.

### 3.2 `digest` queue

**Purpose:** Weekly digest emails.

**Schedule:** Cron `0 9 * * 0` (Sunday 9 AM IST). BullMQ scheduler enqueues a single `weekly-digest-batch` job.

**Payload:** none

**Worker logic:**
1. Fetch all users with `digestEnabled = true` (via NotificationPreference for category=DIGEST).
2. For each user (batched, 100 at a time):
   a. Compute digest content per spec (top questions, followed posts, new resources, weekly stats, unanswered in dept).
   b. Render email template.
   c. Enqueue `email-notification` job for the digest.
3. Log progress; emit metrics.

**Idempotency:** Re-running the job in the same week should not double-send. Use a Redis key `digest:sent:{userId}:{week}` with TTL 8 days as a guard.

### 3.3 `rep-decay` queue

**Purpose:** Apply 10%/year decay to ReputationEvents older than 18 months and recompute User.repScore.

**Schedule:** Cron `0 3 * * *` (3 AM IST daily).

**Worker logic:**
1. Find users with at least one ReputationEvent older than 18 months.
2. For each user (batched):
   a. Recompute decay_factor for events older than 18 months: `decay_factor = max(0.1, 1 - 0.1 * yearsOver18Months)`
   b. Update `effective_value = delta * decay_factor`
   c. Recompute `User.repScore = SUM(effective_value)`
   d. Enqueue `badge-eval` job for the user (badges may need revoke/re-grant).

**Idempotency:** Pure function on data; running twice produces same result.

**Performance:** For 10K users with ~100 events each, this should complete in under 5 minutes. If approach takes longer in practice, partition the work across multiple sub-jobs.

### 3.4 `link-check` queue

**Purpose:** Monthly check of all Library resources for 404s.

**Schedule:** Cron `0 4 1 * *` (4 AM IST on 1st of month).

**Worker logic:**
1. Fetch all `Resource WHERE status = LIBRARY`.
2. For each (with concurrency limit 5):
   a. HTTP HEAD request with 10s timeout.
   b. Update `Resource.linkStatus` and `lastLinkCheckAt`.
   c. If status is BROKEN, enqueue admin notification (creates an admin queue item visible on dashboard).

**Same SSRF protections as OG fetcher.**

### 3.5 `data-export` queue

**Purpose:** Generate user data export files.

**Triggered by:** User clicking "Export my data" → enqueues a job.

**Payload:**
```typescript
{
  userId: string;
  exportId: string;
  mode: 'JSON' | 'JSON_AND_HTML';
}
```

**Worker logic:**
1. Query all user-owned data: questions, answers, posts, resources, comments, votes, badges, follows, bookmarks, connections, messages, notifications.
2. Serialize to JSON.
3. (If JSON_AND_HTML) Render to readable HTML summary.
4. Zip into `export-{userId}-{timestamp}.zip`.
5. Upload to S3 with 7-day signed URL.
6. Email user with the download link.
7. Update DataExport row in DB with status COMPLETED and S3 URL.

**Cleanup:** S3 lifecycle policy auto-deletes after 7 days.

### 3.6 `account-deletion` queue

**Purpose:** Finalize account deletions after 14-day grace period.

**Schedule:** Cron `0 4 * * *` (4 AM IST daily). Also can be triggered manually.

**Worker logic:**
1. Find users with `deletedAt IS NOT NULL AND deletedAt < now() - 14 days AND hardDeletedAt IS NULL`.
2. For each:
   a. If user opted for HARD_DELETE: cascade-delete all owned content; insert tombstones for content with engagement.
   b. If user opted for ANONYMIZE (default): replace personal fields (name → "Deleted User", email → null, bio → null, etc.); preserve content with attribution to "Deleted User".
   c. Delete sessions, push subscriptions, notification preferences.
   d. Set `User.hardDeletedAt = now()`.
3. Schedule personal data purge after 30 additional days (sessions, audit log entries about this user beyond the legal 1-year retention floor).

### 3.7 `og-fetch` queue

**Purpose:** Fetch Open Graph metadata for newly submitted Resource URLs.

**Triggered by:** Resource creation when title not provided.

**Worker logic:**
1. Validate URL (HTTPS only).
2. Resolve hostname; reject if private IP, metadata IP, etc. (per ADR-013).
3. HTTP GET with 5s timeout, 5MB max response, no cookies/auth headers.
4. Parse HTML for OG tags (`og:title`, `og:description`).
5. Update Resource with fetched values.
6. On any failure (DNS, timeout, parse error): leave Resource with empty title/description; user can manually edit.

### 3.8 `badge-eval` queue

**Purpose:** Re-evaluate a user's badge eligibility after a triggering event.

**Triggered by:** ReputationEvent creation, content removal, content acceptance, etc.

**Payload:** `{ userId: string }`

**Worker logic:**
1. Compute current badge eligibility based on user's current state.
2. Compare against existing badges.
3. Insert new Badge rows for newly eligible types.
4. Mark Badge.revokedAt for badges no longer met.
5. If new badge earned, enqueue notification.

### 3.9 `audit-archive` queue

**Purpose:** Daily archive of audit log entries to S3 for long-term retention.

**Schedule:** Cron `0 5 * * *` (5 AM IST).

**Worker logic:**
1. Export AuditLogEntry rows from yesterday.
2. Compress, upload to S3 with date-prefixed key.
3. After successful upload, optional: delete entries older than 1 year from Postgres (keeps DB lean while preserving retention).

---

## 4. Job Reliability

### 4.1 Retry Policy
Default: exponential backoff with jitter, max 3 attempts:
- Attempt 1: immediate
- Attempt 2: 1 minute
- Attempt 3: 5 minutes
- Failure: log, alert if pattern, dead-letter queue

Some jobs have stricter retry policies (e.g., `notifications` retries up to 3x at 1m/5m/30m).

### 4.2 Dead Letter Queue
Failed jobs after final retry are moved to `{queue-name}-dlq`. Bull Board shows DLQ; admins (engineering) review weekly.

### 4.3 Idempotency
Every job must be idempotent. Use natural keys for deduplication:
- `digest:sent:{userId}:{week}`
- `notification:sent:{notificationId}`
- `link-check:{resourceId}:{month}`

### 4.4 Visibility
- **Bull Board** mounted at `/admin/queues` (admin-only access).
- Metrics: jobs processed, jobs failed, queue depth, job duration percentiles.
- Alerts: queue depth > threshold for > 10 minutes; DLQ count > 0 for any queue.

---

## 5. Worker Process Architecture

```
apps/worker/
├── src/
│   ├── index.ts              # Entry point
│   ├── queues/
│   │   ├── notifications.ts
│   │   ├── digest.ts
│   │   ├── rep-decay.ts
│   │   ├── link-check.ts
│   │   ├── data-export.ts
│   │   ├── account-deletion.ts
│   │   ├── og-fetch.ts
│   │   ├── badge-eval.ts
│   │   └── audit-archive.ts
│   ├── jobs/
│   │   ├── send-email.ts
│   │   ├── send-push.ts
│   │   ├── compute-digest.ts
│   │   └── ...
│   ├── shared/
│   │   ├── prisma.ts
│   │   ├── redis.ts
│   │   └── ses.ts
│   └── scheduler.ts          # Registers cron jobs
├── package.json
└── tsconfig.json
```

**Entry point pseudo:**
```typescript
import { Worker, QueueScheduler } from 'bullmq';
import { redisConnection } from './shared/redis';

const queues = [
  'notifications',
  'digest',
  'rep-decay',
  // ...
];

queues.forEach(name => {
  new QueueScheduler(name, { connection: redisConnection });
  const concurrency = getConcurrencyForQueue(name);
  new Worker(name, processorFor(name), {
    connection: redisConnection,
    concurrency,
  });
});

import './scheduler'; // registers cron schedules

console.log('Workers running');
```

### 5.1 Process Isolation

Workers run on a separate EC2 instance from the API. This isolates:
- CPU-intensive work (digest rendering)
- Untrusted network calls (OG fetcher) — runs with restricted IAM (no metadata access)
- Long-running jobs that could affect API responsiveness

### 5.2 Graceful Shutdown

On SIGTERM:
1. Worker stops accepting new jobs
2. Currently-running jobs complete (with timeout)
3. Process exits

This is critical for zero-downtime deploys.

---

## Part B — Real-time Layer (Socket.IO)

## 6. Why Socket.IO

- Built-in reconnection, fallback to long-polling on hostile networks.
- Room/namespace abstraction matches DM threads and per-user notification streams.
- Redis adapter allows multiple API instances to share connection state.
- Mature client library; handles browser quirks.

---

## 7. Connection Lifecycle

### 7.1 Authentication

Socket.IO server validates session on handshake:

```typescript
io.use(async (socket, next) => {
  const cookies = parseCookies(socket.handshake.headers.cookie);
  const sessionId = cookies['session'];
  if (!sessionId) return next(new Error('UNAUTHENTICATED'));

  const user = await loadUserFromSession(sessionId);
  if (!user) return next(new Error('UNAUTHENTICATED'));

  socket.data.user = user;
  next();
});
```

**On verification failure:** disconnect immediately.

### 7.2 Connection Establishment

```typescript
io.on('connection', (socket) => {
  const userId = socket.data.user.id;

  // Auto-join personal notification room
  socket.join(`user:${userId}`);

  socket.on('join:thread', async ({ threadId }) => {
    // Validate user is in the thread
    const thread = await prisma.dMThread.findUnique({ where: { id: threadId } });
    if (!thread) return socket.emit('error', { code: 'THREAD_NOT_FOUND' });
    if (thread.userAId !== userId && thread.userBId !== userId) {
      return socket.emit('error', { code: 'FORBIDDEN' });
    }
    socket.join(`thread:${threadId}`);
  });

  socket.on('disconnect', () => {
    // Cleanup if needed; rooms cleaned automatically
  });
});
```

---

## 8. Room Model

| Room | Joined By | Used For |
|---|---|---|
| `user:{userId}` | The user themselves | New notifications, badge earned, admin actions on user |
| `thread:{threadId}` | Both parties of an active DM thread | New messages, typing indicators |
| `admin` | All admins | Real-time report queue updates |

Server-side helpers emit events into rooms:

```typescript
// On new notification
io.to(`user:${userId}`).emit('notification:new', notification);

// On new DM message
io.to(`thread:${threadId}`).emit('message:new', message);

// On typing
socket.to(`thread:${threadId}`).emit('message:typing', { userId });
```

---

## 9. Event Catalog

### Server → Client

| Event | Payload | Notes |
|---|---|---|
| `notification:new` | Notification object | Triggers in-app badge update |
| `message:new` | Message object | Real-time DM delivery |
| `message:typing` | `{ userId, threadId }` | Typing indicator |
| `connection:request:new` | ConnectionRequest object | Live notification |
| `report:new` | (admin room only) Report object | Admin dashboard live update |
| `error` | `{ code, message }` | For protocol errors |

### Client → Server

| Event | Payload | Notes |
|---|---|---|
| `join:thread` | `{ threadId }` | Join a thread room |
| `leave:thread` | `{ threadId }` | Leave |
| `message:send` | `{ threadId, body }` | Send DM (also persisted via REST) |
| `message:typing` | `{ threadId }` | Send typing indicator |
| `message:read` | `{ threadId, messageId }` | Mark message read |

---

## 10. Scaling Real-time

### 10.1 Single-instance MVP

At MVP, one API instance with ~3K concurrent WebSocket connections is well within Node's capabilities. Memory is the main concern (~10KB per connection).

### 10.2 Horizontal Scaling

When adding a second API instance:

```typescript
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();
await Promise.all([pubClient.connect(), subClient.connect()]);

io.adapter(createAdapter(pubClient, subClient));
```

The Redis adapter forwards events between instances, so emitting `io.to(room).emit(...)` reaches all connected clients regardless of which instance they're connected to.

**Sticky sessions:** Required at the load balancer for Socket.IO's polling fallback to work correctly. Configure ALB with `stickiness.enabled = true`, cookie type `lb_cookie`. (Long-polling sends a series of requests that must hit the same instance.)

### 10.3 Connection Limits

- Max 1 connection per browser tab; 3-5 tabs per user is realistic, so plan for ~5x peak users in connection count.
- Apply rate limit on connect: max 20 connections per minute per IP (mitigates abuse).

---

## 11. Failure Modes

### 11.1 Redis Down (Adapter)
- Cross-instance event delivery breaks; users connected to instance A don't see events from instance B.
- Sessions also affected (can't authenticate).
- Application should not crash; log error, attempt reconnection.

### 11.2 Client Disconnect
- Socket.IO auto-reconnects with exponential backoff.
- On reconnect, client re-joins required rooms.
- No message backlog replay at MVP — rely on REST GET to refetch state on reconnection.

### 11.3 Message Delivery Guarantee
**Not guaranteed at-least-once.** A message could be lost if:
- Sent during disconnect and not yet persisted to DB (mitigated: HTTP POST is the source of truth, WS is eager delivery)
- Server crashes between persist and emit

For DMs, the persist-then-emit pattern means worst case is "message persisted but UI not updated until refresh." Acceptable.

---

## 12. Real-time vs REST: When to Use Which

**Always REST for:**
- Mutations (create, update, delete) — REST is canonical persistence
- Reads on page load
- Anything the app needs in URL-shareable state

**Real-time supplement for:**
- Notification badge increments
- DM message delivery while page is open
- Typing indicators
- Live updates to admin dashboard

**Pattern:** REST persists; real-time notifies. Never use real-time as the only persistence path.

---

## 13. Open Decisions for Engineering

- **Read receipts:** WebSocket emits read events; should they be user-toggleable? Not specified in PRD.
- **Online presence:** Should we show "online now" indicators? Adds privacy concerns; defer.
- **Backlog replay on reconnect:** Could buffer recent events in Redis with replay-on-reconnect; defer to V1+.
- **Bull Board auth:** Mount with admin auth check — confirm route placement.
- **Worker autoscaling:** Single worker instance is fine at MVP; revisit if queue depth grows.
