# **Product Requirements Document (PRD)**

## **Ascend: Elevate Each Other**

***

# 1. Product Summary

**Ascend** is a college-specific platform that enables students to seek guidance from alumni, faculty, and seniors through structured Q\&A, while also supporting experience sharing, resources, and mentorship connections.

***

# 2. Objectives

### Primary Goal

Enable **reliable, experience-driven knowledge exchange** within a trusted college network.

### Secondary Goals

* Build a culture of alumni contribution
* Create a structured knowledge base over time
* Enable mentorship and networking

***

# 3. Success Metrics

### Primary

* ≥ 70% of questions receive answers
* Daily Active Users (DAU)

### Secondary

* Time to first answer (< 24 hrs target)
* Avg answers per question
* Engagement (votes, comments)

***

# 4. User Roles

### 1. Student

* Can ask questions
* Can post content
* Can comment/reply
* Cannot answer if junior (relative to question)

***

### 2. Senior Student

* All student capabilities
* Can answer junior questions

***

### 3. Alumni

* Verified by admin
* Can answer all questions
* Can accept mentorship requests

***

### 4. Faculty

* Can answer questions
* Can moderate
* Can endorse/highlight content

***

### 5. Admin

* Verify alumni
* Moderate content
* Manage users
* Handle reports

***

# 5. Core Features & User Stories

***

# 5.1 Authentication & Onboarding

## User Stories

### US-001: Student Signup

**As a student**, I want to sign up using my college email so that I can access the platform.

**Acceptance Criteria**

* Email must be `@rajagiri.edu.in`
* OTP verification required
* Must select:

  * Department
  * Semester

***

### US-002: Faculty Signup

**As faculty**, I want to register using official email.

**Acceptance Criteria**

* Email must be `@rajagiritech.edu.in`
* OTP verification

***

### US-003: Alumni Signup

**As an alumnus**, I want to register and get verified.

**Acceptance Criteria**

* Submit:

  * Email
  * Department
  * Passout year
  * LinkedIn URL
* Status = “Pending Approval”
* Admin approval required before access

***

# 5.2 Q\&A Module (Core)

***

### US-004: Ask Question

**As a student**, I want to ask a question so I can get guidance.

**Acceptance Criteria**

* Fields:

  * Title (required)
  * Description (required)
  * Tags (required)
* Optional:

  * Post anonymously toggle
* Question visible to all users

***

### US-005: Answer Question

**As an eligible user**, I want to answer a question.

**Acceptance Criteria**

* Only allowed if:

  * Senior student (semester > asker)
  * OR alumni
  * OR faculty
* Stored as top-level answer

***

### US-006: Reply to Answer

**As a user**, I want to reply to an answer for clarification.

**Acceptance Criteria**

* All users can reply
* Nested/threaded replies supported

***

### US-007: Upvote Answer

**As a user**, I want to upvote helpful answers.

**Acceptance Criteria**

* One vote per user per answer
* Vote count visible

***

### US-008: Accept Answer

**As the question owner**, I want to mark the best answer.

**Acceptance Criteria**

* Only question owner can mark accepted
* Only one accepted answer per question

***

***

# 5.3 Feed (Posts)

***

### US-009: Create Post

**As a user**, I want to share experiences or advice.

**Acceptance Criteria**

* Title + content required
* Visible to all users

***

### US-010: Comment on Post

**As a user**, I want to comment on posts.

**Acceptance Criteria**

* Threaded comments supported

***

***

# 5.4 Resource Module

***

### US-011: Add Resource

**As a user**, I want to share useful links.

**Acceptance Criteria**

* Fields:

  * Title (required)
  * Description (required)
  * URL (required)
  * Tags (required)

***

### US-012: Upvote Resource

**As a user**, I want to upvote useful resources.

***

***

# 5.5 Tag System

***

### US-013: Tag Content

**As a user**, I want to categorize content.

**Acceptance Criteria**

* Hybrid:

  * Predefined tags
  * Custom tags allowed

***

***

# 5.6 Messaging & Connections

***

### US-014: Send Connection Request

**As a student**, I want to connect with alumni.

**Acceptance Criteria**

* Request must be accepted before chat

***

### US-015: Accept/Reject Request

**As a user**, I want control over who connects with me.

***

### US-016: Chat Messaging

**As a connected user**, I want to chat.

**Acceptance Criteria**

* Enabled only after connection acceptance

***

***

# 5.7 Moderation & Reporting

***

### US-017: Report Content

**As a user**, I want to report inappropriate content.

**Acceptance Criteria**

* Applicable to:

  * Questions
  * Answers
  * Posts
  * Resources
  * Comments

***

### US-018: Admin Review Reports

**As an admin**, I want to review reports.

**Acceptance Criteria**

* View reported content
* Take action:

  * Ignore
  * Warn user
  * Delete content
  * Ban user

***

### US-019: Alumni Verification

**As admin**, I want to verify alumni.

**Acceptance Criteria**

* Approve/reject pending users
* Access submitted details

***

***

# 5.8 Notifications

***

### US-020: Receive Notifications

**As a user**, I want updates on activity.

**Acceptance Criteria**

* Events:

  * Answer received
  * Upvote received
  * Connection request
* User can:

  * Enable/disable notifications
  * Choose in-app/email

***

***

# 6. Non-Functional Requirements

***

### Performance

* Page load < 2 seconds
* API response < 500ms (ideal)

***

### Security

* JWT-based authentication
* Role-based access control
* Admin visibility of anonymous users

***

### Scalability

* Modular architecture
* DB indexing for:

  * questions
  * tags
  * users

***

### Reliability

* Prevent data loss
* Graceful error handling

***

# 7. Constraints

* College-specific access (initially single college)
* Manual alumni verification
* Minimal notifications (user-controlled)

***

# 8. Assumptions

* Initial users will be seeded manually
* Moderators will actively intervene early-stage
* Alumni engagement requires manual nudging

***

# 9. Out of Scope (For Now)

* AI recommendations
* Real-time chat (advanced)
* Multi-college support
* Advanced analytics dashboards

***

# 10. Future Enhancements

* Smart alumni matching
* Featured answers/posts
* Resume review system
* Placement tracking
* AI summarization of discussions

***

# 11. Open Questions (To Revisit Later)

* Gamification (badges, reputation)
* Verified answers system
* Department-level filtering
* Automated moderation

***

# 12. Definition of Done (MVP)

The product is considered ready when:

* Users can sign up/login
* Students can ask questions
* Eligible users can answer
* Answers can be upvoted and accepted
* Posts and resources can be created
* Messaging works (basic)
* Admin can moderate and verify alumni
* Reports system is functional

