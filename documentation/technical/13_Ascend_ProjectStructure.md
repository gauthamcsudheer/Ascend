# Ascend — Project Structure & Local Development Setup

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Engineering team |
| Purpose | Get a developer from `git clone` to a running local environment in under 30 minutes |

---

## 1. Repository Structure

Single Git repository, pnpm workspaces.

```
ascend/
├── apps/
│   ├── web/                      # Next.js 15 frontend
│   │   ├── app/                  # App Router pages
│   │   ├── components/           # React components
│   │   ├── lib/                  # Frontend utilities
│   │   ├── public/               # Static assets
│   │   ├── styles/               # Global CSS, Tailwind config
│   │   ├── next.config.js
│   │   ├── tailwind.config.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── api/                      # Express + Socket.IO backend
│   │   ├── src/
│   │   │   ├── index.ts          # Entry point
│   │   │   ├── app.ts            # Express app factory
│   │   │   ├── server.ts         # HTTP + Socket.IO server
│   │   │   ├── routes/           # Express routers
│   │   │   ├── controllers/      # Route handlers
│   │   │   ├── services/         # Business logic
│   │   │   ├── middleware/       # Auth, rate limit, errors
│   │   │   ├── validators/       # Zod schemas
│   │   │   ├── socket/           # Socket.IO event handlers
│   │   │   ├── auth/             # Auth helpers (sessions, password, OAuth)
│   │   │   ├── lib/              # Shared utilities
│   │   │   └── config.ts         # Env var loader
│   │   ├── tests/
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── worker/                   # BullMQ worker process
│       ├── src/
│       │   ├── index.ts
│       │   ├── queues/
│       │   ├── jobs/
│       │   └── scheduler.ts
│       ├── package.json
│       └── tsconfig.json
│
├── packages/
│   ├── db/                       # Prisma schema + client
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   ├── seed.ts
│   │   │   └── migrations/
│   │   ├── src/
│   │   │   └── index.ts          # Re-exports prisma client
│   │   └── package.json
│   │
│   ├── shared/                   # Types + Zod schemas + constants
│   │   ├── src/
│   │   │   ├── types/            # Domain types (Question, User, etc.)
│   │   │   ├── schemas/          # Zod validators (request shapes)
│   │   │   ├── enums/            # Enum re-exports from Prisma
│   │   │   └── constants/        # Shared constants (limits, regex, etc.)
│   │   └── package.json
│   │
│   └── config/                   # Shared eslint, prettier, tsconfig
│       ├── eslint-base.js
│       ├── prettier.config.js
│       └── tsconfig.base.json
│
├── docs/                         # All the architecture documents
│   ├── 01_PRD.md
│   ├── 02_UserStories.md
│   ├── 03_TechnicalDesign.md
│   ├── ...
│
├── infra/                        # Infrastructure as code (future)
│   ├── terraform/                # Terraform configs (when ready)
│   └── docker/
│       ├── api.Dockerfile
│       ├── web.Dockerfile
│       └── worker.Dockerfile
│
├── scripts/                      # Dev and ops scripts
│   ├── dev-up.sh                 # docker compose + migrations + seed
│   ├── reset-db.sh
│   └── deploy.sh
│
├── .github/
│   └── workflows/
│       ├── ci.yml                # Lint, test, type-check on PR
│       └── deploy.yml            # Deploy on main
│
├── docker-compose.yml            # Postgres + Redis for local dev
├── .env.example                  # Template for env vars
├── .gitignore
├── pnpm-workspace.yaml
├── package.json                  # Root, with shared scripts
├── README.md
└── tsconfig.json                 # Root tsconfig
```

---

## 2. Workspace Configuration

### 2.1 `pnpm-workspace.yaml`
```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### 2.2 Root `package.json`
```json
{
  "name": "ascend",
  "private": true,
  "scripts": {
    "dev": "pnpm -r --parallel run dev",
    "build": "pnpm -r run build",
    "lint": "pnpm -r run lint",
    "type-check": "pnpm -r run type-check",
    "test": "pnpm -r run test",
    "db:migrate": "pnpm --filter @ascend/db prisma migrate dev",
    "db:reset": "pnpm --filter @ascend/db prisma migrate reset",
    "db:seed": "pnpm --filter @ascend/db prisma db seed",
    "db:studio": "pnpm --filter @ascend/db prisma studio"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "prettier": "^3.3.0",
    "eslint": "^9.0.0"
  },
  "engines": {
    "node": ">=22.0.0",
    "pnpm": ">=9.0.0"
  },
  "packageManager": "pnpm@9.6.0"
}
```

### 2.3 Package Naming
- `@ascend/web`
- `@ascend/api`
- `@ascend/worker`
- `@ascend/db`
- `@ascend/shared`
- `@ascend/config`

### 2.4 Internal Dependencies
Each app declares workspace deps:
```json
{
  "dependencies": {
    "@ascend/db": "workspace:*",
    "@ascend/shared": "workspace:*"
  }
}
```

---

## 3. Local Development Setup

### 3.1 Prerequisites
- Node.js 22 LTS (use `nvm` or `fnm`)
- pnpm 9+ (`corepack enable && corepack prepare pnpm@latest --activate`)
- Docker Desktop (for Postgres and Redis)
- Git

### 3.2 First-Time Setup

```bash
# Clone
git clone <repo-url> ascend
cd ascend

# Install dependencies (single command for all packages)
pnpm install

# Copy env template
cp .env.example .env
# Edit .env with local values (defaults work for docker-compose)

# Start Postgres and Redis
docker compose up -d

# Apply migrations and seed
pnpm db:migrate
pnpm db:seed

# Start all dev servers
pnpm dev
```

After this, the developer should see:
- Web app at `http://localhost:3000`
- API at `http://localhost:4000`
- Worker logging to console
- Postgres at `localhost:5432`
- Redis at `localhost:6379`
- Bull Board at `http://localhost:4000/admin/queues` (after admin login)

### 3.3 `docker-compose.yml`
```yaml
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ascend
      POSTGRES_PASSWORD: ascend_dev_password
      POSTGRES_DB: ascend_dev
    ports:
      - "5432:5432"
    volumes:
      - ascend_pg_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - ascend_redis_data:/data

volumes:
  ascend_pg_data:
  ascend_redis_data:
```

### 3.4 `.env.example`

```bash
# === Database ===
DATABASE_URL=postgresql://ascend:ascend_dev_password@localhost:5432/ascend_dev

# === Redis ===
REDIS_URL=redis://localhost:6379

# === API ===
API_PORT=4000
API_BASE_URL=http://localhost:4000
SESSION_COOKIE_DOMAIN=localhost
SESSION_COOKIE_SECURE=false  # true in production

# === Web ===
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_APP_URL=http://localhost:3000

# === Email (use Mailpit/Mailhog locally) ===
SMTP_HOST=localhost
SMTP_PORT=1025
EMAIL_FROM=noreply@ascend.local

# === Google OAuth ===
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_OAUTH_CALLBACK_URL=http://localhost:4000/api/v1/auth/sso/google/callback

# === Web Push (VAPID) ===
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
VAPID_SUBJECT=mailto:admin@ascend.local

# === Encryption (for MFA secrets) ===
ENCRYPTION_KEY=  # 32-byte random hex; generate with `openssl rand -hex 32`

# === Email/Push from worker ===
AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=  # only needed for SES in non-local
AWS_SECRET_ACCESS_KEY=
S3_AUDIT_BUCKET=
S3_EXPORT_BUCKET=

# === Sentry ===
SENTRY_DSN=  # optional in local

# === Feature Flags / Misc ===
NODE_ENV=development
LOG_LEVEL=debug
```

### 3.5 Optional Services for Local Dev

For a richer local environment, add these to `docker-compose.yml`:

```yaml
  mailpit:
    image: axllent/mailpit
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # Web UI

  bullboard:
    # Already mounted at /admin/queues by the API; no separate service
```

Mailpit captures outgoing emails locally so developers can verify email flows without sending real mail.

---

## 4. Build & Run Scripts

Each app's `package.json` exposes consistent scripts:

```json
// apps/web/package.json
{
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "vitest run"
  }
}
```

```json
// apps/api/package.json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:integration": "vitest run -c vitest.integration.config.ts"
  }
}
```

```json
// apps/worker/package.json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "vitest run"
  }
}
```

```json
// packages/db/package.json
{
  "scripts": {
    "build": "prisma generate",
    "lint": "echo 'no lint for db'",
    "type-check": "tsc --noEmit"
  },
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

---

## 5. Code Generation & Build Order

Build dependencies are inferred by pnpm's workspace resolution; running `pnpm build` topologically sorts:

1. `packages/shared` builds (TypeScript compile)
2. `packages/db` runs `prisma generate` (creates type-safe client)
3. `apps/api`, `apps/worker`, `apps/web` build in parallel

**On schema change:**
```bash
pnpm db:migrate                    # creates migration + regenerates client
pnpm install                       # picks up regenerated client across workspaces
pnpm type-check                    # verify nothing broke
```

---

## 6. Seed Data

`packages/db/prisma/seed.ts` populates:

- ~90-100 starter tags with descriptions
- A first admin account (email/password from env)
- A test student, faculty, and alumnus (in development only)
- Active academic calendar entry
- Default notification categories

```typescript
// packages/db/prisma/seed.ts (sketch)
import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding tags...');
  await prisma.tag.createMany({
    data: TAG_TAXONOMY,
    skipDuplicates: true,
  });

  console.log('Seeding admin...');
  const adminEmail = process.env.SEED_ADMIN_EMAIL;
  const adminPassword = process.env.SEED_ADMIN_PASSWORD;
  if (!adminEmail || !adminPassword) {
    throw new Error('SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD required');
  }

  const admin = await prisma.user.upsert({
    where: { email: adminEmail },
    update: {},
    create: {
      email: adminEmail,
      name: 'Admin',
      persona: 'FACULTY',
      department: 'Administration',
      passwordHash: await argon2.hash(adminPassword),
      verificationStatus: 'VERIFIED',
      emailVerifiedAt: new Date(),
    },
  });

  await prisma.adminRole.upsert({
    where: { userId: admin.id },
    update: {},
    create: { userId: admin.id, grantedById: admin.id },
  });

  if (process.env.NODE_ENV === 'development') {
    console.log('Seeding development users...');
    // Create test student, faculty, alumnus accounts
  }

  console.log('Done.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
```

---

## 7. CI Pipeline (.github/workflows/ci.yml)

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: ascend
          POSTGRES_PASSWORD: ascend
          POSTGRES_DB: ascend_test
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        ports: ['6379:6379']

    env:
      DATABASE_URL: postgresql://ascend:ascend@localhost:5432/ascend_test
      REDIS_URL: redis://localhost:6379

    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'pnpm'

      - run: pnpm install --frozen-lockfile
      - run: pnpm db:migrate deploy
      - run: pnpm lint
      - run: pnpm type-check
      - run: pnpm test
      - run: pnpm build
```

---

## 8. Editor / IDE Setup

### Recommended VS Code extensions
- ESLint
- Prettier
- Prisma
- Tailwind CSS IntelliSense
- TypeScript and JavaScript Language Features (built-in)
- Code Spell Checker (optional)

### `.vscode/settings.json`
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

### Recommended WebStorm settings
Same outcomes via Settings → Languages & Frameworks. Enable Prettier as default formatter.

---

## 9. Environment Variable Loading

- **API & Worker:** Load via `dotenv` at startup; in production, env vars come from AWS Secrets Manager via the deployment process (see Operations Runbook).
- **Web:** Next.js loads `.env.local` automatically; only `NEXT_PUBLIC_*` vars are exposed to the client.

**Strict validation at boot:**
```typescript
// apps/api/src/config.ts
import { z } from 'zod';

const Env = z.object({
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  API_PORT: z.coerce.number().int().positive(),
  SESSION_COOKIE_DOMAIN: z.string(),
  SESSION_COOKIE_SECURE: z.coerce.boolean(),
  // ...
});

export const config = Env.parse(process.env);
// Crashes at boot if env is missing/wrong, not silently at runtime.
```

---

## 10. Common Local Dev Workflows

### Adding a new API endpoint
1. Define Zod schema in `packages/shared/src/schemas/`.
2. Add route in `apps/api/src/routes/`.
3. Add controller in `apps/api/src/controllers/`.
4. Add service logic in `apps/api/src/services/`.
5. Update API spec doc.
6. Write tests.
7. Update frontend client function in `apps/web/lib/api/`.

### Adding a new database column
1. Edit `packages/db/prisma/schema.prisma`.
2. Run `pnpm db:migrate` (creates migration file).
3. Review generated SQL.
4. Update affected code.
5. Run `pnpm type-check`.

### Resetting local DB
```bash
pnpm db:reset    # drops, re-creates, migrates, re-seeds
```

### Running a specific test
```bash
pnpm --filter @ascend/api test -- src/services/seniority.test.ts
```

### Inspecting DB
```bash
pnpm db:studio   # opens Prisma Studio in browser
```

---

## 11. Troubleshooting Quick-Reference

| Issue | Fix |
|---|---|
| `Cannot find module '@ascend/db'` | Run `pnpm install` from root |
| `prisma client out of sync` | `pnpm --filter @ascend/db prisma generate` |
| Migration fails | Check Postgres is running; `docker compose up -d` |
| Web can't reach API | Check `NEXT_PUBLIC_API_URL` matches API port |
| Sessions don't persist | Cookie domain mismatch; check `SESSION_COOKIE_DOMAIN` |
| Worker not picking up jobs | Check Redis is running and reachable |
| TypeScript errors after schema change | Re-run `prisma generate`; restart TS server in editor |

---

## 12. README.md Skeleton

The repository's top-level `README.md` should follow this skeleton (engineering populates):

```markdown
# Ascend

Knowledge and mentorship platform for the RSET community.

## Quick Start
[Reference setup steps from this doc]

## Documentation
- [PRD](docs/01_PRD.md)
- [Architecture](docs/08_SystemArchitecture.md)
- [API Spec](docs/10_APISpec.md)
- [Auth Spec](docs/11_AuthSpec.md)
- [All Documents](docs/)

## Project Status
[Current phase, version, known issues]

## Contributing
[Branch strategy, PR process — see Engineering Standards doc]

## License
[Internal use only / specific terms]
```
