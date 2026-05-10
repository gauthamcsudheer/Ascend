# Ascend — Launch Operations Plan

**Companion to PRD v1.0**

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | PM, admin team, engineering, RSET institutional contacts |
| Purpose | Coordinated plan for taking Ascend from build-complete to fully announced across RSET |

---

## 1. Launch Philosophy

Ascend launches as the RSET platform — full product, full institutional access from day one. The technical launch is a single cutover. The audience exposure is sequenced via announcement timing: CSE department informed first, then other departments added one at a time over approximately 2 weeks based on health guardrails.

This approach gives us:
- A complete product from launch (no "coming soon" features)
- Manageable verification load through paced announcements
- Time to catch operational issues with a smaller initial audience
- Institutional positioning from day one (not pilot framing)

---

## 2. Pre-Launch Phase (T-4 weeks to T-0)

### 2.1 Engineering Readiness (T-4 to T-2)

**T-4 weeks:**
- [ ] All features built and deployed to staging environment
- [ ] Internal testing by engineering and PM
- [ ] Initial bug fixes complete

**T-3 weeks:**
- [ ] Full QA pass on staging
- [ ] Accessibility audit (WCAG 2.1 AA conformance check)
- [ ] Security review (OWASP Top 10 audit, dependency scan, optional pen test)
- [ ] Performance testing under expected concurrent load
- [ ] Load testing of admin dashboard

**T-2 weeks:**
- [ ] Production environment provisioned (Indian cloud region)
- [ ] DNS, SSL, domain configured
- [ ] Database backups configured (daily snapshots, 30-day point-in-time)
- [ ] Monitoring and alerting set up (errors, latency, key business metrics)
- [ ] Email and push notification providers integrated and tested
- [ ] First admin account bootstrapped on production

### 2.2 Content Seeding (T-3 to T-1)

The platform needs to feel alive on day one. Recruit and coordinate content seeders:

**Faculty seed Q&A:**
- [ ] Identify 5-7 cooperating CSE faculty
- [ ] Brief them on the platform
- [ ] Each contributes 5-10 evergreen Q&A pairs (questions they answer every semester, with their best answers)
- [ ] Target: 30-50 seeded Q&A pairs across CSE

**Alumni seed Experience posts:**
- [ ] Identify 15-25 known alumni willing to post
- [ ] Brief them on what makes a good Experience post (internship retro, career journey, project story)
- [ ] Target: 15-25 Experience Feed posts at launch

**Resource Library seeding:**
- [ ] Faculty contribute 3-5 resources each (auto-promoted via faculty endorsement)
- [ ] Alumni contribute supporting resources
- [ ] Target: 30-50 endorsed resources at launch

**Cross-department seed (if achievable):**
- [ ] Even though only CSE is announced first, recruit faculty from other departments to seed pre-launch
- [ ] Their content will be visible to CSE users (cross-department visibility) and ready when their department is announced

### 2.3 Admin Team Readiness (T-2 to T-0)

- [ ] Admin team identified (2-4 individuals)
- [ ] Admin Operations Playbook reviewed by all admins
- [ ] Admin accounts created on production
- [ ] Admin team coordination channel established (Slack, email, etc.)
- [ ] On-call rotation defined for the first 2 weeks
- [ ] Each admin commits to verification triage daily during launch period

### 2.4 Documentation & Policy (T-2)

- [ ] Privacy Policy finalized and reviewed
- [ ] Community Guidelines finalized
- [ ] Help / Getting Started page populated
- [ ] FAQ page drafted for common user questions

### 2.5 Communication Materials (T-1)

- [ ] Announcement email template for CSE drafted
- [ ] Department-specific announcement templates for each subsequent department
- [ ] FAQ for users (what is Ascend, how do I get verified, what can I do)
- [ ] Support email address established (likely admin@rajagiritech.edu.in or equivalent)

---

## 3. Launch Day (T-0)

### 3.1 Morning Operations
- [ ] Final smoke test on production (all features functional)
- [ ] Monitoring dashboards active
- [ ] Admin team online and ready
- [ ] On-call admin identified for the day

### 3.2 Soft Launch
- [ ] Platform goes live (admins, faculty seeders, alumni seeders gain access)
- [ ] Verify seed content displays correctly across all surfaces
- [ ] Admin team performs final UX walkthrough as actual users

### 3.3 CSE Announcement
- [ ] Announcement sent via official RSET channels (most important: official institutional email, secondarily department mailing list, faculty announcement, alumni newsletter)
- [ ] Communication includes: what Ascend is, how to register, verification expectations, support contact
- [ ] Announcement timed for maximum reach (mid-morning, weekday)

### 3.4 Day-1 Monitoring
- [ ] Watch registration rate
- [ ] Watch verification queue size
- [ ] Watch error logs
- [ ] Watch user reports / support emails
- [ ] Brief admin standup at end of day to assess

---

## 4. Post-Launch Days 1-7

### 4.1 Daily Operations (CSE Phase)
- Admin team checks verification queue twice daily (morning and evening)
- Admin team checks reports queue at least once daily
- PM reviews health metrics daily
- Engineering monitors error rates and performance

### 4.2 Health Guardrails

Before announcing the next department, verify:

**System health:**
- [ ] No critical bugs unresolved
- [ ] Error rate < 1%
- [ ] Performance within SLOs (TTFB < 500ms, feed load < 2s on 4G)
- [ ] Verification SLA being met (most within 72h)
- [ ] Reports SLA being met (most within 72h, severe within 24h)

**Engagement health:**
- [ ] Some questions are being asked
- [ ] Some questions are getting answers
- [ ] Some posts are appearing in Experience Feed
- [ ] Users are engaging (votes, comments)

**Content health:**
- [ ] Moderation queue not overwhelmed
- [ ] No widespread spam or abuse
- [ ] Tag taxonomy being used appropriately

### 4.3 Issue Triage
If issues arise during CSE phase:
- **Minor:** queue for next iteration; communicate to users if user-facing
- **Major:** pause expansion announcements; fix; verify; resume
- **Critical:** all hands; rollback if necessary; communicate transparently

---

## 5. Phased Department Announcements (Days 7-21)

Once health guardrails pass, expand announcements one department at a time.

### 5.1 Department Order (Recommended)
1. Computer Science Engineering (CSE) — Day 1
2. Electronics & Communication Engineering (ECE) — ~Day 7
3. Electrical & Electronics Engineering (EEE) — ~Day 11
4. Mechanical Engineering — ~Day 14
5. Civil Engineering — ~Day 17
6. Other branches as applicable — ~Day 19+

(Order can be adjusted based on RSET institutional preferences and available alumni networks per branch.)

### 5.2 Per-Department Announcement Process

**Day before:**
- [ ] Verify health guardrails still pass
- [ ] Coordinate with department's faculty/HoD if helpful
- [ ] Brief admin team on expected uptick in verifications

**Day of:**
- [ ] Send announcement via department mailing list and official channels
- [ ] Admin team prepared for verification surge
- [ ] Monitor closely for the first 24 hours

**Days after:**
- [ ] Track engagement of new users
- [ ] Watch for any branch-specific issues (e.g., tag taxonomy gaps for that branch)
- [ ] Iterate on tags if patterns emerge (e.g., a missing tag for a popular subject)

### 5.3 Pause Criteria
Halt the expansion schedule if any of these occur:
- Verification SLA breached widely
- Critical bug discovered
- Moderation overwhelmed
- Performance degradation under increased load
- Security incident

Resume only when issue is resolved.

---

## 6. Steady State (Day 22+)

### 6.1 Operational Cadence

**Daily:**
- Admin processes verifications and reports
- PM glances at metrics dashboard
- Engineering monitors errors

**Weekly:**
- Admin team coordination meeting (15-30 min)
- Tag suggestion review batched
- PM reviews engagement metrics

**Monthly:**
- Full metrics review
- Product retrospective
- Tag taxonomy review (any retiring needed?)
- Platform health audit

**Quarterly:**
- NPS survey to users
- Admin team review (still the right people?)
- Strategic review of product direction
- External lawyer review of privacy practices (DPDP compliance check)

### 6.2 Success Metrics to Track

**North-star:**
- Weekly Active Users / Monthly Active Users ratio (target > 0.4)
- Median time-to-first-accepted-answer (target < 24h)

**Engagement:**
- % of new students with ≥1 accepted answer in first 30 days
- Verified Alumni MAU as % of total verified alumni (target > 10%)
- % of connection requests accepted within 7 days (target > 50%)
- Average questions answered per active alumnus per month

**Quality:**
- % of questions answered within 48h (target > 70%)
- Resource Library: % of links unbroken (quarterly check, target > 80%)
- % of reports resolved within internal SLA (target > 95%)

**Trust:**
- Quarterly NPS by persona (Students ≥30, Alumni ≥40, Faculty ≥50)
- % of verifications successful on first try
- Moderation actions per 1000 active users (lower is better)

---

## 7. Contingency Plans

### 7.1 Rollback
If a critical bug is shipped:
- Engineering has a documented rollback procedure (revert to previous deployment)
- Communication: immediate honest update to users via in-app banner and announcement
- Post-mortem within 1 week

### 7.2 Verification Surge Beyond Capacity
If verification queue exceeds admin capacity:
- Admin team commits to additional time temporarily
- User-facing SLA copy updates to honest expectation ("Currently up to 5 days")
- Consider temporarily pausing further department announcements until backlog clears

### 7.3 Major Security Incident
- Immediate suspension of any compromised accounts
- Forensic review by engineering
- Notification to affected users
- DPDP-compliant breach notification if applicable
- Post-incident review and remediation

### 7.4 Coordinated Spam or Abuse
- Admin team escalates to engineering
- Rate limits tightened temporarily
- Suspect accounts suspended
- Vector of attack investigated (mass signup? credential stuffing?)

### 7.5 Platform Outage
- Engineering on-call responds per runbook
- Status page (or social media post) communicates outage to users
- Post-mortem within 1 week

---

## 8. Communication Templates

### 8.1 CSE Announcement Email (Draft)
```
Subject: Introducing Ascend — RSET's New Platform for Knowledge & Mentorship

Dear RSET community,

Today we're launching Ascend, a platform built for our community — students, faculty, and alumni — to share knowledge, ask questions, and build mentorship across batches.

Ascend is for our community alone. Every member is verified, and the platform is designed so that the most useful voices — those who've walked the path — guide those who are starting out.

Why Ascend?
- Ask questions and get answers from seniors, alumni, and faculty
- Read experiences from your seniors — internships, projects, career journeys
- Find curated resources for your studies and career
- Connect 1-on-1 with alumni who can mentor you on specific topics

How to join:
- Students: Sign up at [URL] using your @rajagiri.edu.in email
- Faculty: Sign up at [URL] using your @rajagiritech.edu.in email
- Alumni: Sign up at [URL] using any email; verification by our team typically within 3 days

Questions? Email [admin email].

Welcome to Ascend.
```

### 8.2 Per-Department Expansion Email (Template)
```
Subject: Ascend is now open for [Department] students and alumni

Dear [Department] community at RSET,

Ascend, RSET's platform for knowledge sharing and mentorship, is now open for our [Department] community.

[Brief intro to platform — same as CSE template]

How to join:
[Same instructions]

Already 200+ of your CSE peers are using Ascend to find answers, share experiences, and connect with alumni. Now it's your turn.

[Sign up link]
```

### 8.3 Verification Approved Email (Template)
```
Subject: Welcome to Ascend, [Name]

Hi [Name],

Your alumni account on Ascend has been verified. You now have full access to the platform.

[Login link]

What's next:
- Browse questions in your areas of expertise
- Share your experiences with current students
- Connect with juniors who could benefit from your mentorship

Welcome to the RSET community on Ascend.
```

### 8.4 Verification Rejected Email (Template)
```
Subject: Your Ascend registration needs more information

Hi [Name],

We were unable to verify your alumni status from the information provided. Specifically: [reason — e.g., "Your LinkedIn profile doesn't show RSET in your education history"].

You can re-submit your registration with corrected or additional information. If you have alternative ways to verify your alumni status (e.g., a faculty referral, photo of your degree certificate), please email [admin email] directly.

We want to welcome you to Ascend. Please reach out if you need help.
```

---

## 9. Roles & Responsibilities

### 9.1 Product Manager
- Owns the launch plan
- Coordinates between admin team, engineering, and RSET institutional contacts
- Tracks success metrics
- Drives post-launch iteration

### 9.2 Admin Team
- Operations leadership during launch
- Verification and moderation
- Escalation point for user issues
- Daily/weekly operational cadence

### 9.3 Engineering Team
- Production deployment
- Monitoring and incident response
- Bug fixes
- On-call during launch period

### 9.4 RSET Institutional Contacts
- Approval of communication materials
- Distribution via official channels
- Faculty engagement coordination
- Alumni network coordination

---

## 10. Post-Launch Reviews

### 10.1 30-Day Retrospective
- What worked
- What didn't work
- User feedback patterns
- Adjustments to roadmap

### 10.2 90-Day Strategic Review
- Are we hitting north-star metrics?
- What's the user mix looking like (student vs alumni participation)?
- Are there features that are over-built or under-built?
- What's next on the roadmap (V1+ thinking)?

### 10.3 Annual Review
- Full platform health audit
- Strategic direction
- Multi-institutional readiness check (if applicable)

---

This plan is a starting point. Adjust based on what's learned during execution. The goal is a deliberate, controlled launch — not a perfect one.
