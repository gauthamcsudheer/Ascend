# Ascend — Database Schema (Prisma)

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for development |
| File location | `packages/db/prisma/schema.prisma` |

> This is the canonical schema. Engineering may add indexes, derived columns, or split tables as they go, but conceptual changes (new entities, relationship changes) require update to this document and review.

---

## Notes Before Reading

- All tables use `cuid()` primary keys for opacity in URLs and global uniqueness across distributed inserts.
- Soft delete via `deletedAt` for entities that participate in moderation tombstones; hard delete reserved for admin and DPDP compliance.
- Timestamps use `@default(now())` for creation, `@updatedAt` for mutation tracking.
- Indexes called out explicitly where they materially affect query plans.
- Enums defined inline; share with TypeScript via Prisma client generation.

---

## The Schema

```prisma
// packages/db/prisma/schema.prisma

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["fullTextSearchPostgres"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================
// ENUMS
// ============================================

enum Persona {
  STUDENT
  FACULTY
  ALUMNUS
  FORMER_STUDENT
}

enum VerificationStatus {
  PENDING
  VERIFIED
  REJECTED
  LOCKED
}

enum AuthProvider {
  PASSWORD
  GOOGLE_SSO
}

enum VisibilityScope {
  INSTITUTION
  DEPARTMENT
}

enum PostCategory {
  INTERNSHIP
  PROJECT
  HACKATHON
  CAREER_JOURNEY
  COURSE_REFLECTION
  FACULTY_ANNOUNCEMENT
}

enum ResourceCategory {
  COURSE_MATERIAL
  TOOLS
  REFERENCE
  CAREER
  HIGHER_STUDIES
  INSPIRATION
}

enum ResourceStatus {
  PENDING
  LIBRARY
  TOMBSTONE
}

enum LinkStatus {
  OK
  BROKEN
  UNCHECKED
}

enum CommentParentType {
  QUESTION
  ANSWER
  POST
  RESOURCE
}

enum VoteTargetType {
  QUESTION
  ANSWER
  POST
  RESOURCE
  RESOURCE_PENDING
}

enum FollowTargetType {
  USER
  TAG
  CATEGORY
}

enum BookmarkTargetType {
  QUESTION
  ANSWER
  POST
  RESOURCE
}

enum ConnectionStatus {
  PENDING
  ACCEPTED
  DECLINED
  SILENTLY_DECLINED
  EXPIRED
  CANCELLED
}

enum ThreadStatus {
  ACTIVE
  READ_ONLY
}

enum ReputationEventType {
  Q_UPVOTE
  A_UPVOTE
  A_ACCEPTED
  Q_DOWNVOTE
  A_DOWNVOTE
  RESOURCE_ENDORSED
  CONTENT_REMOVED
}

enum BadgeType {
  HELPFUL
  CONNECTOR
  CURATOR
  STORYTELLER
  WELCOMER
  RELIABLE
  SUBJECT_SPECIALIST
  SAGE
  PILLAR
  OPEN_DOOR
  ELDER
  CATALYST
  CLASS_OF
}

enum ReportTargetType {
  QUESTION
  ANSWER
  POST
  COMMENT
  RESOURCE
  DM_MESSAGE
  PROFILE
}

enum ReportReason {
  SPAM
  HARASSMENT
  HATE_SPEECH
  OFF_TOPIC
  MISINFORMATION
  PLAGIARISM
  INAPPROPRIATE
  IMPERSONATION
  OTHER
}

enum ReportStatus {
  OPEN
  RESOLVED
  DISMISSED
}

enum ReportAction {
  NONE
  WARNED
  CONTENT_REMOVED
  USER_SUSPENDED_24H
  USER_SUSPENDED_7D
  USER_SUSPENDED_30D
  USER_BANNED
}

enum PenaltyType {
  WARNING
  SUSPENSION_24H
  SUSPENSION_7D
  SUSPENSION_30D
  PERMANENT_BAN
}

enum NotificationType {
  ANSWER_RECEIVED
  COMMENT
  ANSWER_ACCEPTED
  ANSWER_ENDORSED
  NEW_FOLLOWER
  FOLLOWED_POST
  BADGE_EARNED
  CONNECTION_REQUEST
  CONNECTION_ACCEPTED
  CONNECTION_DECLINED
  CONNECTION_EXPIRED
  NEW_DM
  MENTION
  DEPT_ANNOUNCEMENT
  REPORT_OUTCOME
  CONTENT_REMOVED
  VERIFICATION_APPROVED
  VERIFICATION_REJECTED
  RESOURCE_PROMOTED
  DIGEST
}

enum NotificationChannel {
  IN_APP
  EMAIL
  PUSH
}

enum TagSuggestionStatus {
  PENDING
  APPROVED
  REJECTED
}

// ============================================
// USER & AUTHENTICATION
// ============================================

model User {
  id                          String              @id @default(cuid())
  email                       String              @unique
  emailVerifiedAt             DateTime?
  passwordHash                String?             // null if SSO-only
  authProvider                AuthProvider        @default(PASSWORD)
  googleSubjectId             String?             @unique // Google OAuth sub claim
  persona                     Persona
  verificationStatus          VerificationStatus  @default(VERIFIED) // students/faculty default verified
  name                        String
  branch                      String?             // for student/alumnus/former
  department                  String?             // for faculty
  semester                    Int?                // current semester for student
  batchYear                   Int?                // grad year for alumni / expected for student
  isLateralEntry              Boolean             @default(false) // for students
  currentRole                 String?             // for alumnus
  currentCompany              String?             // for alumnus
  linkedinUrl                 String?             // for alumnus
  bio                         String?             @db.VarChar(280)
  expertiseTagIds             String[]            // FK soft-link to Tag.id (denormalized for query convenience)
  hideActivity                Boolean             @default(false)
  noConnectionRequests        Boolean             @default(false)
  mfaEnabled                  Boolean             @default(false)
  mfaSecretEncrypted          String?
  repScore                    Int                 @default(0)
  failedLoginAttempts         Int                 @default(0)
  lockedUntil                 DateTime?           // login lockout
  lastLoginAt                 DateTime?
  createdAt                   DateTime            @default(now())
  updatedAt                   DateTime            @updatedAt
  deletedAt                   DateTime?           // soft-delete (14-day window)
  hardDeletedAt               DateTime?           // anonymization completed
  graduationConfirmationDueAt DateTime?           // for grad transition prompt
  graduationFlaggedAt         DateTime?           // 6+ months without confirmation

  adminRole                   AdminRole?
  questionsAsked              Question[]          @relation("QuestionAuthor")
  answersGiven                Answer[]            @relation("AnswerAuthor")
  comments                    Comment[]
  posts                       Post[]
  resources                   Resource[]
  votesGiven                  Vote[]
  reputationEvents            ReputationEvent[]
  badges                      Badge[]
  follows                     Follow[]
  followers                   Follow[]            @relation("FollowedUser")
  bookmarks                   Bookmark[]
  connectionsSent             ConnectionRequest[] @relation("ConnSender")
  connectionsReceived         ConnectionRequest[] @relation("ConnRecipient")
  messagesSent                Message[]
  blocksMade                  Block[]             @relation("Blocker")
  blocksAgainst               Block[]             @relation("Blocked")
  reportsFiled                Report[]            @relation("Reporter")
  reportsResolved             Report[]            @relation("Resolver")
  penalties                   PenaltyRecord[]
  notifications               Notification[]
  notificationPreferences     NotificationPreference[]
  tagSuggestions              TagSuggestion[]
  auditActions                AuditLogEntry[]     @relation("Actor")
  sessionRecords              SessionRecord[]
  pushSubscriptions           PushSubscription[]

  @@index([persona, verificationStatus])
  @@index([branch, semester])
  @@index([batchYear])
  @@index([deletedAt])
  @@index([repScore])
}

model AdminRole {
  userId      String    @id
  user        User      @relation(fields: [userId], references: [id])
  grantedById String
  grantedAt   DateTime  @default(now())
  revokedAt   DateTime?
}

model SessionRecord {
  id              String   @id @default(cuid())
  userId          String
  user            User     @relation(fields: [userId], references: [id])
  // Session ID is in Redis; this table records active sessions for audit/list
  redisSessionKey String
  userAgent       String?
  ipAddress       String?  // store for audit only; consider hashing for privacy
  createdAt       DateTime @default(now())
  lastSeenAt      DateTime @default(now())
  expiresAt       DateTime

  @@index([userId])
  @@index([expiresAt])
}

model PushSubscription {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  endpoint  String   @unique
  p256dh    String
  auth      String
  createdAt DateTime @default(now())

  @@index([userId])
}

// ============================================
// Q&A
// ============================================

model Question {
  id                String          @id @default(cuid())
  authorId          String
  author            User            @relation("QuestionAuthor", fields: [authorId], references: [id])
  title             String          @db.VarChar(120)
  body              String          @db.VarChar(5000)
  visibilityScope   VisibilityScope @default(INSTITUTION)
  anonymousFlag     Boolean         @default(false)
  acceptedAnswerId  String?         @unique
  acceptedAnswer    Answer?         @relation("AcceptedAnswer", fields: [acceptedAnswerId], references: [id])
  archivedAt        DateTime?
  archivedById      String?
  voteScore         Int             @default(0) // denormalized
  editCount         Int             @default(0)
  createdAt         DateTime        @default(now())
  editedAt          DateTime?
  searchVector      Unsupported("tsvector")? // GIN index in migration
  answers           Answer[]        @relation("QuestionAnswers")
  questionTags      QuestionTag[]

  @@index([authorId])
  @@index([createdAt(sort: Desc)])
  @@index([visibilityScope])
  @@index([archivedAt])
}

model Answer {
  id                  String     @id @default(cuid())
  questionId          String
  question            Question   @relation("QuestionAnswers", fields: [questionId], references: [id])
  authorId            String
  author              User       @relation("AnswerAuthor", fields: [authorId], references: [id])
  body                String     @db.VarChar(10000)
  voteScore           Int        @default(0) // denormalized
  acceptedAt          DateTime?
  facultyEndorsedBy   String[]   // array of User.id (faculty only)
  editCount           Int        @default(0)
  createdAt           DateTime   @default(now())
  editedAt            DateTime?
  acceptedAsAnswerFor Question?  @relation("AcceptedAnswer")
  searchVector        Unsupported("tsvector")?

  @@unique([questionId, authorId]) // one answer per user per question
  @@index([questionId])
  @@index([authorId])
  @@index([createdAt(sort: Desc)])
}

model Comment {
  id          String            @id @default(cuid())
  parentType  CommentParentType
  parentId    String
  authorId    String
  author      User              @relation(fields: [authorId], references: [id])
  body        String            @db.VarChar(2000)
  createdAt   DateTime          @default(now())

  @@index([parentType, parentId, createdAt])
  @@index([authorId])
}

// ============================================
// EXPERIENCE FEED
// ============================================

model Post {
  id            String        @id @default(cuid())
  authorId      String
  author        User          @relation(fields: [authorId], references: [id])
  title         String        @db.VarChar(120)
  body          String        @db.VarChar(15000)
  category      PostCategory
  pinned        Boolean       @default(false) // true for active faculty announcements
  expiryDate    DateTime?     // only for faculty announcements
  upvoteCount   Int           @default(0) // denormalized
  editCount     Int           @default(0)
  createdAt     DateTime      @default(now())
  editedAt      DateTime?
  deletedAt     DateTime?
  searchVector  Unsupported("tsvector")?
  postTags      PostTag[]

  @@index([category, createdAt(sort: Desc)])
  @@index([authorId])
  @@index([pinned, createdAt(sort: Desc)])
  @@index([deletedAt])
}

// ============================================
// RESOURCE LIBRARY
// ============================================

model Resource {
  id                String           @id @default(cuid())
  submitterId       String
  submitter         User             @relation(fields: [submitterId], references: [id])
  url               String
  title             String           @db.VarChar(120)
  description       String           @db.VarChar(500)
  category          ResourceCategory
  status            ResourceStatus   @default(PENDING)
  endorsedByIds     String[]         // faculty user IDs (array — bounded by faculty count)
  endorsementCount  Int              @default(0) // denormalized
  upvoteCount       Int              @default(0) // denormalized
  linkStatus        LinkStatus       @default(UNCHECKED)
  lastLinkCheckAt   DateTime?
  createdAt         DateTime         @default(now())
  updatedAt         DateTime         @updatedAt
  searchVector      Unsupported("tsvector")? // only indexed when status=LIBRARY
  resourceTags      ResourceTag[]

  @@index([status, category])
  @@index([submitterId])
  @@index([linkStatus])
}

// ============================================
// TAGS
// ============================================

model Tag {
  id              String           @id @default(cuid())
  name            String           @unique // canonical, lowercase, hyphenated
  description     String?          @db.VarChar(280)
  createdById     String           // must be admin
  mergedIntoId    String?          // FK to canonical Tag if this is a deprecated alias
  createdAt       DateTime         @default(now())

  questionTags    QuestionTag[]
  postTags        PostTag[]
  resourceTags    ResourceTag[]

  @@index([mergedIntoId])
}

model QuestionTag {
  questionId  String
  tagId       String
  question    Question @relation(fields: [questionId], references: [id], onDelete: Cascade)
  tag         Tag      @relation(fields: [tagId], references: [id])

  @@id([questionId, tagId])
  @@index([tagId])
}

model PostTag {
  postId  String
  tagId   String
  post    Post @relation(fields: [postId], references: [id], onDelete: Cascade)
  tag     Tag  @relation(fields: [tagId], references: [id])

  @@id([postId, tagId])
  @@index([tagId])
}

model ResourceTag {
  resourceId  String
  tagId       String
  resource    Resource @relation(fields: [resourceId], references: [id], onDelete: Cascade)
  tag         Tag      @relation(fields: [tagId], references: [id])

  @@id([resourceId, tagId])
  @@index([tagId])
}

model TagSuggestion {
  id            String              @id @default(cuid())
  suggesterId   String
  suggester     User                @relation(fields: [suggesterId], references: [id])
  proposedName  String
  context       String?             @db.VarChar(500)
  status        TagSuggestionStatus @default(PENDING)
  reviewedById  String?
  reviewedAt    DateTime?
  createdAt     DateTime            @default(now())

  @@index([status, createdAt])
}

// ============================================
// CONNECTIONS & DM
// ============================================

model ConnectionRequest {
  id              String           @id @default(cuid())
  senderId        String
  sender          User             @relation("ConnSender", fields: [senderId], references: [id])
  recipientId     String
  recipient       User             @relation("ConnRecipient", fields: [recipientId], references: [id])
  note            String           @db.VarChar(500)
  topic           String           @db.VarChar(120)
  status          ConnectionStatus @default(PENDING)
  declineReason   String?          @db.VarChar(500)
  expiresAt       DateTime
  decidedAt       DateTime?
  createdAt       DateTime         @default(now())

  @@index([senderId, status])
  @@index([recipientId, status])
  @@index([status, expiresAt])
}

model DMThread {
  id               String       @id @default(cuid())
  // Canonical ordering: userAId < userBId (lexicographic)
  userAId          String
  userBId          String
  status           ThreadStatus @default(ACTIVE)
  disconnectedAt   DateTime?
  disconnectedById String?
  createdAt        DateTime     @default(now())

  messages         Message[]

  @@unique([userAId, userBId])
  @@index([userAId])
  @@index([userBId])
}

model Message {
  id        String    @id @default(cuid())
  threadId  String
  thread    DMThread  @relation(fields: [threadId], references: [id])
  senderId  String
  sender    User      @relation(fields: [senderId], references: [id])
  body      String    @db.VarChar(5000)
  readAt    DateTime?
  createdAt DateTime  @default(now())

  @@index([threadId, createdAt])
  @@index([senderId])
}

model Block {
  id         String   @id @default(cuid())
  blockerId  String
  blocker    User     @relation("Blocker", fields: [blockerId], references: [id])
  blockedId  String
  blocked    User     @relation("Blocked", fields: [blockedId], references: [id])
  createdAt  DateTime @default(now())

  @@unique([blockerId, blockedId])
  @@index([blockedId])
}

// ============================================
// VOTING & REPUTATION
// ============================================

model Vote {
  id          String         @id @default(cuid())
  voterId     String
  voter       User           @relation(fields: [voterId], references: [id])
  targetType  VoteTargetType
  targetId    String
  direction   Int            // +1 or -1; constrained by check
  createdAt   DateTime       @default(now())

  @@unique([voterId, targetType, targetId])
  @@index([targetType, targetId])
}

model ReputationEvent {
  id              String              @id @default(cuid())
  userId          String
  user            User                @relation(fields: [userId], references: [id])
  delta           Int
  sourceType      ReputationEventType
  sourceId        String?             // points to source action (vote ID, answer ID, etc.)
  decayFactor     Decimal             @default(1.0) @db.Decimal(5, 4)
  effectiveValue  Decimal             @db.Decimal(10, 4) // denormalized: delta * decayFactor
  createdAt       DateTime            @default(now())
  decayedAt       DateTime?

  @@index([userId, createdAt])
  @@index([createdAt])
}

model Badge {
  id         String    @id @default(cuid())
  userId     String
  user       User      @relation(fields: [userId], references: [id])
  badgeType  BadgeType
  subTagId   String?   // for SUBJECT_SPECIALIST
  subYear    Int?      // for CLASS_OF
  earnedAt   DateTime  @default(now())
  revokedAt  DateTime?

  @@unique([userId, badgeType, subTagId, subYear])
  @@index([userId])
  @@index([badgeType])
}

// ============================================
// FOLLOWS & BOOKMARKS
// ============================================

model Follow {
  id           String           @id @default(cuid())
  followerId   String
  follower     User             @relation(fields: [followerId], references: [id])
  targetType   FollowTargetType
  targetId     String           // user ID, tag ID, or category enum value as string
  // Optional reverse relation when target is a User
  followedUser User?            @relation("FollowedUser", fields: [targetId], references: [id], map: "followed_user_fk")
  createdAt    DateTime         @default(now())

  @@unique([followerId, targetType, targetId])
  @@index([targetType, targetId])
}

model Bookmark {
  id         String              @id @default(cuid())
  userId     String
  user       User                @relation(fields: [userId], references: [id])
  targetType BookmarkTargetType
  targetId   String
  createdAt  DateTime            @default(now())

  @@unique([userId, targetType, targetId])
  @@index([targetType, targetId])
}

// ============================================
// REPORTS & MODERATION
// ============================================

model Report {
  id              String           @id @default(cuid())
  reporterId      String
  reporter        User             @relation("Reporter", fields: [reporterId], references: [id])
  targetType      ReportTargetType
  targetId        String
  reason          ReportReason
  freeText        String?          @db.VarChar(1000)
  status          ReportStatus     @default(OPEN)
  resolvedById    String?
  resolvedBy      User?            @relation("Resolver", fields: [resolvedById], references: [id])
  resolvedAt      DateTime?
  actionTaken     ReportAction     @default(NONE)
  severityLevel   String           // 'severe' | 'standard' — derived from reason
  resolutionNotes String?          @db.VarChar(2000)
  createdAt       DateTime         @default(now())

  @@index([status, severityLevel, createdAt])
  @@index([targetType, targetId])
  @@index([reporterId])
}

model PenaltyRecord {
  id              String       @id @default(cuid())
  userId          String
  user            User         @relation(fields: [userId], references: [id])
  type            PenaltyType
  relatedReportId String?
  reason          String       @db.VarChar(1000)
  issuedById      String       // admin
  issuedAt        DateTime     @default(now())
  expiresAt       DateTime?    // null for permanent ban

  @@index([userId, issuedAt(sort: Desc)])
  @@index([expiresAt])
}

// ============================================
// AUDIT & NOTIFICATIONS
// ============================================

model AuditLogEntry {
  id          String   @id @default(cuid())
  actorId     String
  actor       User     @relation("Actor", fields: [actorId], references: [id])
  action      String   // canonical string: 'verify_alumnus', 'suspend_user', etc.
  targetType  String?
  targetId    String?
  metadata    Json?
  createdAt   DateTime @default(now())

  // Append-only: enforce via Postgres role privileges (REVOKE UPDATE, DELETE)
  @@index([actorId, createdAt(sort: Desc)])
  @@index([targetType, targetId, createdAt(sort: Desc)])
  @@index([action, createdAt(sort: Desc)])
}

model Notification {
  id          String              @id @default(cuid())
  userId      String
  user        User                @relation(fields: [userId], references: [id])
  type        NotificationType
  content     Json                // { questionId, askerPersona, etc. }
  channel     NotificationChannel
  readAt      DateTime?
  deliveredAt DateTime?
  createdAt   DateTime            @default(now())

  @@index([userId, readAt, createdAt(sort: Desc)])
  @@index([userId, channel, createdAt(sort: Desc)])
  @@index([deliveredAt]) // for retry queries
}

model NotificationPreference {
  id        String              @id @default(cuid())
  userId    String
  user      User                @relation(fields: [userId], references: [id])
  category  NotificationType
  inApp     Boolean             @default(true)
  email     Boolean             @default(true)
  push      Boolean             @default(true)

  @@unique([userId, category])
}

// ============================================
// FEATURE FLAGS (lightweight)
// ============================================

model FeatureFlag {
  key         String   @id
  enabled     Boolean  @default(false)
  description String?
  updatedAt   DateTime @updatedAt
}

// ============================================
// PLATFORM CONFIG
// ============================================

model AcademicCalendar {
  id              String   @id @default(cuid())
  semesterLabel   String   // 'Spring 2026', 'Fall 2026'
  startsAt        DateTime
  endsAt          DateTime
  active          Boolean  @default(false) // only one active at a time

  @@index([active])
  @@index([startsAt])
}
```

---

## Migration Notes

### Initial Migration
1. Apply this schema to a fresh Postgres database via `pnpm prisma migrate dev --name init`.
2. After migration, manually apply Postgres-only enhancements:

```sql
-- GIN indexes for full-text search
CREATE INDEX question_search_idx ON "Question" USING GIN (search_vector);
CREATE INDEX answer_search_idx ON "Answer" USING GIN (search_vector);
CREATE INDEX post_search_idx ON "Post" USING GIN (search_vector);
CREATE INDEX resource_search_idx ON "Resource" USING GIN (search_vector) WHERE status = 'LIBRARY';

-- Triggers to maintain search_vector
CREATE FUNCTION question_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.body, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER question_search_update
  BEFORE INSERT OR UPDATE ON "Question"
  FOR EACH ROW EXECUTE FUNCTION question_search_trigger();
-- Repeat for Answer, Post, Resource

-- Audit log append-only protection
REVOKE UPDATE, DELETE ON "AuditLogEntry" FROM ascend_app_role;
GRANT INSERT, SELECT ON "AuditLogEntry" TO ascend_app_role;

-- Vote direction check constraint
ALTER TABLE "Vote" ADD CONSTRAINT vote_direction_check CHECK (direction IN (-1, 1));

-- Vote downvote restriction for upvote-only contexts
ALTER TABLE "Vote" ADD CONSTRAINT vote_no_downvote_post_pending CHECK (
  NOT (direction = -1 AND target_type IN ('POST', 'RESOURCE_PENDING'))
);

-- Connection request: prevent sending to self
ALTER TABLE "ConnectionRequest" ADD CONSTRAINT no_self_connection CHECK (sender_id <> recipient_id);

-- Block: prevent blocking self
ALTER TABLE "Block" ADD CONSTRAINT no_self_block CHECK (blocker_id <> blocked_id);

-- Reputation event check: delta is non-zero
ALTER TABLE "ReputationEvent" ADD CONSTRAINT rep_event_nonzero CHECK (delta <> 0);
```

3. Seed the academic calendar, tag taxonomy, and first admin via a seed script (see `packages/db/prisma/seed.ts`).

### Subsequent Migrations
- Always reviewed in PR.
- Forward-only (no `down` migrations applied to production; rollback via DB restore).
- Destructive changes require multi-deploy plan.

---

## Schema Decisions Worth Calling Out

**Why CUID over UUID:** CUIDs are shorter, collision-resistant, and don't leak sortable timestamps the way UUIDv1 does. UUIDs are fine; this is a minor preference.

**Why join tables for tags rather than `String[]`:** Earlier draft used `tags String[]`. Moved to QuestionTag/PostTag/ResourceTag for two reasons:
1. Easier indexed lookups ("all questions with this tag")
2. Cascade delete semantics

`User.expertiseTagIds` remains a `String[]` because it's a small, bounded set (max 5) and is not the primary lookup pattern.

**Why `searchVector Unsupported("tsvector")`:** Prisma doesn't natively support tsvector. We declare it as Unsupported so Prisma includes the column in migrations but doesn't try to query it through the client. Searches use raw SQL via `prisma.$queryRaw`.

**Why `endorsedByIds String[]` on Resource and `facultyEndorsedBy String[]` on Answer:** These are bounded by faculty count (~50-100 individuals). The simplicity of an array beats a join table here. Re-evaluate if faculty count grows materially.

**Why Notification.content as JSONB:** Notification payloads vary by type. JSONB allows flexible structure without polymorphic tables. Trade-off: weaker schema enforcement; mitigated by TypeScript types in application code.
