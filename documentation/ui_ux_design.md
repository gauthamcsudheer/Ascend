# **UI/UX Design Document**

## **Ascend: Elevate Each Other**

***

# 1. Product Experience Overview

Ascend is a **college-scoped knowledge and mentorship platform** designed to:

* Enable structured Q\&A between students and alumni
* Encourage experience sharing through posts
* Provide curated resources
* Facilitate intentional networking

***

## Core UX Philosophy

### 1. Structured, Not Chaotic

* Clear separation:

  * Q\&A (problem-solving)
  * Feed (experience sharing)
  * Resources (reference)

***

### 2. Trust-Driven Design

* Real identity (with optional anonymity)
* Role-based interactions
* Faculty as credibility anchors

***

### 3. Low Noise, High Value

* Slight friction in content creation
* Controlled interactions (connections, messaging)

***

# 2. Layout System

***

## 2.1 Global Layout (3-Column)

```
| Sidebar | Main Content | Right Panel |
```

***

### Sidebar (Left)

* Primary navigation
* Create button
* Profile & notifications

***

### Main Content (Center)

* Dynamic content:

  * Feed
  * Q\&A
  * Resources
  * Messages

***

### Right Panel

* Trending tags
* Featured content
* Suggested connections

***

## 2.2 Topbar

* Global search bar
* Minimal design (no clutter)
* Notifications handled in sidebar

***

# 3. Navigation Structure

***

## Sidebar Items

1. Feed (default)
2. Q\&A
3. Resources
4. Connections (includes messaging)
5. Profile
6. Admin (role-based visibility)

***

# 4. Page-Level UX

***

## 4.1 Feed Page

### Purpose

Experience sharing + casual engagement

***

### Layout

* Horizontal filters at top
* “Create Post” button (left)
* Posts list below

***

### Post Rules

* Title required
* Minimum 100 characters
* Tags required

***

### Smart Prompt

If content looks like a question:

> “This looks like a question. Post in Q\&A instead?”

***

### Content Behavior

* Long posts → collapsed (“Read more”)
* Mixed content allowed (learning + casual)

***

***

## 4.2 Q\&A Page

### Purpose

Core knowledge exchange

***

### Question Listing

Each question card shows:

* Title
* Description preview
* Tags
* Author / “Student – Dept”
* Answer count
* Upvotes
* Timestamp

***

### Filters

* Latest
* Unanswered
* Tags

***

***

## 4.3 Question Detail Page

***

### Structure

1. Question (top)
2. Answers (sorted):

   * Accepted
   * Top voted
   * Others
3. Reply threads (inline)

***

### Answer Rules

* Only:

  * Seniors (semester-based)
  * Alumni
  * Faculty

***

### UX Behavior

* Juniors see:

  > “Only seniors, alumni, and faculty can answer this question”

***

### Answer Input

* Modal-based
* Replies inline

***

### Anonymity

* Display:

  > “Student – CSE”

***

### Unanswered Strategy

* Immediate visibility via filter
* Boost after 24–48 hours

***

***

## 4.4 Resources Page

### Purpose

Centralized learning materials

***

### Structure

* Resource cards
* Tag filtering

***

### Resource Fields

* Title
* Description
* External link
* Tags

***

### Behavior

* Upvote-enabled
* No file uploads

***

***

## 4.5 Connections Page

### Sections

* Incoming requests
* Sent requests
* Accepted connections

***

### Rules

* Request only from profile page
* Mandatory note (200–300 chars)
* Max pending requests limit

***

***

## 4.6 Messaging Page

### Layout

* Left: chat list
* Right: active conversation

***

### Behavior

* WhatsApp-style
* No threads
* Real-time (Socket.io)

***

***

## 4.7 Profile Page

***

### Structure

#### Top: Identity

* Name
* Role
* Department
* Alumni: company, role

***

#### Main: Contributions

* Answers
* Posts
* Resources

***

### Goal

Build trust + credibility

***

***

## 4.8 Admin Pages

***

### Admin Dashboard

* Metrics overview
* Quick actions

***

### Alumni Verification

* Pending users
* Approve / reject

***

### Reports Management

* Report list
* Action panel

***

# 5. Modals & Overlays

***

## Content Creation

* Create Post
* Ask Question
* Add Resource

***

## Interaction

* Answer Modal
* Edit Content

***

## Connections

* Send Request (with note)
* Accept/Reject

***

## Moderation

* Report Content
* Admin Action

***

## System

* Notification Preferences
* Logout Confirmation

***

# 6. Component System

***

## Core Components

### Content

* Post Card
* Question Card
* Answer Card
* Resource Card

***

### Interaction

* Comment box
* Answer editor
* Reply thread

***

### Navigation

* Sidebar
* Topbar
* Tabs / filters

***

### Utility

* Tags
* Badges
* Avatars

***

### Messaging

* Chat bubble
* Chat list item
* Input box

***

# 7. Design System (Visual Identity)

***

## 7.1 Color System

Primary:

* `#5C1220` (maroon deep)

Accent:

* `#C9894A` (gold)

Background:

* `#FAF7F2` (cream)

Text:

* `#1A1410` (ink deep)

***

### Usage Principles

* Maroon → actions, CTAs
* Gold → highlights only
* Cream → base UI

***

***

## 7.2 Typography

* Headings → Cormorant Garamond
* Body → DM Sans
* Tags → JetBrains Mono

***

***

## 7.3 Spacing

* 8px, 12px, 16px, 24px scale
* Consistent padding across components

***

***

## 7.4 Components Styling

* Cards:

  * White background
  * Subtle borders
  * Rounded corners

* Buttons:

  * Primary (maroon)
  * Secondary (outlined)

* Tags:

  * Pill-shaped
  * Monospace font

***

# 8. Interaction & Feedback

***

## 8.1 Notifications

* Panel-based
* Toasts for critical events

***

## 8.2 Feedback

* Toasts for actions
* Report confirmation

***

## 8.3 Errors

* Contextual messages

***

## 8.4 Loading

* Skeleton loaders

***

***

# 9. Content Behavior

***

## Long Content

* Collapsed with “Read more”

***

## Highlighting

* Badges:

  * Accepted answer
  * Featured content

***

***

# 10. Empty States

Action-driven messaging:

* “Be the first to ask a question”
* “Share your experience”

***

***

# 11. Onboarding

Guided onboarding:

* Introduce features
* Highlight key actions

***

***

# 12. UX Guardrails

***

## Prevent Noise

* Min content length
* Tags required
* Smart prompts

***

## Maintain Quality

* Upvotes
* Accepted answers
* Moderation

***

## Encourage Engagement

* Right panel suggestions
* Unanswered highlighting

***

# 13. Future UX Enhancements

* Dark mode
* AI suggestions
* Smart recommendations
* Content ranking

***

# 14. Conclusion

Ascend’s UX is designed to:

* Be **structured like StackOverflow**
* Feel **approachable like LinkedIn**
* Maintain **trust and relevance within a college ecosystem**

