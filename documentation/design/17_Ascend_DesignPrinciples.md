# Ascend — Design Principles

| Field | Value |
|---|---|
| Version | 1.0 |
| Audience | Designers, engineers, anyone making UI decisions |
| Purpose | The philosophical foundation. When two design choices both look reasonable, this doc resolves which is "us." |

---

## How to Use This Document

Principles are not platitudes. Each principle below has three parts: a one-sentence claim, what it actually means in practice, and what it explicitly is *not*. When you face a design tension, read the relevant principle and look for the trade-off it asks you to make.

Principles can conflict with each other. When they do, the order matters — earlier principles take precedence. This is deliberate.

---

## 1. Substance Over Polish

**The content is the product. Everything else serves the content.**

In practice this means: the question text is more important than the button styling. The answer's words are more important than the avatar size. We design the typography of body text first, and decoration second. We give content room to breathe rather than compressing it to fit chrome.

This is *not* an excuse for ugly or careless design. "Plain" is not the same as "polished." We invest heavily in typography, spacing, and reading comfort — those are the polish. We do not invest in glossy gradients, decorative illustrations, or visual flourishes that compete with the content for attention.

**Trade-off:** When a marketing-style hero section would make a screen "more impressive," we resist. Ascend looks more like a well-designed reference work than a SaaS landing page. The first thing a returning user sees is what's new in their world, not a brand statement.

---

## 2. Calm Density

**Show real information. Don't hide it behind progressive disclosure unless the user has actually asked for less.**

Indian university users are reading on commute, between classes, at midnight. They want to scan a feed and know what's worth their time without three taps. That means: meaningful titles visible, persona context visible, recency visible, vote count visible — all in the first card view. We don't reduce a feed item to a title and a "tap to expand."

This is *not* permission for clutter. Density is achieved through hierarchy, not through cramming. A dense screen with strong typographic hierarchy reads as confident. A dense screen with everything at the same visual weight reads as overwhelming. We use weight, size, and spacing to let the eye triage, not to hide things.

**Trade-off:** Apps that make a 5-screen onboarding flow into 12 screens "to be friendly" lose us. We respect that the user is busy. Three screens of onboarding is enough.

---

## 3. Respect the Asymmetry

**A 3rd-semester student and a 15-year alumnus need different scaffolding. The interface acknowledges this without making it awkward.**

A first-time student needs more context, more help, more "what does this mean." A returning faculty member needs efficiency. An alumnus visiting once a month needs orientation again. The same screen serves all three but adapts gracefully — onboarding tooltips appear once, never again. Help text is present but recedes for power users. Persona-specific affordances surface where useful (faculty endorsement, alumni Class of badge) without being crammed everywhere.

This is *not* permission for completely different experiences per persona. There is one Ascend, with consistent navigation and primitives. Adaptation is in the *content* and *tooltips*, not in the structure.

**Trade-off:** When tempted to add a "student mode" toggle or a "faculty dashboard" with different navigation, we resist. The platform is the same; what surfaces is different.

---

## 4. Reversibility by Default

**Fewer "are you sure?" modals. More undo.**

Most actions in Ascend are recoverable. A vote can be retracted. A bookmark can be removed. A submitted question can be edited. We design for "you can change your mind later" rather than "we'll triple-check before letting you act." Confirmations are reserved for actions that are genuinely irreversible (account deletion, ban, hard-delete).

This is *not* a license to remove all friction from destructive actions. Account deletion has a 14-day grace period and a confirmation. Banning a user requires explanation. The principle is about *routine* actions: voting, bookmarking, submitting, replying.

**Trade-off:** Some users will accidentally vote on their own content's parent post. They retract. Ten extra clicks across all users beats a confirmation modal that everyone sees a hundred times.

---

## 5. Honesty in Failure

**When something breaks, say what broke and what to do next. Never blame the user. Never blame "the system."**

Errors are part of the product. Designed well, they're a small moment of trust. Designed badly, they're the moment a user gives up. Every error message includes: what happened, why if we can say honestly, and what the user can do now. We do not say "An error occurred." We say "We couldn't save your answer because the connection dropped. Try again — your draft is still here."

This is *not* permission for technical detail dumps. "DB connection refused" is not honesty; it's noise. Honesty is the right level of detail for the user to act.

**Trade-off:** Writing good error messages takes more time than copying a default. We do it anyway. It is a measurable lever on retention.

---

## 6. Read-First, Write-Cautious

**Ascend is consumed more than created. The reading experience is the core experience.**

Most users on most days read questions and answers without writing anything. Optimize for them. The composer is fast when needed but receded when not. The default state of the home screen is content, not invitations to post. We do not nag users to contribute.

When users *do* write, we make it deliberate. The composer is calm, gives time to think, supports drafts. We don't auto-publish or auto-suggest. Mistakes in writing are public; we slow that step down.

This is *not* permission to bury the composer or make posting hard. It's discoverable; it's just not screaming.

**Trade-off:** Engagement metrics that count "% of users who post weekly" will look modest. We accept that. A platform where 15% of users post and 85% read engaged is healthier than one where 60% post forced contributions.

---

## 7. Earned Attention

**Visual prominence and notifications must be earned by relevance, not assigned by category.**

A red badge on the notification icon is a meaningful disruption. We don't trigger it for marketing announcements, weekly digest reminders, or "we miss you" prompts. We trigger it for things the user genuinely needs to see: an answer to their question, a connection request, a direct mention.

The same applies to layout. Pinned content, "trending" labels, and prominent placement are reserved for content that demonstrably deserves them. When everything is highlighted, nothing is.

This is *not* a directive against helpful nudges. The graduation prompt for a student transitioning to alumnus is appropriate. The "verify your email" reminder is appropriate. Nudges are fine when they reflect a state the user actually has.

**Trade-off:** Engagement teams elsewhere optimize by surfacing more. We optimize by surfacing the right things. Users who trust the notification badge respond to it; users who learned to ignore it never come back.

---

## 8. Mobile Is Primary

**The mobile experience is the platform. Desktop is the convenience layer.**

Most users are on Android phones, on intermittent mobile data, in environments where they have one hand free. Every layout, every interaction, every screen is designed mobile-first. Touch targets are 44px minimum. Important actions are within thumb reach. We assume slow networks and design for them — skeleton loading, optimistic updates, offline read.

Desktop gets more screen real estate, multi-pane layouts where helpful, and keyboard shortcuts. But desktop is not where we *start*. The product must feel native and complete on a phone.

This is *not* permission to build a thin mobile experience. The mobile experience is full-featured. It is also the place we start design work.

**Trade-off:** Some desktop power-user features take longer to build because mobile comes first. Worth it.

---

## 9. Anonymity Without Stigma

**The "Anonymous" affordance for asking questions is treated as a normal first-class option, not a hidden escape hatch.**

Students sometimes need to ask a question that feels embarrassing — about a subject they should know, about a personal struggle, about a faculty interaction. The anonymous-question feature is the platform's answer to this. We design it as a clearly visible toggle, with neutral copy, and treat anonymous questions with the same visual weight as identified ones.

This is *not* permission for total anonymity across the platform. Answers, comments, and posts are always identified. The anonymous option is scoped to *asking* a question — where the asker is most vulnerable.

**Trade-off:** Some attention-seeking behavior may use anonymity. The platform's reporting tools handle that. The benefit to genuinely-vulnerable askers outweighs.

---

## 10. The Interface Disappears

**The best version of an Ascend screen is one the user doesn't notice. They notice the question, the answer, the help, the connection. The interface gets out of the way.**

This is the meta-principle. When we agonize over a button color, a hover state, a transition — we remember that the user is here for a reason that has nothing to do with our chrome. The chrome serves; it does not perform.

This is *not* a directive toward minimalism for its own sake. Empty screens with one button in the middle are not "clean" — they are unhelpful. The interface disappears by being *appropriate*, not by being *absent*.

**Trade-off:** If a designer or engineer is excited about a clever interaction, the bar is whether it makes the underlying task more obvious. If yes, ship. If no, cut.

---

## Anti-Principles

These are things we explicitly do not believe, even though they're popular elsewhere:

**"Engagement is the goal."** It isn't. Useful exchange is the goal. We measure useful exchange (answers accepted, mentorship connections made, resources saved) and treat raw engagement (sessions, time spent) as a coarse proxy at best.

**"Make it fun."** We are not a game. Fun emerges naturally from a well-built community; we don't manufacture it through visual gimmicks, mascots, or artificial achievement loops. The badge system exists, but badges are sober and meaningful, not cartoonish.

**"Move fast and ship."** We move at a deliberate pace. The product handles people's reputations, careers, and academic trajectories. A bug in voting is more serious than a bug in a typical app. We test before we ship.

**"The user is the product."** Users are not the product. The platform's value is created by users for each other; we are the steward of that exchange. Decisions that would compromise user trust to extract value from them (selling data, dark patterns, attention-grabbing notifications) are categorically off the table.

---

## When Principles Conflict

The order of principles above is the priority. **Substance Over Polish (1)** beats **Mobile Is Primary (8)**: if a piece of content needs more space to be readable, we take the space even if it forces a smaller font on mobile. **Reversibility by Default (4)** beats **Calm Density (2)**: even though a confirmation modal adds visual weight, we only use it for genuinely irreversible actions, not for routine ones — those get inline undo.

When in doubt, the question to ask is: "Does this serve the user's actual goal, which is rarely 'admire the interface'?" If yes, it's right. If no, it's the wrong choice no matter how clean the execution.
