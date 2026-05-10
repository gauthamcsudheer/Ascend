# Ascend — Engineering Standards & Conventions

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | All engineers contributing to Ascend |
| Purpose | A canonical reference for "how we do things." Reduces ad-hoc decisions. |

> Standards exist to remove friction, not to impose taste. If a rule below seems wrong, raise it; standards are amended, not silently ignored.

---

## 1. Code Style

### 1.1 TypeScript

- **Strict mode on.** `tsconfig.json` enables `strict: true`, `noUncheckedIndexedAccess: true`, `noFallthroughCasesInSwitch: true`.
- **No `any`.** Use `unknown` when type is genuinely unknown, then narrow.
- **Prefer `type` over `interface`** for new domain types unless declaration merging is needed.
- **Explicit return types on exported functions.** Internal helpers can rely on inference.
- **No default exports** in shared packages (`packages/*`); named exports only. Apps may use defaults sparingly (e.g., Next.js page components require defaults).
- **No barrel files** (`index.ts` re-exporting everything) in apps. Use barrels in `packages/shared` only where they aid consumer ergonomics.

### 1.2 Naming

- **Files:** kebab-case (`user-service.ts`).
- **Components:** PascalCase file matching component (`QuestionCard.tsx`).
- **Variables / functions:** camelCase.
- **Types / interfaces / enums:** PascalCase.
- **Constants:** UPPER_SNAKE_CASE for true constants (`MAX_TITLE_LENGTH`); camelCase for module-level config objects.
- **Booleans:** prefix with `is`, `has`, `can`, `should` (`isVerified`, `canAnswer`, `hasMfa`).
- **Async functions returning promises:** suffix not required, but be explicit when the async nature is non-obvious.
- **React hooks:** prefix with `use` (`useFeed`, `useAuth`).
- **Database table names:** PascalCase singular (matches Prisma model names).

### 1.3 Formatting

- **Prettier** is the source of truth; do not argue formatting in PR review.
- Configured rules:
  - 2-space indent
  - Single quotes for strings
  - Trailing commas where valid
  - Line width 100
  - Semicolons required
  - LF line endings

### 1.4 Imports

Order:
1. Node built-ins
2. External packages
3. Internal workspace packages (`@ascend/*`)
4. Relative imports

Each group separated by blank line. ESLint enforces this.

```typescript
import { readFile } from 'node:fs/promises';

import express from 'express';
import { z } from 'zod';

import { prisma } from '@ascend/db';
import type { CreateQuestionInput } from '@ascend/shared';

import { requireAuth } from '../middleware/auth';
import { questionService } from './question-service';
```

### 1.5 React / Next.js

- **Server Components by default;** mark Client Components with `'use client'` only when needed (event handlers, hooks, browser APIs).
- **Component file structure:** one component per file, named the same as the file. Co-locate small subcomponents.
- **Props:** typed inline for simple cases, extracted to `XProps` type for complex.
- **Avoid prop drilling beyond 2 levels;** use Context or a server-fetched parent.
- **No inline styles** unless dynamic values demand it; use Tailwind classes.
- **Compose Tailwind utility classes;** extract to `cva` (class-variance-authority) when a component has many variants.

### 1.6 Comments

- Comments explain *why*, not *what*. The code shows what.
- Use JSDoc for public exported functions in shared packages.
- TODO comments must include a name or ticket reference: `// TODO(alice): handle empty state once design is finalized`.
- No commented-out code in committed PRs. Use git history.

### 1.7 Linting

- **ESLint** with shared config in `packages/config`.
- Lint errors fail CI; warnings allowed but tracked.
- Disabling a rule inline requires a comment explaining why.

---

## 2. Git & Branching

### 2.1 Branch Strategy

We use **trunk-based development** with short-lived feature branches.

- **`main`:** always deployable. Protected; no direct pushes. PR + 1 approval + green CI required.
- **Feature branches:** named `feat/short-description`, `fix/short-description`, `chore/short-description`. Branched from `main`.
- **Long-lived feature flags** for incomplete work merged to main behind flags rather than long-running branches.

### 2.2 Commits

- **Conventional Commits** format:
  - `feat: add connection request expiry`
  - `fix: prevent duplicate question submission`
  - `chore: bump prisma to 5.18`
  - `refactor: extract seniority engine to pure function`
  - `test: cover badge revocation edge cases`
  - `docs: update API spec for new endpoint`
- **Imperative mood, present tense, no period.**
- Commits should compile and pass tests. Local WIP is fine but squash before merge if needed.

### 2.3 Pull Requests

**PR title:** matches the conventional commit format.

**PR description template:**
```markdown
## What
[1-2 sentences on what this PR does]

## Why
[Link to ticket / spec; brief rationale if non-obvious]

## How
[Notable implementation choices, especially anything reviewer should notice]

## Testing
[How you tested this. Screenshots for UI changes. Curl commands for API changes.]

## Risk
[Anything reviewer should be careful about. Migration? Behavioral change? None?]
```

**PR size:** target under 400 lines changed. Larger PRs slow review and increase risk. Break into stacked PRs when possible.

**Review:** at least 1 approval required. For changes touching auth, payments (future), or DB migrations: 2 approvals.

**Merge strategy:** squash merge to main (linear history). Commit message follows conventional format.

### 2.4 What Can't Be in a PR

- Secrets, API keys, real user data.
- `.env` files (use `.env.example` to document required vars).
- Generated files unless required (Prisma client is generated, not committed).
- Large binary files (use Git LFS if ever needed).

---

## 3. Testing Strategy

### 3.1 Test Pyramid

- **Unit tests (most):** pure functions, services, utilities. Fast, isolated, no DB.
- **Integration tests (fewer):** route handlers + DB. Real Postgres in test container.
- **E2E tests (fewest):** Playwright covering critical user flows.

### 3.2 Targets

| Category | Coverage Goal | Frequency |
|---|---|---|
| Pure functions (seniority, badge eligibility, decay calc) | ~95% | Every change |
| API endpoints | All happy paths + key error paths | Every change |
| Critical UI flows (signup, login, ask, answer, accept) | E2E | Pre-deploy |
| Other UI | Component-level Vitest | Best-effort |

### 3.3 Naming

```typescript
describe('canAnswer (Dynamic Seniority Engine)', () => {
  it('allows alumnus to answer student question', () => { ... });
  it('rejects student answering same-semester student', () => { ... });
  it('allows student to answer alumnus question', () => { ... });
});
```

`describe` names the unit; `it` describes the behavior in plain language.

### 3.4 Test Database

- Integration tests use a separate Postgres database (`ascend_test`).
- Each test runs in a transaction that rolls back on completion (when feasible) for isolation.
- Where transactions don't fit (e.g., testing migrations themselves), use `truncate` between tests.
- Tests must not assume seeded data; they create their own fixtures.

### 3.5 What Not to Test

- Library internals (Prisma, Express).
- Trivial getters/setters.
- Implementation details that the test would couple to.

### 3.6 Test Data Builders

Use builder functions instead of inline object creation:

```typescript
// tests/builders/user.ts
export function buildStudent(overrides?: Partial<User>): User {
  return {
    id: 'cuid_default',
    email: 'student@test.local',
    persona: 'STUDENT',
    branch: 'CSE',
    semester: 3,
    batchYear: 2027,
    verificationStatus: 'VERIFIED',
    ...overrides,
  };
}
```

This pattern keeps tests focused on what's relevant.

---

## 4. Error Handling

### 4.1 Errors Are Values

- Throw only for genuinely exceptional cases (network down, invariant violated).
- For expected business outcomes ("user not found", "rate limit hit"), return a result type or use middleware-handled domain errors.

### 4.2 Domain Error Class

```typescript
// apps/api/src/lib/errors.ts
export class DomainError extends Error {
  constructor(
    public code: string,
    public httpStatus: number,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'DomainError';
  }
}

export class NotFoundError extends DomainError {
  constructor(resource: string, id?: string) {
    super('NOT_FOUND', 404, `${resource} not found`, id ? { id } : undefined);
  }
}

export class ValidationError extends DomainError {
  constructor(message: string, details?: Record<string, unknown>) {
    super('VALIDATION_ERROR', 400, message, details);
  }
}

// More: ForbiddenError, ConflictError, RateLimitError, etc.
```

### 4.3 Error Middleware

Express error middleware converts thrown errors to API responses:

```typescript
// apps/api/src/middleware/error.ts
export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  if (err instanceof DomainError) {
    return res.status(err.httpStatus).json({
      error: { code: err.code, message: err.message, details: err.details },
    });
  }

  // Unexpected error
  logger.error({ err, path: req.path }, 'Unhandled error');
  Sentry.captureException(err);
  return res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
  });
};
```

### 4.4 Never Swallow Errors

```typescript
// BAD
try { await something(); } catch {}

// BAD
try { await something(); } catch (e) { console.log(e); }

// GOOD
try {
  await something();
} catch (err) {
  logger.error({ err, context: { userId } }, 'Failed to process X');
  throw err; // or a wrapped error with more context
}
```

### 4.5 User-Facing Error Messages

- Avoid revealing internals. "Database connection failed" → "Service temporarily unavailable, please try again."
- Use the brand voice (calm, direct) — see Brand Voice doc.
- For form validation: actionable, specific.

---

## 5. Logging

### 5.1 Logger

Use `pino` for structured JSON logging:

```typescript
// apps/api/src/lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  redact: ['req.headers.cookie', 'req.headers.authorization', '*.password', '*.passwordHash'],
});
```

### 5.2 Levels

- `fatal`: process is dying or in an unrecoverable state.
- `error`: a request failed unexpectedly; user impact.
- `warn`: something abnormal but handled (rate limit hit, DB retry succeeded).
- `info`: lifecycle events (server started, job completed).
- `debug`: development-only verbose logging.
- `trace`: rarely used; very fine-grained.

### 5.3 What to Log

- **Request start/end** (via middleware): method, path, status, duration, userId (if authenticated).
- **Auth events**: per Auth Spec § 12.
- **Admin actions**: insert into AuditLogEntry (DB) AND log.info.
- **Background job lifecycle**: enqueue, start, success, failure.
- **External calls**: SES, OAuth, OG fetch — log outcome.
- **Database errors and slow queries** (> 1s).

### 5.4 What NOT to Log

- Passwords (even hashed).
- Session cookies / tokens.
- Full request bodies of auth endpoints.
- PII unless minimized: email becomes hash, IP can be partial.
- Card numbers (we don't have them, but be vigilant).

### 5.5 Correlation IDs

Every request gets a UUID `requestId` injected by middleware, propagated to downstream services and included in all log lines for that request. Frontend includes `X-Request-Id` header when available.

---

## 6. Performance Conventions

### 6.1 Database

- **N+1 queries are a bug.** Use Prisma's `include` or explicit `IN` queries.
- **Pagination always.** No unbounded list endpoints.
- **Index before merge.** PRs adding queries on new columns must add indexes.
- **EXPLAIN your queries** when uncertain about plan.
- **Materialized columns for hot reads** (e.g., `User.repScore`, `Question.voteScore`).
- **Soft delete via `deletedAt`** column where retention is policy; hard delete only via admin/DPDP processes.

### 6.2 API Response Times

Target p95 < 500ms for typical endpoints. Endpoints exceeding this in production are tracked and reviewed.

### 6.3 Caching

Per ADR-008, cache narrowly. When introducing a cache:
- Define cache key explicitly (`feed:{userId}:{cursor}`).
- Define TTL.
- Define invalidation events.
- Document in code comments next to the cache call.

### 6.4 Frontend Bundle Size

- **Dynamic imports** for heavy non-critical components (rich editor, chart libraries).
- **Tree-shake** confirmed via build output.
- Watch bundle analyzer reports in CI.

---

## 7. Security Conventions

### 7.1 Input Validation

- **Validate at the boundary** with Zod. Trust validated types thereafter.
- **Never trust client-provided IDs** for authorization. Always check ownership server-side.

### 7.2 Output Encoding

- React handles JSX encoding. Never use `dangerouslySetInnerHTML` except for sanitized markdown output.
- For URLs constructed from user input, use `URL` constructor and validate scheme.

### 7.3 SQL

- Always parameterize via Prisma. No raw SQL with string interpolation.
- For raw SQL (`$queryRaw`), use tagged template literals: `` prisma.$queryRaw`SELECT * FROM x WHERE id = ${id}` ``.

### 7.4 Secrets

- Never commit secrets.
- Never log secrets.
- In code, secrets come from `config.ts` (env-derived); never hardcoded.

### 7.5 Dependencies

- `pnpm audit` runs in CI; high/critical vulnerabilities block merge.
- Update dependencies monthly; security patches immediately.

(See Security Checklist for full operational security guidance.)

---

## 8. Documentation in Code

### 8.1 What to Document

- **Public exported functions** in shared packages: JSDoc with description, params, returns, examples.
- **Non-obvious algorithms:** comment explaining the why and any references.
- **Non-trivial workflow steps:** state transitions, retry semantics, etc.

### 8.2 What Not to Document

- Self-evident code.
- Restating types.
- Outdated comments — delete them.

### 8.3 README Per Package

Each package and app has a `README.md` describing:
- What it is
- How to run/build
- Key conventions specific to it (if any)
- Pointers to relevant docs in `/docs`

---

## 9. Code Review Standards

### 9.1 Review Within 24 Hours

- Reviewers commit to looking at PRs within 1 business day.
- If a reviewer can't, they reassign.

### 9.2 What Reviewers Look For

In rough priority:
1. **Correctness:** does it do what it claims?
2. **Security:** any new attack surfaces? Auth correct? Inputs validated?
3. **Tests:** sufficient? Cover edges?
4. **Architecture:** consistent with rest of code? Right level of abstraction?
5. **Readability:** can the next person understand this?
6. **Performance:** any obvious issues?
7. **Style:** lint passes; conventions followed.

### 9.3 Reviewer Etiquette

- Be specific about asks ("rename `x` to `y`" not "this is unclear").
- Distinguish blocking from suggestion: prefix non-blocking comments with `nit:` or `optional:`.
- Approve when the PR is mergeable; don't hold up minor improvements (file follow-ups).

### 9.4 Author Etiquette

- Respond to every comment (even "ack").
- Don't take feedback personally; it's about the code.
- If pushing back, explain reasoning; reviewer may be missing context.

---

## 10. Database Migration Practices

### 10.1 Forward-Only

Per ADR-014, migrations are forward-only in production. Local rollbacks via `prisma migrate reset` only.

### 10.2 Reviewing Migrations

Migration PRs require:
- Generated SQL reviewed (not just the schema diff).
- Comment on whether it's a backward-compatible change.
- For breaking changes: a written multi-deploy plan (add column → backfill → switch reads → drop old).

### 10.3 Backward-Compatible Patterns

- **Adding a column:** always safe if nullable or has default.
- **Renaming a column:** add new, dual-write, backfill, switch reads, drop old. Three deploys minimum.
- **Changing a column type:** add new, migrate data, switch reads, drop old.
- **Removing a column:** stop reads, deploy, then drop in subsequent deploy.
- **Adding an index:** safe; large tables may need `CREATE INDEX CONCURRENTLY` (raw SQL).

---

## 11. Dependency Management

### 11.1 Adding a Dependency

Before adding a new package, ask:
- Is it actively maintained? (Last commit recent; multiple contributors.)
- Is it well-known or vetted? (Avoid abandoned single-author packages for security-critical work.)
- Does it solve a problem worth the maintenance cost?
- Could we write the small version we need?

### 11.2 Pinning

- Lock file (`pnpm-lock.yaml`) committed.
- Version ranges in `package.json` use caret (`^`) for libraries we trust to follow semver.
- Pin exact versions for security-critical packages (auth, crypto).

### 11.3 Updates

- Renovate or Dependabot for automated PR updates.
- Review and merge weekly.
- Major version updates: separate PR with testing.

---

## 12. Refactoring & Tech Debt

### 12.1 Boy Scout Rule

Leave the campsite cleaner than you found it. Small refactors as part of feature work are encouraged.

### 12.2 Larger Refactors

- Discuss in advance (issue or async chat).
- Separate from feature changes (don't bundle).
- Keep PR focused — "refactor X" should not change behavior.

### 12.3 Tech Debt Tracking

- Use a `TECH_DEBT.md` file in repo or a labeled issue tracker.
- Review monthly; budget some sprint capacity to debt.
- Don't let it become a wishlist; cull stale items.

---

## 13. On-Call & Incident Response

(Brief here; full procedures in Operations Runbook.)

- Engineers rotate on-call weekly.
- Sev1 (production down): acknowledge within 15 minutes; escalate per runbook.
- Post-incident review (blameless) within 1 week of any Sev1 or Sev2.

---

## 14. Standards Are Living

This document is versioned and amended via PR. Propose changes; debate in review; update when consensus reached. Don't silently violate.
