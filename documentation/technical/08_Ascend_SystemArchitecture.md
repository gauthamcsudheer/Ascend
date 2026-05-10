# Ascend — System Architecture & Deployment Topology

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Audience | Engineering team |

---

## 1. High-Level Architecture

```
                          ┌─────────────────────┐
                          │    CloudFront CDN   │  (optional, static assets)
                          └──────────┬──────────┘
                                     │
                          ┌──────────▼──────────┐
                          │ Application Load    │
                          │ Balancer (HTTPS)    │
                          └──┬──────────────┬───┘
                             │              │
                ┌────────────┘              └────────────┐
                │                                        │
       ┌────────▼─────────┐                  ┌──────────▼─────────┐
       │ EC2 Instance #1  │                  │ EC2 Instance #2    │
       │  ┌─────────────┐ │                  │  ┌──────────────┐  │
       │  │ Next.js     │ │                  │  │ Next.js      │  │
       │  │ (web)       │ │                  │  │ (web)        │  │
       │  └─────────────┘ │                  │  └──────────────┘  │
       │  ┌─────────────┐ │                  │  ┌──────────────┐  │
       │  │ Express API │ │                  │  │ Express API  │  │
       │  │ + Socket.IO │ │                  │  │ + Socket.IO  │  │
       │  └─────────────┘ │                  │  └──────────────┘  │
       └────────┬─────────┘                  └──────────┬─────────┘
                │                                        │
                └────────────────┬───────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
   ┌────▼─────┐         ┌───────▼────────┐       ┌──────▼────────┐
   │ RDS      │         │ ElastiCache    │       │ EC2 Worker    │
   │ Postgres │         │ Redis          │       │ (BullMQ)      │
   │ (Multi-  │         │ (cache + queue │       │               │
   │  AZ)     │         │  + sessions)   │       │               │
   └──────────┘         └────────────────┘       └───────────────┘
                                 │                        │
                                 └────────────────────────┘
                                        (worker pulls jobs)

                          ┌─────────┐    ┌──────┐    ┌────────┐
                          │ S3      │    │ SES  │    │ Sentry │
                          │ (audit, │    │      │    │ (errors│
                          │ exports)│    │      │    │  only) │
                          └─────────┘    └──────┘    └────────┘
```

---

## 2. Component Inventory

### 2.1 Application Tier

**Next.js Web Application (`apps/web`)**
- Renders UI for all user-facing pages
- Server Components for data-heavy reads (feed, profiles, search)
- Client Components for interactive elements (composer, voting, real-time)
- Talks to Express API for mutations and authenticated reads
- Service worker for PWA offline-read

**Express API (`apps/api`)**
- REST endpoints for all data operations
- WebSocket server (Socket.IO) attached to same HTTP server
- Stateless — all session state in Redis
- Reads/writes Postgres via Prisma
- Enqueues background jobs to Redis (BullMQ)
- Exposes `/health` (liveness) and `/ready` (readiness) endpoints

**Worker Process (`apps/worker`)**
- Long-running BullMQ workers
- Runs on dedicated EC2 instance to isolate failure domains
- Processes: rep decay, link checks, weekly digest, data exports, account deletion finalization, notification dispatching
- Same database access as API (via Prisma)
- No HTTP surface

### 2.2 Data Tier

**RDS PostgreSQL 16**
- Multi-AZ deployment for failover
- Daily automated backups, 30-day retention
- Point-in-time recovery enabled
- Read replicas: not at MVP (consider when read load demands)
- Initial sizing: `db.t3.medium` (2 vCPU, 4GB RAM); scale vertically as needed
- Connection pooling: pgBouncer or Prisma's built-in pool (start with Prisma's pool, add pgBouncer if connection limits hit)

**ElastiCache Redis 7**
- Single-node at MVP; consider replication group when scaling
- Persistence: RDB snapshots + AOF
- Initial sizing: `cache.t3.micro` (1 vCPU, 0.5GB); scale up with usage
- Used for: sessions, rate limiting, cache, BullMQ, Socket.IO adapter

**S3 (Mumbai region)**
- Audit log archives (daily exports)
- Data export artifacts (user-requested data dumps)
- 7-day signed URLs for downloads
- Server-side encryption (SSE-S3) on all buckets
- Versioning enabled on audit log bucket

### 2.3 External Services

**SES (Mumbai region)**
- Transactional email: verification, password reset, notifications, digests
- DKIM, SPF, DMARC configured on sending domain
- Bounce and complaint handling via SNS topic → API webhook

**Sentry**
- Error tracking only; no full APM
- PII scrubbing configured (no email, name, body content in error reports)
- Privacy review required before launch (data residency: Sentry EU or US)

**CloudWatch**
- Application logs (JSON-structured via pino)
- Infrastructure metrics (CPU, memory, RDS metrics)
- Alarms on critical thresholds (see Operations Runbook)

---

## 3. Deployment Topology

### 3.1 Network Layout

```
VPC: ascend-prod (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24) — across 2 AZs
│   ├── ALB
│   └── NAT Gateway
├── Private Subnets (10.0.10.0/24, 10.0.20.0/24) — across 2 AZs
│   ├── EC2 instances (web/api)
│   ├── EC2 worker
│   └── ElastiCache
└── DB Subnets (10.0.100.0/24, 10.0.200.0/24) — across 2 AZs
    └── RDS Postgres (Multi-AZ)
```

### 3.2 Security Groups

- `alb-sg`: inbound 443 from 0.0.0.0/0
- `app-sg`: inbound 3000 (web), 4000 (api) from `alb-sg`
- `worker-sg`: no inbound (outbound only)
- `db-sg`: inbound 5432 from `app-sg`, `worker-sg`
- `cache-sg`: inbound 6379 from `app-sg`, `worker-sg`

### 3.3 IAM Roles

- **EC2 instance role (web/api):** read S3 (limited), send SES, write CloudWatch logs, **no** RDS/Redis credentials (those go via secrets manager)
- **EC2 instance role (worker):** same as above plus write S3
- **No instance metadata access from app code:** worker isolated for OG fetching specifically (ADR-013)

### 3.4 Secrets Management

- AWS Secrets Manager for: DB password, Redis password, JWT signing keys, SES credentials, Google OAuth client secret, VAPID private key, Sentry DSN
- Application reads secrets at boot; not committed to env files in production
- Local development uses `.env` files (gitignored)

---

## 4. Request Flow Examples

### 4.1 User loads the feed (authenticated GET)

```
Browser
  └─ HTTPS GET /feed
      └─ ALB
          └─ Routes to Next.js on EC2
              └─ Next.js Server Component
                  ├─ Reads session cookie
                  ├─ Validates session in Redis (HIT)
                  ├─ Queries Express API: GET /api/feed
                  │   └─ Express middleware: auth, rate limit
                  │       └─ Prisma query to Postgres
                  │           └─ Returns paginated results
                  └─ Renders HTML server-side
              └─ Returns HTML + hydration data
          └─ Browser renders, opens WebSocket for live updates
```

### 4.2 User posts a question (authenticated POST)

```
Browser
  └─ HTTPS POST /api/questions
      ├─ Body: { title, body, tags, anonymous }
      └─ ALB → Express on EC2
          ├─ Auth middleware (session valid)
          ├─ Rate limit middleware (under hourly cap)
          ├─ Validation middleware (Zod schema)
          ├─ Markdown sanitization (markdown-it)
          ├─ Prisma transaction:
          │   ├─ INSERT Question
          │   ├─ INSERT QuestionTag rows
          │   └─ INSERT AuditLogEntry (for admin review later)
          ├─ Enqueue notification job to BullMQ (followers of asker)
          ├─ Emit Socket.IO event to relevant rooms
          └─ Return 201 with question.id
```

### 4.3 Background job runs (rep decay)

```
Cron schedule (BullMQ): daily at 03:00 IST
  └─ BullMQ scheduler enqueues `rep-decay-batch` job
      └─ Worker process picks up job
          ├─ Query: users with rep events older than 18 months
          ├─ For each batch of 100 users:
          │   ├─ Recompute decay_factor for old events
          │   ├─ Recompute User.rep_score
          │   ├─ Re-evaluate badge eligibility
          │   └─ Update Badge revoked_at if no longer eligible
          ├─ Log progress to CloudWatch
          └─ Job completes; metrics emitted
```

### 4.4 DM message delivery

```
User A's browser
  └─ Socket.IO emit `message:send` to thread room
      └─ Express + Socket.IO server
          ├─ Validate sender in thread, thread is active, not blocked
          ├─ Persist Message to Postgres
          ├─ Emit `message:new` to thread room (User B's connections)
          └─ Enqueue notification job (push/email per User B prefs)

User B's browser (if connected)
  └─ Receives `message:new` event
      └─ UI updates immediately

User B (if offline)
  └─ Notification worker delivers via push/email per prefs
```

---

## 5. Scaling Plan

### 5.1 Vertical Scaling (Default)
- Start with `t3.medium` instances; monitor CPU and memory
- Scale RDS instance class as connection count grows

### 5.2 Horizontal Scaling (When Vertical Caps Out)
- Add more EC2 instances behind ALB (already designed for this)
- Socket.IO Redis adapter handles cross-instance event routing
- Sessions in Redis already work across instances
- BullMQ workers can scale by adding worker instances; queues distribute work

### 5.3 Database Scaling Sequence
1. Vertical scale RDS instance class (quick, requires brief downtime in non-Multi-AZ; Multi-AZ minimizes this)
2. Add read replica for read-heavy queries (feed, search)
3. Partition large tables (Notifications, ReputationEvent) when row counts cross 100M

### 5.4 Cache Scaling Sequence
1. Vertical scale ElastiCache node
2. Move to replication group (primary + replica)
3. Move to cluster mode if dataset exceeds single-node memory

---

## 6. Failure Modes and Recovery

### 6.1 RDS Failure
- Multi-AZ failover is automatic (~60-120s downtime)
- Application reconnects via Prisma's connection pool retries

### 6.2 Redis Failure
- Sessions become unavailable until Redis is back; users effectively logged out
- BullMQ jobs in-flight are retried per queue config
- Cache misses fall through to Postgres (graceful degradation)
- **Critical:** application must handle Redis errors gracefully — never crash on Redis unavailability

### 6.3 EC2 Instance Failure
- ALB health check removes failing instance from rotation
- Auto Scaling Group replaces instance (recommended setup; otherwise manual)
- Stateless application design means no data loss

### 6.4 Worker Failure
- BullMQ persists jobs in Redis; worker restart resumes
- No new jobs run during downtime; backlog processes when worker returns
- Critical jobs (account deletion, data export) are time-tolerant

### 6.5 SES Failure
- Email delivery delayed; in-app notifications still work
- BullMQ retries with exponential backoff; permanent failures alert admin

### 6.6 Total Region Outage
- DR plan: restore from S3 backup in alternate region
- RTO target: 4 hours
- RPO target: 24 hours (daily backup cadence)
- Documented in Operations Runbook

---

## 7. Environment Strategy

### 7.1 Environments
- **Local:** Docker Compose; Postgres, Redis, app services on developer machine
- **Staging:** Single EC2 + smaller RDS in same VPC structure as prod; pre-launch QA
- **Production:** Full topology as described

### 7.2 Configuration
- Environment-specific values via env vars (12-factor)
- Feature flags via simple Postgres-backed flag table (no LaunchDarkly at MVP)
- Database migrations applied during deploy via CI

### 7.3 Data Isolation
- Staging database is separate; never holds real production data
- For testing flows that need realistic data, use synthetic seed scripts
- No PII from production ever copied to staging

---

## 8. Performance Budgets

| Surface | Target |
|---|---|
| Time-to-first-byte (TTFB) | < 500ms p50, < 1s p95 |
| Feed page load (mobile 4G) | < 2s p50, < 4s p95 |
| Question detail page load | < 1.5s p50, < 3s p95 |
| Search results | < 1s p50, < 2.5s p95 |
| WebSocket message delivery | < 500ms p50 |
| Background job completion (digest) | < 30 minutes |
| Background job completion (rep decay) | < 5 minutes |

These are budgets, not commitments; CI should fail PRs that demonstrably regress critical paths.

---

## 9. Open Questions for Engineering

These are intentionally left for the team to resolve in the first sprint:

- Which Node version (LTS 20 or LTS 22)? Default to LTS 22 unless ecosystem issues found.
- Auto Scaling Group enabled at launch or manual? Recommend ASG with min=1, max=3.
- ALB target group health check path and threshold? Recommend `/health` every 30s, 2 successes to mark healthy.
- Logging volume estimate for CloudWatch retention/cost? Start at 30-day retention; revisit.
- Sentry plan size? Estimate 5K events/day at MVP; team plan likely sufficient.
