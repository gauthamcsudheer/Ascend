# Ascend — Admin Operations Playbook

**Companion to PRD v1.0**

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Admin team (2-4 trusted individuals from development and RSET) |
| Purpose | Day-to-day operational guide for running Ascend |

> This document covers what admins actually do, when, and how. It covers verification, moderation, tag curation, edge cases, and escalation paths. It is meant to be read in full by every admin before they operate the platform, and used as a reference thereafter.

---

## 1. Admin Role Overview

### 1.1 What Admin Is Responsible For
- **Alumni verification** — review pending registrations, approve or reject
- **Content moderation** — handle reported content, take action per penalty ladder
- **Tag taxonomy** — curate, add new tags from suggestions, merge duplicates
- **Persona overrides** — handle drop-outs, transfers, manual adjustments
- **User suspension and bans** — enforce community guidelines
- **Tag suggestion review** — approve or reject user-suggested tags
- **Question archival** — archive outdated questions when needed
- **Faculty endorsement of seed content** (during initial seeding only)

### 1.2 What Admin Is NOT Responsible For
- Platform content creation (admins are users like any other when they post)
- Endorsement of student/alumni content (that's faculty's domain via Faculty Endorsed mechanism)
- Resource library curation (community-driven via promotion mechanic)
- Customer support beyond the dashboard tools (no in-app live chat)

### 1.3 Admin Team Structure
- 2-4 individual admins, each with their own admin account (no shared credentials)
- All admins have full role; operationally equivalent
- Audit log records every action by individual admin
- Operational best practice: rotate primary on-call between admins to avoid burnout

### 1.4 Time Commitment
Realistic estimate based on ~3,000 active users:
- **First 2 weeks (announcement period):** 1-2 hours/day per primary admin
- **Steady state:** 30-60 minutes/day; can be batched (e.g., 30 min morning + 30 min evening)
- **Peak periods (start of semester, placement season):** more verification, more questions, slightly higher load

---

## 2. Verification Workflow

### 2.1 When to Process Verifications
- **During announcement period:** twice daily (morning and evening) to keep SLA
- **Steady state:** once daily

### 2.2 The Process

1. **Open Admin Dashboard → Pending Alumni Queue**
2. **Sort by oldest first** — these are closest to SLA breach
3. **For each pending request:**
   - Read submitted info: name, batch year, branch, current role, current company, LinkedIn URL
   - Click LinkedIn URL → does the profile match the registration data?
   - Look for these positive signals:
     - LinkedIn shows RSET or Rajagiri in education history
     - Batch year aligns with what they entered
     - Current role/company match LinkedIn
     - Profile has photo, connections, activity (real person indicators)
   - Look for these red flags:
     - LinkedIn doesn't mention RSET at all
     - Names don't match
     - Batch year contradicts LinkedIn dates
     - LinkedIn profile is empty or suspicious (no connections, no photo, generic)
     - Multiple registrations from same source within minutes
4. **Decide:**
   - **Clear positive signals → Approve**
   - **Clear red flags → Reject** (provide reason: "Could not verify RSET affiliation from provided LinkedIn URL")
   - **Ambiguous → Approve** (err on the side of trust; community moderation will catch genuine bad actors)
5. **Add internal admin note** if anything notable for future reviewers

### 2.3 Decision Heuristics

**Approve when in doubt** — the cost of approving a borderline case is small (community will surface bad actors); the cost of rejecting a real alumnus is high (they don't come back).

**Reject only with confidence** — if you're rejecting, you should be able to explain in one sentence why. "LinkedIn doesn't show RSET at all" is a clear reason. "Felt off somehow" is not.

### 2.4 Special Cases

**Alumnus without LinkedIn (manual flow):**
1. They emailed admin@rajagiritech.edu.in directly
2. Verify their identity via alternate means: faculty referral, photo of degree certificate, batchmate vouching
3. Once verified, manually create their account via admin dashboard's "Create user" flow with persona=alumnus and verification_status=verified
4. Notify them their account is ready

**Repeat registrations:** If a user registers twice (perhaps after a failed first attempt), treat the more recent registration as canonical and reject the older one.

**Second rejection:** When you reject a user who has already been rejected once, the account locks automatically. They must email admin to appeal. Treat appeals seriously — re-verify with whatever evidence they provide.

### 2.5 SLA
- **User-facing copy:** "Reports are typically resolved within 3 days; severe issues are prioritized."
- **Internal target:** 72 hours during steady state; up to 7 days during announcement surge (be honest in copy)

### 2.6 Audit Trail
Every approve/reject action automatically logs:
- Admin user ID
- Action taken
- Reason (for rejections)
- Timestamp

---

## 3. Moderation Workflow

### 3.1 When to Process Reports
- **Severe categories (Harassment, Hate speech, Inappropriate content, Impersonation):** check at least twice daily; aim for 24-hour resolution
- **Standard categories (Spam, Off-topic, Misinformation, Plagiarism, Other):** check daily; aim for 72-hour resolution

### 3.2 The Process

1. **Open Admin Dashboard → Reports Queue**
2. **Sort by severity then SLA priority**
3. **For each report:**
   - Read the reported content in full context (open the question/post/answer/comment)
   - Read the report reason and any free-text
   - Check the target user's history: prior reports, prior content removals, prior penalties
   - Check the reporter's history: are they a frivolous reporter (flagged previously)?
4. **Decide based on the penalty ladder (§3.4):**
   - **Dismiss** — report not actionable; report doesn't reflect a real violation
   - **Warn** — content is borderline; user gets a private warning; counts toward record
   - **Remove content** — content clearly violates guidelines; -50 rep
   - **Suspend user** — repeated violations; choose 24h, 7d, or 30d per ladder
   - **Permanent ban** — severe violation or end of ladder
5. **Document the action** in the resolution note
6. **Notify the reporter** of the outcome (system handles this automatically per the action taken)

### 3.3 Severity Heuristics

**Severe (24h SLA target):**
- Harassment of an individual (especially personalized attacks)
- Hate speech (caste/religious/regional/gender-based)
- Doxxing (sharing private information)
- Impersonation (claiming to be someone they're not)
- Sexual or violent content
- Direct threats

**Standard (72h SLA target):**
- Spam
- Off-topic content
- Mild misinformation (factual errors)
- Plagiarism (copying without attribution)
- Vague reports

### 3.4 Penalty Ladder

| Infraction | Action |
|---|---|
| First (low severity) | Warning |
| First (high severity) | Content removal + warning, OR direct suspension |
| Second within 6 months | 24h suspension |
| Third within 6 months | 7-day suspension |
| Fourth within 6 months | 30-day suspension |
| Fifth within 6 months | Permanent ban |
| Severe (e.g., harassment campaign, doxxing, hate speech) | Direct permanent ban regardless of history |

### 3.5 Special Situations

**Multiple reports of same content:**
The dashboard consolidates multiple reports into one queue entry with a count. If 5 users reported the same post, that's a stronger signal than 1 user reporting. Take it more seriously; resolve faster.

**Anonymous question reported:**
You can see the asker's real identity (admins always do). Apply the same rules; just keep their identity confidential in your private resolution.

**DM reported:**
You get access to the specific message thread. Read enough to understand the context. Take action proportional to the violation. If both parties are at fault (mutual harassment), warn both.

**Faculty content reported:**
Treat faculty like any other user; same rules apply. Faculty are not above moderation.

**Borderline content:**
When unsure, **warn first**. Removing content has consequences (rep loss, public tombstone); warning is reversible if the user complies.

### 3.6 Frivolous Reporters
If you see a user filing many reports that are consistently being dismissed (e.g., 10 reports, all dismissed):
1. Open their profile in admin dashboard
2. Click "Flag as Frivolous Reporter"
3. Their future reports will go to a lower-priority queue (still reviewed, just last in line)

This is reversible — if their reporting quality improves, you can unflag.

### 3.7 What to Do When Unsure
- **Wait 24 hours** if there's no urgency; let multiple admins look at it
- **Ask another admin** via your team's communication channel
- **Lean toward minimal action** — warning beats removal; removal beats suspension; suspension beats ban
- **Document your reasoning** in the resolution note so future admins understand the precedent

---

## 4. Tag Management

### 4.1 Reviewing Tag Suggestions

**When:** weekly, batched

**Process:**
1. Open Admin Dashboard → Tag Suggestions
2. For each suggestion:
   - Is this a real topic that doesn't already have a tag?
   - Is the proposed name canonical (well-formed, unambiguous)?
   - Could it merge into an existing tag instead?
3. **Approve, reject, or merge into existing**

**Naming conventions for tags:**
- Lowercase, hyphenated (e.g., `data-structures`, `web-development`)
- Singular for subjects (`algorithm` not `algorithms`) — exception: established plural names
- Avoid abbreviations unless universally known (`ml` is fine; `ds` is too overloaded — use `data-structures`)
- No special characters except hyphens

### 4.2 Adding New Tags

When creating a new tag:
- Name it canonically
- Write a clear one-line description (this becomes the tooltip)
- Choose category (informational, doesn't affect behavior)
- Save

### 4.3 Merging Duplicate Tags

When you see two tags that mean the same thing (e.g., `ml` and `machine-learning`):
1. Pick the canonical one (prefer the more descriptive)
2. Open admin → Tags → select the non-canonical
3. Click "Merge into existing tag" → choose canonical
4. System handles: reassigning all content, recomputing Subject Specialist badges, marking old tag as merged

The old tag's URL still works (redirects to canonical). Don't worry about old links breaking.

### 4.4 Retiring Tags

If a tag is no longer relevant (e.g., a course got dropped from curriculum):
1. Don't delete content tagged with it
2. Mark the tag as retired in admin dashboard
3. Retired tags don't appear in pickers; existing tagged content keeps the tag

---

## 5. Persona Overrides & Lifecycle

### 5.1 Drop-out / Transfer (Student → Former Student)

**When you should do this:**
- A student informs you (or it becomes apparent) that they're no longer at RSET
- Faculty inform you of a transfer or drop-out
- Investigation of suspicious activity reveals the user is no longer a student

**Process:**
1. Open admin → Search user
2. Click "Override persona" → select "Former Student"
3. Provide reason in audit log
4. User receives notification of persona change
5. Their access becomes browse-only

If the user appeals (e.g., they're returning to RSET): you can change them back.

### 5.2 Faculty Department Change

**When:** faculty member transferred to a different department

**Process:**
1. Search user → open profile
2. Edit department field
3. Audit log records the change

### 5.3 Other Persona Adjustments

Generally, the system handles persona transitions correctly (student → alumnus on graduation). Manual adjustment is rare and should be documented carefully.

---

## 6. Question Archival

**When to archive a question:**
- The question references a course/curriculum that no longer exists
- The answer landscape has fundamentally changed (e.g., questions about a since-deprecated tool)
- The question is misleading in current context

**Process:**
1. Open the question
2. Click "Archive" in admin actions
3. Provide reason in audit log
4. Question becomes read-only; still searchable

Archival is reversible. Don't be afraid to archive — it's not deletion.

---

## 7. Edge Cases & Common Situations

### 7.1 "I think someone hacked my account"

1. Immediately suspend the account (24h, just to stop activity)
2. Email the user via their registered email asking to confirm
3. If confirmed compromised: reset password, enable MFA, restore access
4. Audit log: review all recent actions on the account

### 7.2 "An anonymous question is clearly harassment"

You can see the asker's identity. Apply the same penalty ladder. The fact that they tried to be anonymous is a slight aggravator (intent to evade accountability), but not automatically severe.

### 7.3 "A high-rep user is now misbehaving"

The penalty ladder applies the same way. High rep doesn't grant immunity. If anything, established users behaving badly is more concerning because it can normalize misbehavior.

### 7.4 "A faculty member is being reported"

Faculty are users like any other. Apply the rules. If a faculty member needs to be suspended or banned, do so. The institution will support fair moderation.

### 7.5 "Multiple reports against the same content keep coming in"

If you've already actioned a report and new ones keep arriving for the same content:
- If you took action (removed/warned), let the new reports auto-resolve
- If you dismissed, the new reports might indicate you missed something — re-review

### 7.6 "An admin account is no longer trusted"

If an admin needs to be removed (left the project, behaved badly):
1. Any other admin can revoke their admin role
2. Don't delete their user account — they may still be a regular user
3. Audit log preserves their past actions
4. If their actions need review, the audit log is the source of truth

### 7.7 "Critical issue, no admin online"

If a severe issue arises and no admin is reachable:
- Engineering team has direct database access in extreme cases (documented in launch operations plan)
- Severe content can be hidden via direct DB action
- Once an admin is reachable, the action is logged and reviewed

This should happen rarely; the goal is admin coverage that prevents this.

### 7.8 "Spam wave"

If you see a sudden surge of spam (multiple accounts posting similar content):
1. Suspend the obvious spam accounts
2. Remove their content
3. Check if rate limiting needs adjustment (loop in engineering)
4. Look for the entry vector — was there a security issue that allowed mass signups?

---

## 8. Communication Patterns

### 8.1 Talking to Users
- Be brief, clear, and respectful
- Explain your reasoning when actioning content
- Avoid platform jargon
- If declining a verification, give them a path forward (resubmit, email admin)
- Don't engage in arguments; state the policy and the action; refer to community guidelines

### 8.2 Internal Admin Communication
- Use a private channel (Slack/email) for "did anyone else see this?" coordination
- Document significant decisions in audit log notes so future admins understand precedents
- If you're going off-duty for a stretch, let other admins know

### 8.3 Communicating with Engineering
- Bug or anomaly: file a clear report with steps to reproduce
- Feature request from a user: route through PM, not directly to engineering
- Security concern: immediate escalation, do not delay

---

## 9. Operational Hygiene

### 9.1 Daily Checklist (Steady State)
- [ ] Open admin dashboard
- [ ] Check verification queue (process oldest first)
- [ ] Check reports queue (process severe first)
- [ ] Check tag suggestions queue (weekly batch is fine)
- [ ] Glance at audit log for any unusual patterns

### 9.2 Weekly Checklist
- [ ] Review tag suggestions backlog
- [ ] Check for stale items in queues (anything over SLA)
- [ ] Review admin team coordination notes
- [ ] Check link-rot report (monthly job output)

### 9.3 Monthly Checklist
- [ ] Review broader platform health (any moderation patterns trending?)
- [ ] Review which tags are being used vs unused (candidates for retirement)
- [ ] Audit your own actions in audit log (sanity check)
- [ ] Coordinate with other admins on any policy clarifications needed

### 9.4 Quarterly Checklist
- [ ] Review admin team membership (still the right people?)
- [ ] Review penalty ladder outcomes (is it producing fair results?)
- [ ] Review verification heuristics (are we approving/rejecting at the right rates?)
- [ ] Consider taxonomy refresh based on actual usage data
- [ ] PM/engineering retrospective on platform metrics

---

## 10. Boundaries and Limits

### 10.1 What You Cannot Do (and Should Not Try)
- You cannot read DMs that haven't been reported (privacy)
- You cannot delete user accounts on their behalf (they must initiate)
- You cannot view passwords (hashed only)
- You cannot bypass the audit log
- You cannot share admin credentials (each admin has their own login)

### 10.2 What You Should Avoid Even Though You Could
- Don't moderate based on disagreement with content; only based on community guidelines violations
- Don't take action against users you have personal relationships with — ask another admin
- Don't take action late at night while tired; queue it for tomorrow

### 10.3 If You're Asked to Do Something Outside Policy
- "Can you delete this critical comment about me?" — No, not unless it violates guidelines.
- "Can you boost my friend's content?" — No.
- "Can you reveal who reported me?" — No.
- "Can you give me access to someone's data?" — No, unless it's a DPDP data-export request from that user themselves.

If institutional pressure asks you to act outside policy: escalate to the full admin team for discussion before acting.

---

## 11. Appendix — Decision Trees

### 11.1 Verification Decision Tree
```
Pending alumnus → Is LinkedIn URL valid format?
  ↓ No → REJECT (invalid URL)
  ↓ Yes → Open LinkedIn profile
    → Does profile mention RSET/Rajagiri?
      ↓ No → REJECT (no RSET affiliation visible)
      ↓ Yes → Does the data align (name, batch, role)?
        ↓ Major mismatch → REJECT
        ↓ Minor mismatch → APPROVE with internal note
        ↓ Aligns → APPROVE
```

### 11.2 Moderation Decision Tree
```
Report received → Read content
  → Is it clearly within community guidelines?
    ↓ Yes → DISMISS
    ↓ No → Is it severe (harassment, hate, etc.)?
      ↓ Yes → REMOVE + check user history → SUSPEND or BAN per ladder
      ↓ No → Is this their first offense?
        ↓ Yes → WARN
        ↓ No → REMOVE + per ladder
```

---

This playbook is a living document. As patterns emerge and edge cases surface, update it. The goal is institutional knowledge that survives admin turnover.
