# Ascend

Knowledge and mentorship platform for the RSET community — a single place where students, faculty, alumni, and former students share questions, experiences, and curated resources, and connect with each other through structured introductions and direct messages.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 15 (App Router), React 18, Tailwind CSS, TypeScript (strict) |
| Backend API | Express 4 + Socket.IO, TypeScript (strict) |
| Background Worker | BullMQ + ioredis (dedicated process) |
| Database | PostgreSQL 16 via Prisma 5 |
| Cache / Queue / Sessions | Redis 7 |
| Email (local) | Mailpit |
| Email (prod) | AWS SES |
| Logging | pino (structured JSON, with PII redaction) |
| Testing | Vitest (unit + integration), Playwright (E2E) |
| Tooling | pnpm workspaces, ESLint 9 (flat config), Prettier 3 |

---

## Repository Structure

```
ascend/
├── apps/
│   ├── web/        # Next.js 15 frontend (port 3000)
│   ├── api/        # Express + Socket.IO backend (port 4000)
│   └── worker/     # BullMQ worker process
├── packages/
│   ├── db/         # Prisma schema + client (@ascend/db)
│   ├── shared/     # Shared types, Zod schemas, constants (@ascend/shared)
│   └── config/     # Shared eslint, prettier, tsconfig (@ascend/config)
├── infra/
│   └── docker/     # Production Dockerfiles for api, web, worker
├── scripts/        # dev, db reset, post-migration SQL
├── documentation/  # Product, technical, and design docs
└── .github/        # CI / deploy workflows
```

---

## Prerequisites

- **Node.js 22 LTS** (use `fnm` or `nvm` to manage versions)
- **pnpm 9.6.0** (`corepack enable && corepack prepare pnpm@9.6.0 --activate`)
- **Docker Desktop** (for local Postgres, Redis, Mailpit)
- **Git**

---

## Quick Start

From `git clone` to a running stack in under 5 minutes.

```bash
# 1. Install workspace dependencies
pnpm install

# 2. Copy and fill env
cp .env.example .env
# Generate ENCRYPTION_KEY:
#   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Paste the value into .env as ENCRYPTION_KEY=<value>

# 3. Start Postgres, Redis, and Mailpit
docker compose up -d

# 4. Apply migrations and post-migration SQL (FTS triggers + check constraints)
pnpm db:migrate
Get-Content scripts/post-migrate.sql | docker exec -i ascend-postgres-1 psql -U ascend -d ascend_dev

# 5. Seed admin + dev test users
pnpm db:seed

# 6. Start all services in parallel
pnpm dev
```

After this:

| Service | URL |
|---|---|
| Web app | http://localhost:3000 |
| API | http://localhost:4000 |
| Health check | http://localhost:4000/health |
| Mailpit (email inbox) | http://localhost:8025 |
| Postgres | `localhost:5432` (user `ascend`, db `ascend_dev`) |
| Redis | `localhost:6379` |

---

## Seed Accounts

After running `pnpm db:seed`, the following accounts exist for local development:

| Email | Persona | Password |
|---|---|---|
| `admin@ascend.local` (or your `SEED_ADMIN_EMAIL`) | FACULTY + admin role | `SEED_ADMIN_PASSWORD` from `.env` |
| `student@ascend.local` | STUDENT | `password123` |
| `faculty@ascend.local` | FACULTY | `password123` |
| `alumnus@ascend.local` | ALUMNUS | `password123` |

---

## Common Commands

```bash
# Development
pnpm dev                 # All apps in parallel (web + api + worker)
pnpm build               # Production build of every app
pnpm lint                # ESLint across all workspaces
pnpm type-check          # tsc --noEmit across all workspaces
pnpm test                # Vitest across all workspaces

# Database
pnpm db:migrate          # Create + apply a new migration
pnpm db:reset            # Drop, re-create, migrate, re-seed
pnpm db:seed             # Run seed script
pnpm db:studio           # Prisma Studio in browser
pnpm db:deploy           # Apply migrations (production / CI)
```

---

## Documentation

### Product

- [Product Requirements (PRD)](documentation/product/01_Ascend_PRD.md)
- [User Stories](documentation/product/02_Ascend_UserStories.md)
- [Technical Design Overview](documentation/product/03_Ascend_TechnicalDesign.md)
- [Admin & Ops Playbook](documentation/product/04_Ascend_AdminOpsPlaybook.md)
- [Launch Plan](documentation/product/05_Ascend_LaunchOpsPlan.md)
- [Brand & Voice](documentation/product/06_Ascend_BrandVoiceGuidelines.md)

### Technical

- [Architecture Decision Records](documentation/technical/07_Ascend_ADRs.md)
- [System Architecture](documentation/technical/08_Ascend_SystemArchitecture.md)
- [Database Schema](documentation/technical/09_Ascend_DatabaseSchema.md)
- [API Specification](documentation/technical/10_Ascend_APISpec.md)
- [Auth Specification](documentation/technical/11_Ascend_AuthSpec.md)
- [Async / Worker Architecture](documentation/technical/12_Ascend_AsyncArchitecture.md)
- [Project Structure](documentation/technical/13_Ascend_ProjectStructure.md)
- [Engineering Standards](documentation/technical/14_Ascend_EngineeringStandards.md)
- [Security Checklist](documentation/technical/15_Ascend_SecurityChecklist.md)
- [Operations Runbook](documentation/technical/16_Ascend_OperationsRunbook.md)

### Design

- [Design Principles](documentation/design/17_Ascend_DesignPrinciples.md)
- [Design System Foundations](documentation/design/18_Ascend_DesignSystemFoundations.md)
- [Component Library](documentation/design/19_Ascend_ComponentLibrary.md)
- [Information Architecture](documentation/design/20_Ascend_InformationArchitecture.md)
- [Screen Inventory](documentation/design/21_Ascend_ScreenInventory.md)
- [Interaction Patterns](documentation/design/22_Ascend_InteractionPatterns.md)
- [Accessibility Spec](documentation/design/23_Ascend_AccessibilitySpec.md)
- [Content Design Guidelines](documentation/design/24_Ascend_ContentDesignGuidelines.md)
- [Responsive Strategy](documentation/design/25_Ascend_ResponsiveStrategy.md)
- [State Catalog](documentation/design/26_Ascend_StateCatalog.md)

---

## Project Status

**Phase:** Initial development — foundation complete, feature work beginning.

**What's working:**
- pnpm monorepo with strict TypeScript across all packages
- Full database schema (31 tables) with check constraints, GIN full-text indexes, and FTS triggers
- API foundational middleware: CORS, rate limiting, request-ID correlation, structured logging with PII redaction
- Workspace-scoped lint, type-check, and build pipelines
- Production-clean `start` scripts (env injected at orchestrator level)

**Deferred (tracked, not blocking):**
- Authentication (Google OAuth, password, MFA) — first feature on the roadmap
- Sentry `init()` (waiting on DSN provisioning)
- Bull Board admin UI (needs auth first)
- `deploy.yml` (waiting on AWS infrastructure)
- First Vitest tests (will land with first business logic)

---

## Contributing

See [Engineering Standards](documentation/technical/14_Ascend_EngineeringStandards.md) for the canonical conventions. Highlights:

- **Branching:** trunk-based, short-lived feature branches off `main` (`feat/...`, `fix/...`, `chore/...`).
- **Commits:** Conventional Commits format, imperative mood.
- **PRs:** under 400 lines, 1 approval required (2 for auth / DB migrations).
- **Merge:** squash to `main`.
- **Testing:** unit tests for pure functions, integration tests against a real Postgres test DB, E2E for critical flows.

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `Cannot find module '@ascend/db'` | Run `pnpm install` from repo root |
| `Prisma client out of sync` | `pnpm --filter @ascend/db exec prisma generate` |
| Migration fails | Check Postgres is running: `docker compose ps` |
| Sessions don't persist | Check `SESSION_COOKIE_DOMAIN` in `.env` matches host |
| Worker not picking up jobs | Check Redis is reachable: `docker exec ascend-redis-1 redis-cli PING` |
| TypeScript errors after schema change | Re-run `prisma generate`; restart TS server in editor |

More in [Project Structure §11](documentation/technical/13_Ascend_ProjectStructure.md).

---

## License

MIT — see [LICENSE](LICENSE).
