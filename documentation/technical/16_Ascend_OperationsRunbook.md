# Ascend — Operations Runbook

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Engineering team, on-call |
| Purpose | Keep services running. Procedures for routine ops, incidents, and disaster recovery. |

> When an incident is happening, this is the doc to open first. Procedures here are concrete and step-by-step.

---

## 1. Environment Inventory

### 1.1 Production (`ascend-prod`)
- AWS account: `<account-id-prod>`
- Region: `ap-south-1` (Mumbai)
- Domain: `ascend.rajagiritech.edu.in` (or actual launched domain)
- Components:
  - ALB: `ascend-prod-alb`
  - EC2 Web/API: 2x `t3.medium` in private subnets
  - EC2 Worker: 1x `t3.small` in private subnet
  - RDS Postgres: `db.t3.medium` Multi-AZ
  - ElastiCache Redis: `cache.t3.micro`
  - S3 buckets: `ascend-prod-audit`, `ascend-prod-exports`
  - CloudWatch log group: `/ascend/prod`

### 1.2 Staging (`ascend-staging`)
- AWS account: same or separate; recommended separate
- Smaller instance sizes; otherwise mirrors prod topology
- Domain: `staging.ascend.rajagiritech.edu.in`
- Used for: pre-prod QA, migration testing, integration testing

### 1.3 Local Development
- Docker Compose; see Project Structure doc

---

## 2. Access & Credentials

### 2.1 AWS Access
- **Console:** SSO via institution IdP (when available); IAM users with MFA otherwise
- **CLI:** AWS Session Manager preferred (`aws ssm start-session`); SSH disabled in production
- **Programmatic:** IAM roles on EC2; no long-lived access keys on instances

### 2.2 Application Access
- Production database: only via Session Manager → bastion-style EC2 with `psql` installed; or via Prisma Studio over Session Manager port-forward
- Production Redis: same access pattern
- Bull Board: `https://<api-domain>/admin/queues` — admin auth required

### 2.3 Secrets
- **AWS Secrets Manager** holds all production secrets
- Naming convention: `ascend/prod/<service>/<key>` (e.g., `ascend/prod/db/password`)
- Rotation: documented per secret in Secrets Manager metadata

---

## 3. Deployment Procedure

### 3.1 Standard Deploy (Main → Production)

Trigger: PR merged to `main` after CI passes.

**Automated steps (GitHub Actions):**
1. Build Docker images for `web`, `api`, `worker`
2. Tag images with git commit SHA + `latest`
3. Push to ECR (`ascend-prod` registry)
4. Apply DB migrations against staging; run smoke tests
5. **Manual approval** required to proceed to production
6. Apply DB migrations against production
7. Update target group / docker-compose on each EC2 instance to pull new images
8. Rolling restart: instance 1 drains → restart → health check passes → instance 2 same
9. Worker EC2 restart (graceful shutdown waits for in-flight jobs)
10. Post-deploy smoke tests run
11. Slack notification on success/failure

### 3.2 Hotfix Deploy

For urgent fixes:
1. Cherry-pick or branch from `main`
2. Open PR; expedited review (1 approver, abbreviated review)
3. Same automated pipeline; skip manual approval is **NOT** allowed even for hotfixes (1-line override possible by senior engineer with audit trail)

### 3.3 Rollback

If a deploy causes issues:

**Option A — Code rollback (no DB change):**
```bash
# On each EC2 instance via Session Manager
docker pull <ecr-url>:<previous-sha>
docker compose down
docker compose up -d  # uses previous tag
```
Or trigger rollback workflow in GitHub Actions specifying the previous SHA.

**Option B — Code + DB rollback:**
- Forward-only migrations mean DB rollback usually requires restore from backup
- Decision tree:
  - Is the DB change additive (new column with default)? → roll back code only; new column harmless
  - Is the DB change destructive or breaking? → restore DB from latest snapshot (loses recent data); roll back code
- Restoring from snapshot is significant; communicate user impact

### 3.4 Migration Safety

- Migrations applied **before** new code is deployed
- New migrations should be backward-compatible with previous code (nullable additions, etc.)
- Breaking changes use multi-deploy pattern (per Engineering Standards § 10.3)

---

## 4. Routine Operations

### 4.1 Daily
- Check CloudWatch dashboards for anomalies
- Triage Sentry errors (assign or dismiss)
- Review Bull Board for failed jobs
- Verify daily audit log archive succeeded (S3 file present)
- Verify daily backups present in RDS console

### 4.2 Weekly
- Review dependency update PRs (Renovate/Dependabot)
- Triage user-reported issues
- Review on-call handoff notes
- Check disk usage on EC2 (logs, ephemeral data)

### 4.3 Monthly
- Review monitoring alert thresholds (false positives? missed incidents?)
- Review CloudWatch costs and log retention
- Run security checklist spot-check (sample items)
- Verify DR backup restoration on staging

### 4.4 Quarterly
- Full security checklist walk
- Penetration testing (external where budgeted, internal otherwise)
- Capacity review: are we approaching scale thresholds?
- Cost review

---

## 5. Monitoring & Alerts

### 5.1 What We Monitor

**Infrastructure (CloudWatch):**
- EC2 CPU > 80% for 5 min → warning
- EC2 memory > 85% for 5 min → warning
- RDS CPU > 80% for 5 min → warning
- RDS connections > 80% of max → warning
- RDS storage > 80% → critical
- RDS replica lag > 30s → warning
- ElastiCache memory > 80% → warning
- ElastiCache evictions > 0 → warning
- ALB 5xx rate > 1% over 5 min → critical
- ALB target health < 100% → warning

**Application (CloudWatch + custom metrics):**
- API p95 response time > 1s for 10 min → warning
- API p95 response time > 3s for 5 min → critical
- Error log rate > baseline + 50% → warning
- Sentry error rate spike → warning (Sentry alert)

**Business Metrics (custom):**
- Failed login spike (potential attack) → warning
- Admin action spike (potential compromise) → warning
- Notification queue depth > 5000 for > 10 min → warning
- DLQ count > 0 in any queue → warning
- Alumni verification queue age > 5 days → warning

### 5.2 Alert Routing

- **Critical alerts:** PagerDuty (or simpler equivalent) → on-call phone
- **Warnings:** Slack channel `#ascend-alerts`
- **Sentry:** routes to email + Slack

### 5.3 Sample Dashboards

**Service Health Dashboard:**
- Request rate, error rate, p50/p95/p99 response time
- Active sessions (from Redis)
- DB connection pool usage
- Worker queue depths

**Business Health Dashboard:**
- Daily signups by persona
- Daily active users
- Questions asked / answered (with acceptance rate)
- Reports filed / resolved
- Notifications sent

---

## 6. Incident Response

### 6.1 Severity Definitions

| Severity | Definition | Response |
|---|---|---|
| Sev1 | Production fully down or critical feature broken for all users | Acknowledge < 15 min; all hands; status page update |
| Sev2 | Significant degradation; subset of users affected | Acknowledge < 30 min; on-call leads |
| Sev3 | Minor issue; workaround available | Next business day |

### 6.2 Sev1 Procedure

1. **Acknowledge** in PagerDuty or alert channel within 15 minutes
2. **Open incident channel** (Slack or equivalent) `#incident-YYYYMMDD-HHMM-shortname`
3. **Assign roles:**
   - Incident Commander (drives the response)
   - Investigator (looks at logs, metrics)
   - Communicator (status page, internal updates)
4. **Triage in this order:**
   a. Is it real? (check from external monitoring; not just our internal alert)
   b. What's the user impact? (which feature, how many users)
   c. What changed recently? (last deploy, last config change)
5. **Mitigate before diagnose:**
   - If recent deploy: roll back
   - If recent config: revert
   - If unknown: scale up; restart instances
6. **Update communicators every 15 minutes** while incident is active
7. **Resolve** when user impact ends; declare end-of-incident
8. **Post-incident review** within 1 week (blameless)

### 6.3 Common Incidents & First Responses

#### Database CPU spike
- Check slow query log: `SELECT * FROM pg_stat_activity WHERE state = 'active' ORDER BY query_start ASC;`
- Identify long-running queries; consider canceling: `SELECT pg_cancel_backend(<pid>);`
- Look for missing indexes; check recent code changes for N+1 patterns

#### Redis unavailable
- Verify ElastiCache cluster status in AWS Console
- Check connectivity from app instances: `redis-cli -h <host> ping`
- App should degrade gracefully (cache miss → DB; sessions broken until restored)
- If failover needed: promote replica or restore from backup

#### High error rate from API
- Check Sentry for error patterns
- Check recent deploys; consider rollback
- Check downstream dependencies (DB, Redis, SES, Google OAuth)

#### Stuck background jobs
- Bull Board shows queue depth; identify which queue
- Check worker process logs
- If a single bad job: remove or DLQ it
- If broader issue: investigate code path

#### Sudden traffic spike
- Check ALB metrics for source distribution
- If suspicious (spike from few IPs): rate limit / block at WAF/security group
- If legitimate: scale up EC2 capacity (vertical first); add instances if needed

#### Login failures spike
- Possible credential stuffing attack
- Check IPs and patterns in audit log
- Block offending IPs; tighten rate limits temporarily
- Notify users if breach suspected

#### Admin account compromise suspected
- Immediately: revoke admin role and all sessions for the suspected account
- Audit log: review actions in last 30 days
- Reset password, MFA; have user re-authenticate
- Consider scope of damage; restore content from backups if needed

---

## 7. Disaster Recovery

### 7.1 Recovery Objectives
- **RTO (Recovery Time Objective):** 4 hours from declaration to restored service
- **RPO (Recovery Point Objective):** 24 hours of data loss maximum (daily backups)

### 7.2 Backup Inventory
- **RDS automated backups:** retained 30 days, point-in-time recovery to any second within window
- **RDS manual snapshots:** monthly, retained 1 year, copied to alternate region (`ap-southeast-1` Singapore)
- **S3 audit log archives:** versioned, 7-year retention
- **Code:** GitHub (multiple regions by GitHub's design)
- **Secrets:** Secrets Manager (regional service; consider cross-region replication for criticals)

### 7.3 DR Scenarios

#### Single AZ failure
- RDS Multi-AZ handles automatically (~60-120s downtime)
- EC2: ALB removes failing AZ targets; remaining AZ instances serve traffic
- ElastiCache: not Multi-AZ at MVP; downtime until restored

**Action:** monitor; allow auto-recovery; communicate if user-visible.

#### Region-wide outage in `ap-south-1`
- AWS regions are designed not to fail simultaneously, but it has happened
- We do not have hot standby in another region
- Recovery procedure:
  1. Restore latest RDS snapshot to `ap-southeast-1`
  2. Provision new EC2 + ALB in alternate region
  3. Update DNS (Route 53) to point to alternate region
  4. Note DPDP implications: this is emergency-only; communicate with users; restore to ap-south-1 ASAP

**Estimated time: 4-6 hours for the above.** Documented for completeness; this is "break glass."

#### AWS account compromise
- Immediately: rotate all credentials; revoke all IAM users/roles; review CloudTrail
- Restore service in a new clean account if needed
- This is a multi-day recovery in worst case

#### Data corruption (logical)
- Examples: bug deletes content; bad migration corrupts data
- Restore RDS to point in time before corruption
- Compare data; selectively re-import what was correct
- Communicate with affected users

### 7.4 DR Drill Schedule

- **Quarterly:** restore latest production snapshot to staging; verify app boots and key flows work
- **Annually:** simulate region-failure scenario (table-top exercise initially; live test as team matures)

---

## 8. Capacity Planning

### 8.1 Scale Triggers (When to Scale Up)

| Metric | Threshold | Action |
|---|---|---|
| EC2 CPU sustained > 70% | for 1 hour | Vertical scale (next size up) |
| EC2 memory sustained > 75% | for 1 hour | Vertical scale or memory profile |
| RDS CPU sustained > 60% | for 1 day | Plan vertical scale; investigate query patterns |
| RDS connections > 70% of max | for 1 hour | Increase max connections or add pooler |
| RDS storage > 70% | trigger | Increase storage (online operation) |
| Redis memory > 75% | for 1 day | Vertical scale |
| WebSocket connections > 5000 | sustained | Add API instance; verify Redis adapter |
| Background job queue depth growing | trend | Add worker instance or increase concurrency |

### 8.2 Cost Watch

- Monthly cost report reviewed
- Top cost drivers identified
- Tagged resources for cost allocation
- Reserved instances purchased after 6 months of stable usage

---

## 9. Database Operations

### 9.1 Common Queries

**Active connections:**
```sql
SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state;
```

**Long-running queries:**
```sql
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '30 seconds'
ORDER BY duration DESC;
```

**Table sizes:**
```sql
SELECT
  schemaname || '.' || tablename AS table,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS size
FROM pg_tables WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;
```

**Index health:**
```sql
SELECT schemaname, relname, indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY relname;
-- Indexes never used; candidates for removal
```

### 9.2 Vacuum & Maintenance
- Autovacuum enabled (RDS default)
- Manual `VACUUM ANALYZE` after large bulk operations
- Monitor `pg_stat_user_tables.n_dead_tup` for tables with high churn

### 9.3 Schema Changes in Production
- Apply during low-traffic window (early morning IST)
- Test on staging first
- For large tables, prefer `CREATE INDEX CONCURRENTLY` over inline migration
- Have rollback or restore plan ready

---

## 10. Email Operations

### 10.1 SES Setup
- Verify sending domain in SES console
- Configure SPF, DKIM, DMARC DNS records
- Move out of sandbox to production sending limits
- Configure SNS topics for bounces and complaints; subscribe API webhook

### 10.2 Bounce Handling
- Hard bounces: mark email address as "blocked" in DB; don't send further
- Soft bounces: retry per BullMQ schedule; mark blocked after 5 consecutive
- Complaints: immediately unsubscribe user from all email; flag for review

### 10.3 Deliverability Monitoring
- Track bounce rate (target < 5%); SES will pause sending if exceeded
- Track complaint rate (target < 0.1%)
- Monitor sender reputation in SES console

---

## 11. Logging Operations

### 11.1 Log Retention
- CloudWatch logs: 30 days (review and adjust based on cost)
- S3 archived audit logs: 7 years (DPDP retention floor)
- Sentry: per plan (90 days typically)

### 11.2 Log Volume Watch
- Excessive logging is a cost driver
- If volume spikes: identify the source endpoint; reduce log verbosity for that path

### 11.3 Log Search
- CloudWatch Logs Insights for querying:
```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
```

---

## 12. User Support Procedures

### 12.1 Account Issues

**User can't log in:**
- Verify account exists (check by email in admin tools)
- Check verification status
- Check lockout state; if locked, can clear from admin panel
- If MFA issue: admin can reset (audit logged); user must re-enroll

**User wants account deleted:**
- Direct to in-app deletion (`/api/v1/privacy/account-delete`)
- For DPDP-compliant hard delete, the system handles it
- If user can't access account, manual identity verification required

**User claims content was wrongly removed:**
- Check audit log for the removal
- Check report records
- If error, content can be restored from soft-delete (within retention window)

### 12.2 Verification Backlog

- Target: alumni verifications complete within 3 days
- Daily admin task to triage `/admin/verifications/pending`
- Bulk approval if pattern verified (e.g., 20 from same batch with same evidence)

---

## 13. On-Call Rotation

### 13.1 Schedule
- 1 week rotations
- Handoff at Monday 9 AM IST
- Holiday/PTO swaps coordinated in advance

### 13.2 On-Call Responsibilities
- Acknowledge alerts within SLA
- Triage incidents
- Document findings in incident channel
- Hand off open issues to next on-call with summary

### 13.3 On-Call Tools
- PagerDuty (or simpler tool) on phone
- Slack on phone for incident channels
- VPN client for accessing AWS Session Manager
- This runbook bookmarked

---

## 14. Communication During Incidents

### 14.1 Internal
- Slack channel for the incident
- Updates every 15 minutes during active incident
- Post-incident summary within 24 hours

### 14.2 External (User-Facing)
- Status page (when established): `status.ascend.rajagiritech.edu.in`
- Banner in app for known degradation
- Email to all users only for major incidents (>1 hour, >50% users affected, data loss)

### 14.3 Sample Status Update Templates

**Initial (investigating):**
> We're aware of issues with [feature]. Our team is investigating. Updates in 15 minutes.

**Mitigated:**
> The issue with [feature] has been mitigated. We're monitoring to ensure stability. We'll share a full update soon.

**Resolved:**
> The issue affecting [feature] is resolved. We'll share a post-mortem within the week. Thank you for your patience.

---

## 15. Useful Commands Quick-Reference

### AWS Session Manager into instance
```bash
aws ssm start-session --target <instance-id> --region ap-south-1
```

### View live API logs
```bash
docker logs -f ascend-api
# or via CloudWatch:
aws logs tail /ascend/prod/api --follow
```

### Connect to production DB (read-only via psql)
```bash
# After Session Manager into a bastion or app instance
psql $DATABASE_URL_READONLY
```

### Force-restart a service
```bash
docker compose restart api
# or for full container replacement:
docker compose pull && docker compose up -d
```

### Bull Board access (admin only)
```
https://api.ascend.rajagiritech.edu.in/admin/queues
```

### Trigger a manual job (from worker instance)
```bash
docker exec -it ascend-worker node dist/scripts/trigger-rep-decay.js
```

---

## 16. Open Items for Operations Team

These are intentionally undefined here; the engineering/ops team firms up before/during launch:

- **Status page tool:** Statuspage.io, BetterStack, or self-hosted? Decision before launch.
- **PagerDuty alternative:** Opsgenie, Better Stack, or simpler email-to-SMS? Cost vs features.
- **Backup region cross-region copy frequency:** Daily? Weekly?
- **WAF strategy:** AWS WAF rules at ALB? Specific rule set?
- **Log query budgets:** at what log volume do we move from CloudWatch to a dedicated tool (Datadog, etc.)?
- **Synthetic monitoring:** external uptime monitoring service (UptimeRobot, etc.)?
