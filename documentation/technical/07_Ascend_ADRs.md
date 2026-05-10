# Ascend — Architecture Decision Records (ADRs)

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Audience | Engineering team, future contributors |

> ADRs capture the *why* behind technical decisions. Future engineers will ask "why didn't we use X?" — these documents answer that. Each ADR follows a consistent format: Context, Decision, Consequences, Alternatives Considered.

---

## ADR-001: Backend Framework — Express + TypeScript

**Status:** Accepted

**Context**
We need a backend framework for the Ascend API. The team has direct experience with Express, FastAPI, and the Node ecosystem. The product surface is REST-heavy with a WebSocket layer for DMs and notifications. Expected scale is institutional (~3K concurrent peak, ~10-20K total users).

**Decision**
Use Node.js (LTS) with Express and TypeScript.

**Rationale**
- Single language across frontend (Next.js/React) and backend collapses cognitive load for a small team.
- TypeScript types can be shared between frontend and backend via a `packages/shared` workspace package, eliminating an entire class of integration bugs.
- Express is unopinionated enough that we won't fight the framework when implementing custom logic (Dynamic Seniority Engine, badge calculation, alumni verification).
- The Node ecosystem has mature libraries for every requirement: Socket.IO for realtime, BullMQ for jobs, Prisma for ORM, web-push for VAPID.

**Consequences**
- We must establish opinionated structure ourselves (see ADR-006: Project Structure).
- Async/await everywhere; no callback patterns.
- We accept the operational overhead of running Node in production (process management, memory leaks, etc.).

**Alternatives Considered**
- **NestJS:** Too much framework for this team size. The DI container, decorators, and module system are valuable at scale but slow early velocity.
- **FastAPI (Python):** Excellent framework, but introduces a second language. Loses the shared-types advantage with the React frontend.
- **Hono / Fastify:** Faster than Express but with smaller ecosystems. Performance is not our bottleneck at this scale.

---

## ADR-002: Frontend Framework — Next.js 15 (App Router)

**Status:** Accepted

**Context**
We need a React-based frontend that supports PWA, server-side rendering for performance, and a clear routing model.

**Decision**
Use Next.js 15 with the App Router and TypeScript.

**Rationale**
- App Router is mature in Next.js 15; React Server Components reduce client bundle size.
- Built-in PWA support via service worker integration.
- Route handlers can serve as a thin BFF layer if needed, though our primary backend is the Express API.
- Strong ecosystem: Tailwind, shadcn/ui, next-auth-style cookie handling, deployment story.

**Consequences**
- Server Components require careful thinking about which components are server vs client (`'use client'` directive).
- Some libraries that depend on browser APIs need dynamic imports.
- We must be deliberate about what runs on the server vs the client.

**Alternatives Considered**
- **Vite + React:** Simpler but loses SSR and the PWA story would need to be assembled manually.
- **Remix:** Strong contender but smaller ecosystem and fewer team members likely to know it.
- **Plain CRA:** Deprecated and lacks SSR.

---

## ADR-003: Database — PostgreSQL with Prisma ORM

**Status:** Accepted

**Context**
The data model is heavily relational: votes link voters to targets, badges depend on aggregate counts, reputation flows from events, the Dynamic Seniority Engine joins users and questions, the Resource Library has promotion rules requiring aggregation. Mongo (your stated comfort) was considered but rejected because forcing this into documents would create denormalization headaches.

**Decision**
Use PostgreSQL 16 as the primary database. Use Prisma as the ORM.

**Rationale**
- ACID guarantees for reputation events and vote counting.
- JSONB for flexible fields where needed (notification content, audit metadata).
- Full-text search via `tsvector` is sufficient at MVP scale.
- Prisma provides type-safe queries that compose cleanly with the rest of the TypeScript codebase.
- Prisma Migrate is ergonomic and produces SQL migrations that can be reviewed and version-controlled.

**Consequences**
- Schema migrations require discipline (no destructive changes without backfill plans).
- Prisma Client introduces a code-generation step in builds.
- Prisma's query engine is a Rust binary — must be in Docker images.

**Alternatives Considered**
- **MongoDB:** Wrong shape for this data. Joins everywhere would lead to either denormalization debt or `$lookup` performance issues.
- **TypeORM / Sequelize:** Older, less ergonomic, weaker TypeScript support than Prisma.
- **Drizzle ORM:** Newer alternative; closer to raw SQL. Viable but Prisma's tooling and migrations are more battle-tested.
- **Knex + raw SQL:** More control but loses type safety; not worth the trade at this scale.

---

## ADR-004: Cache and Job Queue — Redis + BullMQ

**Status:** Accepted

**Context**
We have multiple async needs: rate limiting, session storage, background jobs (rep decay, link checks, weekly digest), and caching frequently-read data (feed, search results).

**Decision**
Single Redis instance serving as cache, session store, rate limit counter, and BullMQ backend.

**Rationale**
- One service to operate instead of three.
- BullMQ is the de facto Node job library; supports cron schedules, retries, priority queues, and a visible UI (Bull Board).
- Redis is the standard session/cache store with mature client libraries (`ioredis`).

**Consequences**
- Redis becomes a critical dependency. RDB+AOF persistence required.
- Memory pressure must be monitored.
- Cache invalidation strategy must be deliberate (see ADR-008).

**Alternatives Considered**
- **In-memory queues (e.g., simple `setInterval`):** Won't survive restarts; not viable.
- **AWS SQS:** Adds AWS lock-in and another moving part; BullMQ over Redis is simpler.
- **Memcached for cache:** Doesn't support pub/sub or job semantics; loses the consolidation benefit.

---

## ADR-005: Real-time Layer — Socket.IO with Redis Adapter

**Status:** Accepted

**Context**
DMs and live notification badge updates require real-time delivery. Plain WebSockets work but require manual reconnection logic, message buffering, and room semantics.

**Decision**
Use Socket.IO with the Redis adapter for horizontal scaling.

**Rationale**
- Built-in reconnection, fallback to long-polling on hostile networks.
- Room/namespace primitives map cleanly to DM threads and per-user notifications.
- Redis adapter allows multiple Node instances to share connection state, which we'll need at moderate scale.

**Consequences**
- Sticky sessions required at the load balancer (or use Redis adapter exclusively).
- Slightly heavier wire protocol than raw WebSocket.
- Must scope events carefully — never broadcast more than needed.

**Alternatives Considered**
- **Raw WebSocket (`ws` library):** More work for marginal gain.
- **Server-Sent Events (SSE):** One-way only; doesn't fit DM use case.
- **Pusher / Ably (managed):** Operationally simpler but introduces vendor cost and data residency concerns (DPDP).

---

## ADR-006: Authentication — Custom Built on Primitives

**Status:** Accepted

**Context**
We have a complex auth surface: three personas (Student/Faculty/Alumnus), institutional email auto-verification, manual alumni verification, Google SSO, optional MFA, and account lockout. Off-the-shelf auth frameworks (NextAuth/Auth.js) are opinionated in ways that conflict with our verification flow.

**Decision**
Build authentication using well-tested primitives: Argon2id for password hashing, server-side sessions in Redis with HTTP-only cookies, `jose` for JWT (only for password reset and email verification tokens, not session tokens), `googleapis` for OAuth.

**Rationale**
- Sessions in Redis (not JWTs in cookies) allow instant revocation on logout, password change, or admin suspension.
- Cookie-based sessions are simpler than JWT rotation; SameSite=Lax + Secure + HttpOnly mitigates CSRF and XSS risk.
- Argon2id is the modern standard for password hashing.
- We need full control over the verification state machine (pending → verified → rejected → locked); off-the-shelf solutions don't model this cleanly.

**Consequences**
- More code to write and audit.
- Security review required before launch (see Security Checklist).
- We own the responsibility for keeping primitives current.

**Alternatives Considered**
- **NextAuth.js (Auth.js):** Convention-over-configuration; convenient for standard flows but rigid for our verification state machine.
- **Lucia:** Lightweight library; reasonable alternative if team prefers slightly more structure.
- **Auth0 / Clerk:** Vendor lock-in, cost, DPDP residency concerns (these store user data outside India).

---

## ADR-007: Monorepo with pnpm Workspaces

**Status:** Accepted

**Context**
Frontend and backend share TypeScript types (request/response shapes, enums, validation schemas). They will be deployed independently but developed together.

**Decision**
Single Git repository with pnpm workspaces. Layout: `apps/web`, `apps/api`, `apps/worker`, `packages/shared`, `packages/db`.

**Rationale**
- Shared types eliminate frontend-backend drift.
- pnpm's content-addressable store saves disk space and install time.
- Single PR can change frontend, backend, and DB schema atomically.

**Consequences**
- CI must build the right pieces for the right deploys.
- Larger repo size; clone times grow.
- Care required to avoid circular dependencies between packages.

**Alternatives Considered**
- **Polyrepo:** Common but creates type-drift overhead and cross-repo coordination friction.
- **Nx / Turbo:** Useful for very large monorepos; overkill at our size.
- **Yarn / npm workspaces:** Functionally similar to pnpm but slower installs.

---

## ADR-008: Caching Strategy — Selective with Short TTLs

**Status:** Accepted

**Context**
Premature caching causes stale-data bugs that are hard to debug. We should cache only where there's a measured need.

**Decision**
At launch, cache only:
1. Feed page render (per-user, 60s TTL) — invalidated on user's own post or follow change
2. User badge list (per-user, 5min TTL) — invalidated on badge earn/revoke
3. Tag list (global, 1hr TTL) — invalidated on admin tag mutation
4. User profile reads of others (per-target, 5min TTL)

All other reads go directly to Postgres until measured otherwise.

**Rationale**
- Most reads are personalized; cache hit rates would be low without explicit per-user caching.
- Postgres handles 10K-50K reads/sec on modest hardware; we're nowhere near that.
- Cache invalidation bugs are a top source of customer complaints; we minimize the surface.

**Consequences**
- Database load is higher than it could be.
- Adding caching later is a known cost.

**Alternatives Considered**
- **Aggressive caching from day one:** Solves a problem we don't have yet; introduces bugs we don't need.
- **Materialized views:** Powerful but more operational complexity.

---

## ADR-009: Hosting — AWS Mumbai (ap-south-1)

**Status:** Accepted

**Context**
DPDP Act 2023 requires personal data of Indian users to be stored in India. We need a cloud region in India and a small enough operational footprint that a 2-4 person team can manage it.

**Decision**
AWS Mumbai region (ap-south-1). Specific services: EC2 (compute), RDS PostgreSQL (managed DB), ElastiCache Redis (managed cache/queue), S3 (object store for audit log archives and data exports), SES (transactional email), CloudFront (CDN, optional but recommended), Route 53 (DNS), CloudWatch (basic logs).

**Rationale**
- Most mature managed services in Indian regions.
- DPDP compliance with default configuration.
- Strong tooling and community support.

**Consequences**
- AWS-specific knowledge required on the team.
- Cost is moderate but not the cheapest option.
- IAM and security group configuration must be deliberate.

**Alternatives Considered**
- **Azure India / GCP Mumbai:** Comparable; AWS chosen for ecosystem familiarity.
- **DigitalOcean Bangalore:** Cheaper, simpler, but smaller ecosystem and fewer managed services.
- **Self-hosted on a VPS:** Saves cost but adds DevOps burden disproportionate to team size.
- **Vercel / Railway / Render:** No Indian region; DPDP residency issue.

---

## ADR-010: Deployment — Containerized on EC2 with Docker Compose

**Status:** Accepted

**Context**
Need a deployment model that 2-4 engineers can operate without dedicated DevOps. ECS Fargate is more "modern" but adds VPC, ALB, IAM, and task-definition complexity.

**Decision**
At launch:
- 2 EC2 instances behind an Application Load Balancer
- Docker Compose on each instance running the API and web services
- One worker EC2 instance running BullMQ workers
- RDS Postgres (managed)
- ElastiCache Redis (managed)
- S3 for static export artifacts
- ALB for SSL termination and routing

**Rationale**
- Single-instance Docker Compose is operationally familiar.
- ALB handles SSL, health checks, and zero-downtime deploys.
- Vertical scaling is fine for the foreseeable future; horizontal possible by adding instances.

**Consequences**
- Deployment requires SSH or a deploy script; not GitOps from day one.
- Less elasticity than ECS/Kubernetes.
- Migration to ECS/Kubernetes is a known future task at scale.

**Alternatives Considered**
- **ECS Fargate:** More operational surface; defer until scale demands it.
- **EKS:** Wildly overkill.
- **AWS App Runner:** Simpler but less control; viable alternative.

---

## ADR-011: Observability — Sentry + CloudWatch + Structured Logs

**Status:** Accepted

**Context**
We need error tracking, basic metrics, and request logs. Full observability stack (Datadog, etc.) is cost-prohibitive at this scale.

**Decision**
- Application errors: Sentry (free tier or low cost; data residency check required for DPDP — Sentry has EU and US regions but no India yet; this requires acceptance and minimization of PII in error reports).
- Request logs: structured JSON logs (pino) shipped to CloudWatch.
- Infrastructure metrics: CloudWatch native (CPU, memory, RDS metrics).
- Custom business metrics (verifications/day, reports resolved, etc.): emit to a `metrics` Postgres table; render in admin dashboard.

**Rationale**
- Sentry is best-in-class for error tracking and trace context.
- CloudWatch is included with AWS; no extra integration.
- Custom metrics in Postgres avoid cost overhead of dedicated metrics services until needed.

**Consequences**
- Sentry's lack of India region requires DPIA review and PII minimization.
- CloudWatch logs are not the most ergonomic for searching; mitigated by structured logging.
- Custom Postgres metrics table will need cleanup/rollup over time.

**Alternatives Considered**
- **Datadog / New Relic:** Excellent but cost-prohibitive.
- **OpenTelemetry to a self-hosted Grafana stack:** Operationally heavy; worth revisiting at scale.
- **Self-hosted Sentry:** Possible but adds another service to operate.

---

## ADR-012: Markdown Rendering — markdown-it with Sanitization

**Status:** Accepted

**Context**
Q&A bodies, answer bodies, post bodies, and resource descriptions accept markdown. This is a primary XSS surface.

**Decision**
Use `markdown-it` for parsing with `markdown-it-sanitizer` plus a strict allowlist for HTML tags. Specifically:
- Allow: paragraphs, headings (h2-h4 only), lists, code blocks, inline code, blockquotes, links, emphasis, strong, line breaks
- Disallow: HTML tags in source, raw HTML output, images via `![]()` syntax (no external image embeds), iframes, scripts, styles
- Code blocks: server-side syntax highlighting with `highlight.js` (limited language set)
- Tables, footnotes, math: out of scope at launch

**Rationale**
- We disallow inline images entirely (consistent with "no media uploads" decision in PRD).
- Whitelist approach is safer than denylist.
- markdown-it is the most actively maintained Node markdown parser.

**Consequences**
- Users cannot embed images even via URL — this is intentional and should be clearly documented in user-facing help.
- We must keep markdown-it and its plugins updated for security.

**Alternatives Considered**
- **remark / unified:** More flexible but more complex; not needed.
- **GitHub Flavored Markdown:** Extensions like task lists are nice but not essential at MVP.

---

## ADR-013: Open Graph Fetching — Server-Side with Strict SSRF Protection

**Status:** Accepted

**Context**
Resource Library auto-pulls title from submitted URLs. Server-side HTTP fetch from user-supplied URLs is a classic SSRF vector.

**Decision**
Implement OG fetcher with strict controls:
- Resolve hostname; reject if it resolves to private IP ranges (RFC 1918, 169.254/16, 127/8, ::1, fc00::/7, fe80::/10), `metadata.google.internal`, or AWS instance metadata IPs (169.254.169.254).
- Use `dns.lookup` with a manual check before HTTP fetch; do not allow library to follow redirects to private addresses.
- Maximum 5MB response size; truncate after.
- 5-second timeout.
- Limit to HTTPS only (HTTP rejected).
- Strip cookies and authentication headers; never forward user headers.
- Run fetcher in a dedicated worker process with restricted IAM (no AWS metadata access).

**Rationale**
SSRF leading to AWS metadata exfiltration is a top-tier cloud vulnerability. The protections above are the standard mitigations.

**Consequences**
- Some legitimate URLs may fail to fetch; manual title entry is the fallback.
- Slight latency on submission (up to 5s timeout).
- Worker isolation adds deployment complexity, justified by security gain.

**Alternatives Considered**
- **Client-side fetching:** Doesn't work — CORS prevents most cross-origin metadata reads.
- **Third-party service (e.g., Iframely, Microlink):** Adds vendor cost and DPDP question.
- **No metadata fetch (manual only):** Worse UX, no security gain over a properly-controlled fetcher.

---

## ADR-014: Database Migrations — Prisma Migrate, Forward-Only

**Status:** Accepted

**Context**
Schema will evolve. We need a migration strategy that's safe for production data.

**Decision**
- Prisma Migrate for all schema changes.
- Migrations are forward-only (no `down` migrations in production).
- Destructive changes (drop column, change type) require a multi-deploy plan: add new, dual-write, backfill, cut over, drop old.
- All migrations reviewed in PR before merge.
- Migrations applied in CI before app deploys.

**Rationale**
- Down migrations rarely work in production; restoring from backup is the real rollback.
- Multi-deploy plans force the team to think through data implications.

**Consequences**
- Schema evolution is more work than naive "drop and recreate."
- Discipline required.

**Alternatives Considered**
- **Plain SQL migrations (e.g., Flyway-style):** More portable but loses type safety and Prisma's introspection benefits.

---

## ADR-015: Reputation Calculation — Event-Sourced with Materialized Score

**Status:** Accepted

**Context**
Reputation can be computed (a) on-the-fly by summing all events, or (b) materialized as a column on User. Decay (10%/year after 18 months) complicates pure summing.

**Decision**
Hybrid:
- `ReputationEvent` table stores every event immutably (append-only).
- `User.rep_score` column is a denormalized materialized total.
- On every event write, update `rep_score` via a transaction.
- Daily background job recomputes `rep_score` for all users with events older than 18 months (decay application).
- The job is idempotent — running it twice produces the same answer.

**Rationale**
- Reading rep is trivially fast (one column).
- Event log preserves auditability and allows recomputation if needed.
- Decay job runs daily, not per-read, keeping read paths fast.

**Consequences**
- Mismatches between events and materialized score are possible; daily recompute is the safety net.
- Events table grows unboundedly; rollup strategy may be needed at multi-year scale.

**Alternatives Considered**
- **Compute on read:** Simple but slow at scale and complicates decay.
- **Trigger-based:** Postgres triggers are robust but make logic harder to test and version.

---

## ADR-016: Search — Postgres Full-Text Search at MVP, Defer Dedicated Engine

**Status:** Accepted

**Context**
We need full-text search across questions, posts, resources, people, and tags. Dedicated search engines (Meilisearch, OpenSearch) are powerful but operational additions.

**Decision**
At launch:
- `tsvector` columns on Question, Answer, Post, Resource with GIN indexes.
- Composite scoring: tag match boost + recency boost + base relevance (`ts_rank_cd`).
- Typeahead on tags and people: simple `ILIKE` prefix queries with limit 10.

**Graduation criteria (move to dedicated search engine when):**
- p95 search latency exceeds 500ms, OR
- Need for typo tolerance / fuzzy matching becomes critical, OR
- Index size exceeds practical Postgres limits (~10GB on FTS columns)

**Rationale**
Postgres FTS is sufficient for institutional scale and avoids an additional service to operate.

**Consequences**
- No semantic search at MVP (acceptable per PRD).
- No typo tolerance at MVP (note in user-facing help: "spelling matters").
- Migration to Meilisearch/OpenSearch is a known future task with clear trigger.

**Alternatives Considered**
- **Meilisearch from day one:** Excellent product but adds an operational dependency we don't need yet.
- **Algolia:** Vendor; cost and DPDP residency.
- **Elasticsearch / OpenSearch:** Heavyweight for our scale.
