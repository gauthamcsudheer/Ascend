# Ascend — Security Implementation Checklist

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Engineering team, security reviewer |
| Purpose | Concrete checklist of security controls to implement and verify before launch |

> This is operational, not aspirational. Each item is something to **verify** before a launch sign-off, not just to read.

---

## 1. Authentication & Session Security

- [ ] Passwords hashed with Argon2id; parameters per Auth Spec § 2
- [ ] Password validation enforces minimum length (8) and character classes
- [ ] Session tokens are 32-byte random; stored in Redis as sha256 hash
- [ ] Session cookies: `HttpOnly`, `Secure` (prod), `SameSite=Lax`, scoped to app domain
- [ ] Sessions revocable on: logout, password change, admin action, MFA disable
- [ ] Account lockout after 10 failed login attempts in 30 minutes; 30-minute lock window
- [ ] Lockout extended on continued failures during the lockout window
- [ ] Login response identical for invalid email vs invalid password (no enumeration)
- [ ] Forgot-password response identical regardless of email existence
- [ ] Email verification tokens are single-use, 24h TTL
- [ ] Password reset tokens are single-use, 1h TTL; invalidate all sessions on reset
- [ ] MFA secrets encrypted at rest with AES-256-GCM using key from Secrets Manager
- [ ] MFA recovery codes are single-use; hashed in DB
- [ ] OAuth state parameter validated against Redis; PKCE implemented
- [ ] OAuth account linking requires re-authentication
- [ ] Failed login attempts logged with hashed email (not plaintext)

---

## 2. Authorization

- [ ] Every authenticated endpoint enforces session validity via middleware
- [ ] Admin-only endpoints enforce `requireAdmin` middleware
- [ ] Faculty-only actions (endorse answer, post announcement) check persona
- [ ] Resource ownership checks happen server-side; client-provided IDs never trusted
- [ ] Dynamic Seniority Engine enforced server-side on every answer attempt
- [ ] Verification status (PENDING / VERIFIED / LOCKED) gates access per spec
- [ ] Block relationships consulted before allowing direct interaction (DM, mentions, connection)
- [ ] Soft-deleted users cannot perform any action
- [ ] Suspended users cannot perform write actions; can read

---

## 3. Input Validation

- [ ] All API inputs validated with Zod schemas at the boundary
- [ ] String length limits enforced per spec (titles 120, bodies 2000-15000, etc.)
- [ ] Email format validated; domain checks for student/faculty signups
- [ ] URL fields validated against allowed schemes (HTTPS only for resources)
- [ ] UUIDs/CUIDs validated by format; unparseable IDs return 400 not 500
- [ ] Numeric inputs bounded (no negative semesters, no future batch years > current+10)
- [ ] Enum values validated against the actual enum
- [ ] No string-passthrough for fields that should be enums or IDs
- [ ] File uploads: not applicable at MVP (no media uploads), but if added: MIME type + magic byte validation, size limit, scan for malicious content

---

## 4. Output Encoding & XSS

- [ ] All user-rendered content goes through React (auto-escaping); no manual HTML strings
- [ ] `dangerouslySetInnerHTML` allowed only for sanitized markdown output
- [ ] Markdown rendering uses markdown-it with strict allowlist (per ADR-012)
- [ ] No raw HTML in markdown source allowed
- [ ] No images via `![]()` syntax (no embedded external images)
- [ ] Code blocks server-side syntax highlighted; no JS execution
- [ ] User-supplied URLs (LinkedIn, profile) validated and rendered with `rel="nofollow noopener"`
- [ ] Content Security Policy header set:
  - `default-src 'self'`
  - `script-src 'self'` (with nonce for inline if needed)
  - `style-src 'self' 'unsafe-inline'` (Tailwind)
  - `img-src 'self' data:` (no external images)
  - `connect-src 'self' wss://...`
  - `frame-ancestors 'none'`
- [ ] `X-Frame-Options: DENY` header
- [ ] `X-Content-Type-Options: nosniff` header
- [ ] `Referrer-Policy: strict-origin-when-cross-origin` header

---

## 5. CSRF Protection

- [ ] Cookies set with `SameSite=Lax`
- [ ] State-changing endpoints (POST/PATCH/DELETE) require custom header (`X-Requested-With: ascend-web`)
- [ ] Browser cannot set the custom header in simple form submissions; this prevents form-based CSRF
- [ ] Logout endpoint accepts POST only (not GET)

---

## 6. SQL Injection

- [ ] All DB access via Prisma (parameterized by default)
- [ ] Raw SQL uses tagged template literals (`$queryRaw`); no string concatenation with user input
- [ ] Search queries use Prisma's safe parameter binding even for tsvector queries
- [ ] No `eval` or dynamic query construction from user input

---

## 7. SSRF (Open Graph Fetcher & Link Checker)

Per ADR-013:

- [ ] OG fetcher rejects URLs that resolve to private IP ranges:
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
  - 127.0.0.0/8
  - 169.254.0.0/16 (link-local + AWS metadata)
  - ::1, fc00::/7, fe80::/10
- [ ] Hostname resolved before HTTP request; library not allowed to resolve internally
- [ ] Redirects followed only to same protections (re-check IP after redirect)
- [ ] Maximum 3 redirects
- [ ] Maximum 5MB response size; truncate after
- [ ] Maximum 5-second timeout
- [ ] HTTPS only; HTTP rejected
- [ ] No cookies or auth headers forwarded
- [ ] Link checker uses same protections
- [ ] Worker IAM role has no AWS metadata access (instance metadata blocked)
- [ ] Failures logged but not exposed verbatim to user

---

## 8. Rate Limiting

- [ ] Auth endpoints (login, signup, forgot-password): 10/hour/IP
- [ ] Content creation: 10/hour/user
- [ ] Comments: 30/hour/user
- [ ] Votes: 200/hour/user
- [ ] Connection requests: 10/day/user
- [ ] Search: 60/minute/user
- [ ] Generic authenticated: 1000/hour/user
- [ ] Limits use Redis-backed sliding window
- [ ] `429` responses include `Retry-After` header
- [ ] Limits are per-IP for unauth and per-userId for auth (tracking both prevents trivial bypass)

---

## 9. Secrets Management

- [ ] Production secrets in AWS Secrets Manager
- [ ] App reads secrets at boot via IAM-authenticated SDK call
- [ ] No secrets in environment variables of running processes (other than at boot)
- [ ] No secrets in container images
- [ ] No secrets in Git history (verify with git-secrets or similar)
- [ ] `.env` files gitignored
- [ ] Secrets rotation schedule defined (DB password annually, OAuth secrets on demand, JWT keys quarterly)
- [ ] Compromise procedure documented (Operations Runbook)

---

## 10. PII & Data Protection

- [ ] User personal data stored in India (DPDP requirement; AWS ap-south-1)
- [ ] Audit log entries minimize PII (hashed email for failed logins)
- [ ] Sentry configured to scrub PII (email, name, body content) via `beforeSend` hook
- [ ] CloudWatch logs do not contain plaintext passwords, cookies, tokens
- [ ] Data export endpoint provides user's data in machine-readable format
- [ ] Account deletion process (anonymize or hard-delete) implemented per spec
- [ ] 14-day grace period before deletion finalization
- [ ] Backups encrypted at rest (RDS automated; S3 SSE)
- [ ] All transit encrypted (TLS 1.2+ at ALB; encrypted intra-VPC where possible)

---

## 11. Audit Logging

- [ ] AuditLogEntry table is append-only at the DB role level (REVOKE UPDATE/DELETE)
- [ ] Every admin action creates an audit entry: actor, action, target, metadata, timestamp
- [ ] Audit entries archived daily to S3 (immutable bucket with versioning)
- [ ] Admin can search audit logs by actor, target, action, date range
- [ ] Failed admin actions also logged
- [ ] Auth events logged separately (login success/failure, password change, MFA changes)

---

## 12. Email Security

- [ ] SPF, DKIM, DMARC configured on sending domain
- [ ] DMARC policy starts at `p=none` for monitoring; advance to `p=quarantine` then `p=reject` after 30 days of clean reports
- [ ] Bounce and complaint handling via SES → SNS → API webhook
- [ ] Hard bounces → suppress further mail to that address; flag for review
- [ ] Unsubscribe link in every digest email (legal requirement)
- [ ] Transactional emails do not include unsubscribe (verification, password reset)
- [ ] Email content does not include sensitive data (full session info, passwords)

---

## 13. Dependency Security

- [ ] `pnpm audit` runs in CI; high/critical findings block merge
- [ ] Dependabot or Renovate configured for automated updates
- [ ] Critical security patches applied within 72 hours of disclosure
- [ ] No untrusted packages (verify maintainer, popularity, last update before adding)

---

## 14. Infrastructure Security

- [ ] VPC with public/private/db subnet separation
- [ ] App instances in private subnet; only ALB in public
- [ ] Database not internet-accessible; security group restricts to app subnets
- [ ] Redis not internet-accessible
- [ ] All ports closed except necessary (22 SSH only via bastion or Session Manager)
- [ ] EC2 instances have IAM roles, not access keys
- [ ] Sensitive worker (OG fetcher) in even more restricted IAM role
- [ ] CloudTrail enabled for AWS API activity
- [ ] AWS Config rules for security baselines
- [ ] GuardDuty or equivalent threat detection enabled (or budgeted)

---

## 15. Web Push Security

- [ ] VAPID keys generated and stored in Secrets Manager
- [ ] Push subscriptions stored per-user; unique by endpoint
- [ ] Subscriptions auto-removed on permanent failure (HTTP 410)
- [ ] Push payloads do not contain sensitive content (use generic message + deep link)

---

## 16. Account Recovery & Lifecycle

- [ ] Forgot-password generates new token; invalidates old tokens
- [ ] Password reset invalidates all sessions
- [ ] Email change requires confirmation from both old and new addresses
- [ ] MFA reset requires identity verification (admin process, not self-service)
- [ ] Suspension and ban actions revoke all active sessions

---

## 17. Admin Security

- [ ] First admin bootstrapped via documented process (env-driven seed)
- [ ] Admins have separate audit visibility on their own actions
- [ ] Admin actions on a target user are visible to that user (per `/api/v1/privacy/account-activity`)
- [ ] Cannot remove the last admin
- [ ] Admin role grant/revoke creates audit entry
- [ ] MFA strongly recommended (and ultimately required) for all admin accounts

---

## 18. Privacy Compliance (DPDP)

- [ ] Privacy policy linked at signup; acceptance recorded
- [ ] Privacy policy version tracked; changes notify users
- [ ] Data residency in India (verified per ADR-009)
- [ ] DPO contact published in privacy policy (when required by thresholds)
- [ ] Data export within 7 days of request (operationally tracked)
- [ ] Account deletion within 14 days of request (system-enforced)
- [ ] Breach notification process documented and tested
- [ ] Data Processing Agreement with AWS in place (standard)
- [ ] Sub-processor list documented (Sentry, SES, OAuth providers)

---

## 19. Browser Hardening

- [ ] HSTS header: `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- [ ] Submit domain to HSTS preload list after stable HSTS in production for 30 days
- [ ] Cookies marked with `__Host-` prefix where applicable
- [ ] No mixed content (all assets HTTPS)
- [ ] Service worker registered only over HTTPS
- [ ] PWA manifest does not request unnecessary permissions

---

## 20. Pre-Launch Security Sign-Off

Before launching to users:

- [ ] All items above checked off
- [ ] Penetration test conducted (internal or third-party)
- [ ] Critical and high findings remediated
- [ ] Vulnerability disclosure policy published (`SECURITY.md` in repo with contact)
- [ ] Incident response runbook reviewed (Operations Runbook)
- [ ] On-call rotation established
- [ ] Backup and restore procedure verified end-to-end (test restore from production backup to staging)
- [ ] Security monitoring alerts configured (failed logins, admin action spikes, error rate spikes)

---

## 21. Ongoing Security Practices (Post-Launch)

- [ ] Quarterly security review (this checklist re-walked)
- [ ] Annual third-party security audit (when budget allows)
- [ ] Dependency audits weekly
- [ ] Log review for anomalies (admin can build dashboards from audit log)
- [ ] User-reported security issues triaged within 48 hours

---

## 22. Threat Model Quick-Reference

| Asset | Primary Threats | Primary Controls |
|---|---|---|
| User account | Brute force, credential stuffing | Argon2, lockout, MFA, breach monitoring |
| Sessions | Hijack, fixation | HttpOnly cookies, IP/UA tracking, instant revocation |
| User data (PII) | Unauthorized access, exfiltration | Authorization, audit, encryption at rest, scoped IAM |
| Content (Q, A, posts) | Spam, harassment, defamation | Reports, moderation, rate limits, suspension |
| Reputation system | Gaming via sock puppets, vote manipulation | Self-vote prevention, vote rate limits, monitoring |
| Admin tools | Malicious admin, compromised admin account | Audit log, MFA required, action visibility to user |
| Infra (DB, Redis) | External access, AWS account compromise | VPC isolation, IAM least privilege, MFA on AWS |
| OG/link fetcher | SSRF to internal services | Strict allowlist, IP filtering, isolated worker |
| Email pipeline | Spoofing, deliverability issues | SPF/DKIM/DMARC, bounce handling |

---

## 23. Files to Maintain

- `SECURITY.md` in repo root: vulnerability disclosure policy, contact email
- `docs/security-runbook.md` (extends Operations Runbook): incident response procedures
- This checklist: re-walked quarterly, updated as the product evolves
