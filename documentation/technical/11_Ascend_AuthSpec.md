# Ascend — Authentication & Authorization Specification

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| Audience | Engineering team, security reviewer |

---

## 1. Overview

Ascend uses **server-side sessions** stored in Redis, identified by an opaque session token in an HTTP-only cookie. We chose this over JWT-in-cookie because it allows instant revocation (logout, password change, admin suspension) and simpler implementation.

Authentication factors:
1. **Email + password** with optional TOTP-based MFA
2. **Google SSO** (OAuth 2.0 Authorization Code flow with PKCE)

Authorization is performed per-request based on:
- Whether session is valid
- The user's persona, verification status, and admin role
- The specific resource and action being accessed

---

## 2. Password Storage

**Algorithm:** Argon2id via `argon2` npm package.

**Parameters (production):**
- Memory: 64 MiB (`memoryCost: 65536`)
- Iterations: 3 (`timeCost: 3`)
- Parallelism: 4 (`parallelism: 4`)
- Salt: 16 bytes random per password (handled by library)
- Hash length: 32 bytes

**Tuning:** parameters chosen to take ~150ms on production hardware. Re-evaluate annually.

**Validation rules:**
- Minimum 8 characters
- Must contain at least one letter and one number
- Maximum 128 characters (prevent DoS via massive inputs)
- No common-password check at MVP (consider adding HaveIBeenPwned API later)

```typescript
// packages/api/src/auth/password.ts
import argon2 from 'argon2';

const ARGON2_OPTIONS = {
  type: argon2.argon2id,
  memoryCost: 65536,
  timeCost: 3,
  parallelism: 4,
};

export async function hashPassword(plain: string): Promise<string> {
  return argon2.hash(plain, ARGON2_OPTIONS);
}

export async function verifyPassword(hash: string, plain: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, plain);
  } catch {
    return false;
  }
}

export function validatePasswordStrength(plain: string): ValidationResult {
  if (plain.length < 8) return { valid: false, reason: 'Too short (min 8 chars)' };
  if (plain.length > 128) return { valid: false, reason: 'Too long' };
  if (!/[a-zA-Z]/.test(plain)) return { valid: false, reason: 'Must contain a letter' };
  if (!/[0-9]/.test(plain)) return { valid: false, reason: 'Must contain a number' };
  return { valid: true };
}
```

---

## 3. Session Model

### 3.1 Session Lifecycle

**Creation (on login):**
1. Generate 32-byte random token via `crypto.randomBytes(32)`, base64url-encode → `sessionId`
2. Compute hash: `sha256(sessionId)` → `sessionKey` (we store the hash to limit damage if Redis is dumped)
3. Write to Redis: `session:{sessionKey}` with value `{ userId, createdAt, lastSeenAt, ipAddress, userAgent }`, TTL 30 days
4. Insert `SessionRecord` row in Postgres with the hash for audit purposes
5. Set cookie:
   ```
   Set-Cookie: session=<sessionId>; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=2592000
   ```

**Use (on every authenticated request):**
1. Extract cookie
2. Compute `sessionKey = sha256(cookie)`
3. Read `session:{sessionKey}` from Redis
4. If missing or expired → 401
5. If present, refresh `lastSeenAt` (debounced: only if > 5 min stale)
6. Sliding expiration: extend Redis TTL on each request

**Revocation:**
- **Logout:** delete `session:{sessionKey}` from Redis; remove SessionRecord
- **Password change:** delete all `session:*` for user; insert audit log
- **Admin suspend/ban:** same as password change
- **Token compromise (manual):** admin can delete sessions for any user

### 3.2 Session Configuration

| Parameter | Value |
|---|---|
| Cookie name | `session` |
| Max-Age | 30 days (2,592,000 seconds) |
| HttpOnly | true |
| Secure | true (production); false (local dev) |
| SameSite | Lax |
| Domain | `.ascend.rajagiritech.edu.in` (or actual prod domain) |
| Path | `/` |

**Why SameSite=Lax instead of Strict:** Strict would break OAuth callback flows (cookie not sent on top-level navigations from external origins). Lax balances CSRF protection and OAuth compatibility.

**Why not SameSite=None:** Would require Secure-only and we'd lose CSRF protection.

### 3.3 CSRF Protection

For state-changing requests (POST, PATCH, DELETE), in addition to the SameSite cookie:

- All such requests require a custom header (e.g., `X-Requested-With: ascend-web`) which the server validates. Browsers do not allow custom headers in simple form submissions, so this prevents CSRF via form replay.
- For requests crossing origins (none should at MVP), a CSRF token approach would be added.

---

## 4. Login Flow (Password)

```
[Client]                              [API]                        [Redis]      [Postgres]
   |                                    |                            |             |
   |--POST /auth/login {email, pw}----->|                            |             |
   |                                    |--SELECT user by email----->|             |
   |                                    |<--user (or null)-----------|             |
   |                                    |                            |             |
   |                                    |  if locked & lockedUntil>now: 403       |
   |                                    |                            |             |
   |                                    |--Argon2 verify password----|             |
   |                                    |  if invalid:               |             |
   |                                    |    increment failedLoginAttempts        |
   |                                    |    if >= 10: lock 30min    |             |
   |                                    |    return 401              |             |
   |                                    |                            |             |
   |                                    |  if MFA enabled:           |             |
   |                                    |    create mfaToken (5min)->|             |
   |                                    |    return 200 mfaRequired  |             |
   |                                    |                            |             |
   |                                    |  else:                     |             |
   |                                    |    create sessionId        |             |
   |                                    |    SET session:{key}------>|             |
   |                                    |    INSERT SessionRecord--------------->  |
   |                                    |    reset failedLoginAttempts             |
   |<--Set-Cookie + user info-----------|                            |             |
```

### 4.1 Account Lockout

**Trigger:** 10 failed login attempts within 30 minutes for the same email.

**Effect:** Account locked for 30 minutes. Lockout extends on further failed attempts during the lockout window. Successful login (after lockout expires) resets the counter.

**User experience:**
- Locked response: `403 ACCOUNT_LOCKED { "lockedUntil": "..." }`
- After 3 successive failures, return rate limit hint without revealing whether email exists
- After lockout, an email is sent to the account holder noting the failed attempts

**Why these numbers:** Lockout prevents brute force without making the system trivially DoS-able by attackers locking real users out. 10 attempts/30 min is the OWASP-recommended baseline.

### 4.2 Email Enumeration Prevention

For invalid email and invalid password, return identical responses:
```json
{ "error": { "code": "INVALID_CREDENTIALS", "message": "Email or password is incorrect" } }
```

Forgot-password endpoint always returns the same response regardless of whether email exists.

---

## 5. MFA (TOTP)

### 5.1 Setup Flow

1. User authenticated, requests `/auth/mfa/enable`
2. Server generates 32-byte secret via `crypto.randomBytes`; base32-encode for compatibility
3. Server stores **encrypted** secret in `User.mfaSecretEncrypted` (AES-256-GCM with key from secrets manager)
4. Server returns:
   - QR code data URI (otpauth URL containing the secret)
   - 10 single-use recovery codes (10 chars each, hashed and stored separately in `MfaRecoveryCode` table — schema add-on)
5. User scans QR with authenticator (Google Authenticator, Authy, 1Password, etc.)
6. User submits TOTP code via `/auth/mfa/verify`; server validates within ±1 step (30s window)
7. On successful verification, `User.mfaEnabled = true`

### 5.2 Login with MFA

After password verification:
1. Server creates a short-lived (5 min) `mfaToken` in Redis: `mfa:{token}` → `{ userId, expiresAt }`
2. Returns `200 MFA_REQUIRED { mfaToken }`
3. Client submits `/auth/login/mfa` with `mfaToken` and `code`
4. Server validates code; if valid, completes login (creates session); deletes `mfa:{token}`

### 5.3 Recovery Code Use

Same flow as TOTP code, but the recovery code consumes that code permanently (mark used in DB). Show user remaining count.

### 5.4 MFA Disable

Requires:
- Currently authenticated session
- Re-entering current password
- Audit log entry

---

## 6. Google SSO

### 6.1 OAuth Configuration

- **Authorization URL:** `https://accounts.google.com/o/oauth2/v2/auth`
- **Token URL:** `https://oauth2.googleapis.com/token`
- **Userinfo URL:** `https://www.googleapis.com/oauth2/v2/userinfo`
- **Scopes:** `openid email profile`
- **Response type:** `code`
- **Flow:** Authorization Code with PKCE

### 6.2 Sign-Up via SSO

```
1. Client → /auth/sso/google/initiate
   - Server generates state (random, stored in Redis 5min) and codeVerifier (PKCE)
   - Redirect to Google with state and codeChallenge

2. Google → /auth/sso/google/callback?code=...&state=...
   - Server validates state matches Redis
   - Exchange code for token using codeVerifier
   - Fetch userinfo
   - Decision branching based on email:
     a. Email ends @rajagiri.edu.in → create Student account (still requires manual student profile completion: branch, semester, batchYear)
     b. Email ends @rajagiritech.edu.in → create Faculty account (must complete department)
     c. Other email → redirect to alumni signup form pre-filled with name+email

3. Server creates session, returns user to dashboard
```

### 6.3 Sign-In via SSO

If user with that `googleSubjectId` exists, sign in directly. If not but email matches an existing account, prompt user to confirm linking (security against account takeover via SSO).

### 6.4 Linking Password Account to Google

If a user signed up with password, they can link Google later from settings. Re-authentication required (current password). Sets `googleSubjectId`.

### 6.5 Profile Completion After SSO

For SSO sign-ups that need additional profile data (branch, semester, etc.), a `profileComplete: false` flag on the user record gates platform access until they complete the missing fields.

---

## 7. Email Verification (for Password Signups)

1. On signup, generate 32-byte token; store hashed in `EmailVerificationToken` table (schema addition) with `userId`, `expiresAt = now + 24h`, `used = false`
2. Send email with link `https://app.ascend.../verify-email?token=...`
3. User clicks; server hashes token, looks it up, verifies not expired and not used, sets `User.emailVerifiedAt`, marks token used
4. Account is `verificationStatus = VERIFIED` for student/faculty (auto-verified by domain); alumni stay PENDING for admin review

**Tokens:** Single-use, 24h expiry. Resend allowed (invalidates previous).

---

## 8. Password Reset

1. User submits email → `/auth/forgot-password`
2. Always returns `200 { ok: true }` (no enumeration)
3. If account exists: generate token, send email with link, store hashed token with 1h expiry
4. User clicks → `/reset-password?token=...`
5. User submits new password
6. Server: validate token; verify password strength; update `User.passwordHash`; **invalidate all existing sessions for user**; mark token used
7. Email confirmation: "Your password was changed"

---

## 9. Authorization Matrix

Permissions evaluated per request via middleware. The following table shows resource × action × who-can.

### 9.1 Read Permissions

| Resource | Anyone | Authenticated | Same Dept | Author | Admin |
|---|---|---|---|---|---|
| Public pages (landing, help) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Question (institution-wide) | — | ✓ | ✓ | ✓ | ✓ |
| Question (department-only) | — | — | ✓ | ✓ | ✓ |
| Anonymous question identity | — | — | — | ✓ | ✓ |
| Post | — | ✓ | ✓ | ✓ | ✓ |
| Resource (Library) | — | ✓ | ✓ | ✓ | ✓ |
| Resource (Pending) | — | ✓ | ✓ | ✓ | ✓ |
| User profile (default) | — | ✓ | ✓ | ✓ | ✓ |
| User activity (when hideActivity=true) | — | — | — | ✓ | ✓ |
| DM thread | — | — | — | ✓ | ✓ (on report only) |
| Audit log | — | — | — | — | ✓ |

### 9.2 Write Permissions

| Action | Eligible |
|---|---|
| Ask question | Verified user (any persona) |
| Answer question | Verified user passing Dynamic Seniority Engine |
| Edit question | Author |
| Edit answer | Author |
| Delete question | Author (when no answers) or admin |
| Delete answer | Author (when not accepted) or admin |
| Accept answer | Question author |
| Endorse answer | Faculty |
| Endorse resource | Faculty |
| Post Faculty Announcement | Faculty |
| Submit resource | Verified user |
| Send connection request | Verified user (subject to limits) |
| Block user | Verified user |
| Suspend / ban user | Admin |
| Override persona | Admin |
| Manage tags | Admin |
| Archive question | Admin |

### 9.3 Implementation Pattern

Authorization is implemented as middleware functions composing permission checks:

```typescript
// packages/api/src/middleware/auth.ts

export const requireAuth: RequestHandler = async (req, res, next) => {
  const user = await loadUserFromSession(req);
  if (!user) return res.status(401).json({ error: ... });
  req.user = user;
  next();
};

export const requireVerified: RequestHandler = async (req, res, next) => {
  if (req.user.verificationStatus !== 'VERIFIED') {
    return res.status(403).json({ error: { code: 'NOT_VERIFIED' } });
  }
  next();
};

export const requireAdmin: RequestHandler = async (req, res, next) => {
  if (!req.user.isAdmin) return res.status(403).json({ error: { code: 'NOT_ADMIN' } });
  next();
};

export const requireFaculty: RequestHandler = async (req, res, next) => {
  if (req.user.persona !== 'FACULTY') {
    return res.status(403).json({ error: { code: 'NOT_FACULTY' } });
  }
  next();
};

// Per-resource checks live in route handlers
async function canEditAnswer(user: User, answerId: string): Promise<boolean> {
  const answer = await prisma.answer.findUnique({ where: { id: answerId } });
  return answer?.authorId === user.id;
}
```

---

## 10. Dynamic Seniority Engine

Pure function, easily testable:

```typescript
// packages/api/src/auth/seniority.ts

interface SeniorityCheckInput {
  viewer: {
    persona: Persona;
    semester?: number;       // for STUDENT
    verificationStatus: VerificationStatus;
  };
  asker: {
    persona: Persona;
    semester?: number;       // for STUDENT
  };
}

export function canAnswer(input: SeniorityCheckInput): { eligible: boolean; reason?: string } {
  const { viewer, asker } = input;

  if (viewer.verificationStatus !== 'VERIFIED') {
    return { eligible: false, reason: 'Not verified' };
  }

  // Alumni and Faculty can always answer
  if (viewer.persona === 'ALUMNUS') return { eligible: true };
  if (viewer.persona === 'FACULTY') return { eligible: true };

  // Former students can browse but not answer
  if (viewer.persona === 'FORMER_STUDENT') {
    return { eligible: false, reason: 'Former students cannot answer questions' };
  }

  // Students: must be at least 2 semesters senior to asker
  if (viewer.persona === 'STUDENT') {
    // Asker is faculty/alumnus → any verified student can answer
    if (asker.persona === 'FACULTY' || asker.persona === 'ALUMNUS') {
      return { eligible: true };
    }
    // Asker is student
    if (asker.persona === 'STUDENT' && asker.semester !== undefined && viewer.semester !== undefined) {
      if (viewer.semester >= asker.semester + 2) {
        return { eligible: true };
      }
      return {
        eligible: false,
        reason: `You'll be eligible to answer this asker's questions when you reach semester ${asker.semester + 2}`,
      };
    }
  }

  return { eligible: false, reason: 'Not eligible' };
}
```

This function MUST be unit-tested exhaustively — it is a critical piece of platform behavior.

---

## 11. Threat Model & Mitigations

| Threat | Mitigation |
|---|---|
| Password brute force | Argon2id, account lockout, rate limiting |
| Credential stuffing | Account lockout, MFA encouraged, monitor for spike patterns |
| Session hijacking | HttpOnly cookies, Secure flag, IP/UA check on suspicious activity |
| CSRF | SameSite=Lax + custom header check on mutations |
| XSS | Content Security Policy, markdown sanitization, no inline scripts |
| Email enumeration | Identical responses for invalid email and invalid password |
| Phishing for OAuth | State parameter validation, PKCE |
| Account takeover via OAuth linking | Require re-authentication to link |
| Token leakage in logs | Never log raw cookies or tokens; log session hash only |
| MFA bypass | Recovery codes single-use, MFA disable requires re-auth |
| Time-based attacks on TOTP | ±1 step window only, replay window enforced |

---

## 12. Audit Logging for Auth Events

Every auth event creates an `AuditLogEntry` (or equivalent application log):

| Event | Logged |
|---|---|
| Login success | userId, ip, ua |
| Login failure | email (hashed), ip, reason |
| Logout | userId |
| Password reset request | email (hashed), ip |
| Password change | userId, ip |
| MFA enable | userId |
| MFA disable | userId |
| MFA failure | userId, ip |
| OAuth link | userId, provider |
| OAuth login | userId, provider |
| Session forced revoke | userId, by-actor |

Failed login attempts log a hash of the email rather than the email itself (avoids PII spillage in logs).

---

## 13. Open Decisions for Engineering

- **Auth library or custom:** This spec assumes custom. If the team prefers Lucia (which provides session primitives without opinions on signup flow), the spec maps cleanly to it.
- **Recovery code count:** 10 is a default; could be higher.
- **Session sliding window:** Refresh `lastSeenAt` debounced to 5 min — confirm this is acceptable.
- **Cookie domain:** Confirm production domain; may need wildcard for subdomain support.
- **Sentry sensitive data scrubbing:** Configure `beforeSend` to strip cookies, headers with auth, and request bodies of auth endpoints.
