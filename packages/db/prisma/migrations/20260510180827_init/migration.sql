-- CreateEnum
CREATE TYPE "Persona" AS ENUM ('STUDENT', 'FACULTY', 'ALUMNUS', 'FORMER_STUDENT');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('PENDING', 'VERIFIED', 'REJECTED', 'LOCKED');

-- CreateEnum
CREATE TYPE "AuthProvider" AS ENUM ('PASSWORD', 'GOOGLE_SSO');

-- CreateEnum
CREATE TYPE "VisibilityScope" AS ENUM ('INSTITUTION', 'DEPARTMENT');

-- CreateEnum
CREATE TYPE "PostCategory" AS ENUM ('INTERNSHIP', 'PROJECT', 'HACKATHON', 'CAREER_JOURNEY', 'COURSE_REFLECTION', 'FACULTY_ANNOUNCEMENT');

-- CreateEnum
CREATE TYPE "ResourceCategory" AS ENUM ('COURSE_MATERIAL', 'TOOLS', 'REFERENCE', 'CAREER', 'HIGHER_STUDIES', 'INSPIRATION');

-- CreateEnum
CREATE TYPE "ResourceStatus" AS ENUM ('PENDING', 'LIBRARY', 'TOMBSTONE');

-- CreateEnum
CREATE TYPE "LinkStatus" AS ENUM ('OK', 'BROKEN', 'UNCHECKED');

-- CreateEnum
CREATE TYPE "CommentParentType" AS ENUM ('QUESTION', 'ANSWER', 'POST', 'RESOURCE');

-- CreateEnum
CREATE TYPE "VoteTargetType" AS ENUM ('QUESTION', 'ANSWER', 'POST', 'RESOURCE', 'RESOURCE_PENDING');

-- CreateEnum
CREATE TYPE "FollowTargetType" AS ENUM ('USER', 'TAG', 'CATEGORY');

-- CreateEnum
CREATE TYPE "BookmarkTargetType" AS ENUM ('QUESTION', 'ANSWER', 'POST', 'RESOURCE');

-- CreateEnum
CREATE TYPE "ConnectionStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'SILENTLY_DECLINED', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ThreadStatus" AS ENUM ('ACTIVE', 'READ_ONLY');

-- CreateEnum
CREATE TYPE "ReputationEventType" AS ENUM ('Q_UPVOTE', 'A_UPVOTE', 'A_ACCEPTED', 'Q_DOWNVOTE', 'A_DOWNVOTE', 'RESOURCE_ENDORSED', 'CONTENT_REMOVED');

-- CreateEnum
CREATE TYPE "BadgeType" AS ENUM ('HELPFUL', 'CONNECTOR', 'CURATOR', 'STORYTELLER', 'WELCOMER', 'RELIABLE', 'SUBJECT_SPECIALIST', 'SAGE', 'PILLAR', 'OPEN_DOOR', 'ELDER', 'CATALYST', 'CLASS_OF');

-- CreateEnum
CREATE TYPE "ReportTargetType" AS ENUM ('QUESTION', 'ANSWER', 'POST', 'COMMENT', 'RESOURCE', 'DM_MESSAGE', 'PROFILE');

-- CreateEnum
CREATE TYPE "ReportReason" AS ENUM ('SPAM', 'HARASSMENT', 'HATE_SPEECH', 'OFF_TOPIC', 'MISINFORMATION', 'PLAGIARISM', 'INAPPROPRIATE', 'IMPERSONATION', 'OTHER');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'RESOLVED', 'DISMISSED');

-- CreateEnum
CREATE TYPE "ReportAction" AS ENUM ('NONE', 'WARNED', 'CONTENT_REMOVED', 'USER_SUSPENDED_24H', 'USER_SUSPENDED_7D', 'USER_SUSPENDED_30D', 'USER_BANNED');

-- CreateEnum
CREATE TYPE "PenaltyType" AS ENUM ('WARNING', 'SUSPENSION_24H', 'SUSPENSION_7D', 'SUSPENSION_30D', 'PERMANENT_BAN');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('ANSWER_RECEIVED', 'COMMENT', 'ANSWER_ACCEPTED', 'ANSWER_ENDORSED', 'NEW_FOLLOWER', 'FOLLOWED_POST', 'BADGE_EARNED', 'CONNECTION_REQUEST', 'CONNECTION_ACCEPTED', 'CONNECTION_DECLINED', 'CONNECTION_EXPIRED', 'NEW_DM', 'MENTION', 'DEPT_ANNOUNCEMENT', 'REPORT_OUTCOME', 'CONTENT_REMOVED', 'VERIFICATION_APPROVED', 'VERIFICATION_REJECTED', 'RESOURCE_PROMOTED', 'DIGEST');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'EMAIL', 'PUSH');

-- CreateEnum
CREATE TYPE "TagSuggestionStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerifiedAt" TIMESTAMP(3),
    "passwordHash" TEXT,
    "authProvider" "AuthProvider" NOT NULL DEFAULT 'PASSWORD',
    "googleSubjectId" TEXT,
    "persona" "Persona" NOT NULL,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'VERIFIED',
    "name" TEXT NOT NULL,
    "branch" TEXT,
    "department" TEXT,
    "semester" INTEGER,
    "batchYear" INTEGER,
    "isLateralEntry" BOOLEAN NOT NULL DEFAULT false,
    "currentRole" TEXT,
    "currentCompany" TEXT,
    "linkedinUrl" TEXT,
    "bio" VARCHAR(280),
    "expertiseTagIds" TEXT[],
    "hideActivity" BOOLEAN NOT NULL DEFAULT false,
    "noConnectionRequests" BOOLEAN NOT NULL DEFAULT false,
    "mfaEnabled" BOOLEAN NOT NULL DEFAULT false,
    "mfaSecretEncrypted" TEXT,
    "repScore" INTEGER NOT NULL DEFAULT 0,
    "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    "hardDeletedAt" TIMESTAMP(3),
    "graduationConfirmationDueAt" TIMESTAMP(3),
    "graduationFlaggedAt" TIMESTAMP(3),

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdminRole" (
    "userId" TEXT NOT NULL,
    "grantedById" TEXT NOT NULL,
    "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "AdminRole_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "SessionRecord" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "redisSessionKey" TEXT NOT NULL,
    "userAgent" TEXT,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SessionRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PushSubscription" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "endpoint" TEXT NOT NULL,
    "p256dh" TEXT NOT NULL,
    "auth" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PushSubscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Question" (
    "id" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "title" VARCHAR(120) NOT NULL,
    "body" VARCHAR(5000) NOT NULL,
    "visibilityScope" "VisibilityScope" NOT NULL DEFAULT 'INSTITUTION',
    "anonymousFlag" BOOLEAN NOT NULL DEFAULT false,
    "acceptedAnswerId" TEXT,
    "archivedAt" TIMESTAMP(3),
    "archivedById" TEXT,
    "voteScore" INTEGER NOT NULL DEFAULT 0,
    "editCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "editedAt" TIMESTAMP(3),
    "searchVector" tsvector,

    CONSTRAINT "Question_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Answer" (
    "id" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "body" VARCHAR(10000) NOT NULL,
    "voteScore" INTEGER NOT NULL DEFAULT 0,
    "acceptedAt" TIMESTAMP(3),
    "facultyEndorsedBy" TEXT[],
    "editCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "editedAt" TIMESTAMP(3),
    "searchVector" tsvector,

    CONSTRAINT "Answer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Comment" (
    "id" TEXT NOT NULL,
    "parentType" "CommentParentType" NOT NULL,
    "parentId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "body" VARCHAR(2000) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Comment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Post" (
    "id" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "title" VARCHAR(120) NOT NULL,
    "body" VARCHAR(15000) NOT NULL,
    "category" "PostCategory" NOT NULL,
    "pinned" BOOLEAN NOT NULL DEFAULT false,
    "expiryDate" TIMESTAMP(3),
    "upvoteCount" INTEGER NOT NULL DEFAULT 0,
    "editCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "editedAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "searchVector" tsvector,

    CONSTRAINT "Post_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Resource" (
    "id" TEXT NOT NULL,
    "submitterId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "title" VARCHAR(120) NOT NULL,
    "description" VARCHAR(500) NOT NULL,
    "category" "ResourceCategory" NOT NULL,
    "status" "ResourceStatus" NOT NULL DEFAULT 'PENDING',
    "endorsedByIds" TEXT[],
    "endorsementCount" INTEGER NOT NULL DEFAULT 0,
    "upvoteCount" INTEGER NOT NULL DEFAULT 0,
    "linkStatus" "LinkStatus" NOT NULL DEFAULT 'UNCHECKED',
    "lastLinkCheckAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "searchVector" tsvector,

    CONSTRAINT "Resource_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tag" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" VARCHAR(280),
    "createdById" TEXT NOT NULL,
    "mergedIntoId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Tag_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuestionTag" (
    "questionId" TEXT NOT NULL,
    "tagId" TEXT NOT NULL,

    CONSTRAINT "QuestionTag_pkey" PRIMARY KEY ("questionId","tagId")
);

-- CreateTable
CREATE TABLE "PostTag" (
    "postId" TEXT NOT NULL,
    "tagId" TEXT NOT NULL,

    CONSTRAINT "PostTag_pkey" PRIMARY KEY ("postId","tagId")
);

-- CreateTable
CREATE TABLE "ResourceTag" (
    "resourceId" TEXT NOT NULL,
    "tagId" TEXT NOT NULL,

    CONSTRAINT "ResourceTag_pkey" PRIMARY KEY ("resourceId","tagId")
);

-- CreateTable
CREATE TABLE "TagSuggestion" (
    "id" TEXT NOT NULL,
    "suggesterId" TEXT NOT NULL,
    "proposedName" TEXT NOT NULL,
    "context" VARCHAR(500),
    "status" "TagSuggestionStatus" NOT NULL DEFAULT 'PENDING',
    "reviewedById" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TagSuggestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConnectionRequest" (
    "id" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "recipientId" TEXT NOT NULL,
    "note" VARCHAR(500) NOT NULL,
    "topic" VARCHAR(120) NOT NULL,
    "status" "ConnectionStatus" NOT NULL DEFAULT 'PENDING',
    "declineReason" VARCHAR(500),
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "decidedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ConnectionRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DMThread" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "status" "ThreadStatus" NOT NULL DEFAULT 'ACTIVE',
    "disconnectedAt" TIMESTAMP(3),
    "disconnectedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DMThread_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Message" (
    "id" TEXT NOT NULL,
    "threadId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "body" VARCHAR(5000) NOT NULL,
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Block" (
    "id" TEXT NOT NULL,
    "blockerId" TEXT NOT NULL,
    "blockedId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Block_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Vote" (
    "id" TEXT NOT NULL,
    "voterId" TEXT NOT NULL,
    "targetType" "VoteTargetType" NOT NULL,
    "targetId" TEXT NOT NULL,
    "direction" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Vote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReputationEvent" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "delta" INTEGER NOT NULL,
    "sourceType" "ReputationEventType" NOT NULL,
    "sourceId" TEXT,
    "decayFactor" DECIMAL(5,4) NOT NULL DEFAULT 1.0,
    "effectiveValue" DECIMAL(10,4) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decayedAt" TIMESTAMP(3),

    CONSTRAINT "ReputationEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Badge" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "badgeType" "BadgeType" NOT NULL,
    "subTagId" TEXT,
    "subYear" INTEGER,
    "earnedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "Badge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Follow" (
    "id" TEXT NOT NULL,
    "followerId" TEXT NOT NULL,
    "targetType" "FollowTargetType" NOT NULL,
    "targetId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Follow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Bookmark" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "targetType" "BookmarkTargetType" NOT NULL,
    "targetId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Bookmark_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Report" (
    "id" TEXT NOT NULL,
    "reporterId" TEXT NOT NULL,
    "targetType" "ReportTargetType" NOT NULL,
    "targetId" TEXT NOT NULL,
    "reason" "ReportReason" NOT NULL,
    "freeText" VARCHAR(1000),
    "status" "ReportStatus" NOT NULL DEFAULT 'OPEN',
    "resolvedById" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "actionTaken" "ReportAction" NOT NULL DEFAULT 'NONE',
    "severityLevel" TEXT NOT NULL,
    "resolutionNotes" VARCHAR(2000),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PenaltyRecord" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "PenaltyType" NOT NULL,
    "relatedReportId" TEXT,
    "reason" VARCHAR(1000) NOT NULL,
    "issuedById" TEXT NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "PenaltyRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLogEntry" (
    "id" TEXT NOT NULL,
    "actorId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "targetType" TEXT,
    "targetId" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLogEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "content" JSONB NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "readAt" TIMESTAMP(3),
    "deliveredAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NotificationPreference" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "category" "NotificationType" NOT NULL,
    "inApp" BOOLEAN NOT NULL DEFAULT true,
    "email" BOOLEAN NOT NULL DEFAULT true,
    "push" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "NotificationPreference_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeatureFlag" (
    "key" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "description" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FeatureFlag_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "AcademicCalendar" (
    "id" TEXT NOT NULL,
    "semesterLabel" TEXT NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3) NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "AcademicCalendar_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_googleSubjectId_key" ON "User"("googleSubjectId");

-- CreateIndex
CREATE INDEX "User_persona_verificationStatus_idx" ON "User"("persona", "verificationStatus");

-- CreateIndex
CREATE INDEX "User_branch_semester_idx" ON "User"("branch", "semester");

-- CreateIndex
CREATE INDEX "User_batchYear_idx" ON "User"("batchYear");

-- CreateIndex
CREATE INDEX "User_deletedAt_idx" ON "User"("deletedAt");

-- CreateIndex
CREATE INDEX "User_repScore_idx" ON "User"("repScore");

-- CreateIndex
CREATE INDEX "SessionRecord_userId_idx" ON "SessionRecord"("userId");

-- CreateIndex
CREATE INDEX "SessionRecord_expiresAt_idx" ON "SessionRecord"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "PushSubscription_endpoint_key" ON "PushSubscription"("endpoint");

-- CreateIndex
CREATE INDEX "PushSubscription_userId_idx" ON "PushSubscription"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Question_acceptedAnswerId_key" ON "Question"("acceptedAnswerId");

-- CreateIndex
CREATE INDEX "Question_authorId_idx" ON "Question"("authorId");

-- CreateIndex
CREATE INDEX "Question_createdAt_idx" ON "Question"("createdAt" DESC);

-- CreateIndex
CREATE INDEX "Question_visibilityScope_idx" ON "Question"("visibilityScope");

-- CreateIndex
CREATE INDEX "Question_archivedAt_idx" ON "Question"("archivedAt");

-- CreateIndex
CREATE INDEX "Answer_questionId_idx" ON "Answer"("questionId");

-- CreateIndex
CREATE INDEX "Answer_authorId_idx" ON "Answer"("authorId");

-- CreateIndex
CREATE INDEX "Answer_createdAt_idx" ON "Answer"("createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "Answer_questionId_authorId_key" ON "Answer"("questionId", "authorId");

-- CreateIndex
CREATE INDEX "Comment_parentType_parentId_createdAt_idx" ON "Comment"("parentType", "parentId", "createdAt");

-- CreateIndex
CREATE INDEX "Comment_authorId_idx" ON "Comment"("authorId");

-- CreateIndex
CREATE INDEX "Post_category_createdAt_idx" ON "Post"("category", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Post_authorId_idx" ON "Post"("authorId");

-- CreateIndex
CREATE INDEX "Post_pinned_createdAt_idx" ON "Post"("pinned", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Post_deletedAt_idx" ON "Post"("deletedAt");

-- CreateIndex
CREATE INDEX "Resource_status_category_idx" ON "Resource"("status", "category");

-- CreateIndex
CREATE INDEX "Resource_submitterId_idx" ON "Resource"("submitterId");

-- CreateIndex
CREATE INDEX "Resource_linkStatus_idx" ON "Resource"("linkStatus");

-- CreateIndex
CREATE UNIQUE INDEX "Tag_name_key" ON "Tag"("name");

-- CreateIndex
CREATE INDEX "Tag_mergedIntoId_idx" ON "Tag"("mergedIntoId");

-- CreateIndex
CREATE INDEX "QuestionTag_tagId_idx" ON "QuestionTag"("tagId");

-- CreateIndex
CREATE INDEX "PostTag_tagId_idx" ON "PostTag"("tagId");

-- CreateIndex
CREATE INDEX "ResourceTag_tagId_idx" ON "ResourceTag"("tagId");

-- CreateIndex
CREATE INDEX "TagSuggestion_status_createdAt_idx" ON "TagSuggestion"("status", "createdAt");

-- CreateIndex
CREATE INDEX "ConnectionRequest_senderId_status_idx" ON "ConnectionRequest"("senderId", "status");

-- CreateIndex
CREATE INDEX "ConnectionRequest_recipientId_status_idx" ON "ConnectionRequest"("recipientId", "status");

-- CreateIndex
CREATE INDEX "ConnectionRequest_status_expiresAt_idx" ON "ConnectionRequest"("status", "expiresAt");

-- CreateIndex
CREATE INDEX "DMThread_userAId_idx" ON "DMThread"("userAId");

-- CreateIndex
CREATE INDEX "DMThread_userBId_idx" ON "DMThread"("userBId");

-- CreateIndex
CREATE UNIQUE INDEX "DMThread_userAId_userBId_key" ON "DMThread"("userAId", "userBId");

-- CreateIndex
CREATE INDEX "Message_threadId_createdAt_idx" ON "Message"("threadId", "createdAt");

-- CreateIndex
CREATE INDEX "Message_senderId_idx" ON "Message"("senderId");

-- CreateIndex
CREATE INDEX "Block_blockedId_idx" ON "Block"("blockedId");

-- CreateIndex
CREATE UNIQUE INDEX "Block_blockerId_blockedId_key" ON "Block"("blockerId", "blockedId");

-- CreateIndex
CREATE INDEX "Vote_targetType_targetId_idx" ON "Vote"("targetType", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "Vote_voterId_targetType_targetId_key" ON "Vote"("voterId", "targetType", "targetId");

-- CreateIndex
CREATE INDEX "ReputationEvent_userId_createdAt_idx" ON "ReputationEvent"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "ReputationEvent_createdAt_idx" ON "ReputationEvent"("createdAt");

-- CreateIndex
CREATE INDEX "Badge_userId_idx" ON "Badge"("userId");

-- CreateIndex
CREATE INDEX "Badge_badgeType_idx" ON "Badge"("badgeType");

-- CreateIndex
CREATE UNIQUE INDEX "Badge_userId_badgeType_subTagId_subYear_key" ON "Badge"("userId", "badgeType", "subTagId", "subYear");

-- CreateIndex
CREATE INDEX "Follow_targetType_targetId_idx" ON "Follow"("targetType", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "Follow_followerId_targetType_targetId_key" ON "Follow"("followerId", "targetType", "targetId");

-- CreateIndex
CREATE INDEX "Bookmark_targetType_targetId_idx" ON "Bookmark"("targetType", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "Bookmark_userId_targetType_targetId_key" ON "Bookmark"("userId", "targetType", "targetId");

-- CreateIndex
CREATE INDEX "Report_status_severityLevel_createdAt_idx" ON "Report"("status", "severityLevel", "createdAt");

-- CreateIndex
CREATE INDEX "Report_targetType_targetId_idx" ON "Report"("targetType", "targetId");

-- CreateIndex
CREATE INDEX "Report_reporterId_idx" ON "Report"("reporterId");

-- CreateIndex
CREATE INDEX "PenaltyRecord_userId_issuedAt_idx" ON "PenaltyRecord"("userId", "issuedAt" DESC);

-- CreateIndex
CREATE INDEX "PenaltyRecord_expiresAt_idx" ON "PenaltyRecord"("expiresAt");

-- CreateIndex
CREATE INDEX "AuditLogEntry_actorId_createdAt_idx" ON "AuditLogEntry"("actorId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "AuditLogEntry_targetType_targetId_createdAt_idx" ON "AuditLogEntry"("targetType", "targetId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "AuditLogEntry_action_createdAt_idx" ON "AuditLogEntry"("action", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Notification_userId_readAt_createdAt_idx" ON "Notification"("userId", "readAt", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Notification_userId_channel_createdAt_idx" ON "Notification"("userId", "channel", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "Notification_deliveredAt_idx" ON "Notification"("deliveredAt");

-- CreateIndex
CREATE UNIQUE INDEX "NotificationPreference_userId_category_key" ON "NotificationPreference"("userId", "category");

-- CreateIndex
CREATE INDEX "AcademicCalendar_active_idx" ON "AcademicCalendar"("active");

-- CreateIndex
CREATE INDEX "AcademicCalendar_startsAt_idx" ON "AcademicCalendar"("startsAt");

-- AddForeignKey
ALTER TABLE "AdminRole" ADD CONSTRAINT "AdminRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionRecord" ADD CONSTRAINT "SessionRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PushSubscription" ADD CONSTRAINT "PushSubscription_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Question" ADD CONSTRAINT "Question_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Question" ADD CONSTRAINT "Question_acceptedAnswerId_fkey" FOREIGN KEY ("acceptedAnswerId") REFERENCES "Answer"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Answer" ADD CONSTRAINT "Answer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Answer" ADD CONSTRAINT "Answer_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Post" ADD CONSTRAINT "Post_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Resource" ADD CONSTRAINT "Resource_submitterId_fkey" FOREIGN KEY ("submitterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionTag" ADD CONSTRAINT "QuestionTag_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionTag" ADD CONSTRAINT "QuestionTag_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES "Tag"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PostTag" ADD CONSTRAINT "PostTag_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PostTag" ADD CONSTRAINT "PostTag_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES "Tag"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResourceTag" ADD CONSTRAINT "ResourceTag_resourceId_fkey" FOREIGN KEY ("resourceId") REFERENCES "Resource"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResourceTag" ADD CONSTRAINT "ResourceTag_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES "Tag"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TagSuggestion" ADD CONSTRAINT "TagSuggestion_suggesterId_fkey" FOREIGN KEY ("suggesterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectionRequest" ADD CONSTRAINT "ConnectionRequest_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConnectionRequest" ADD CONSTRAINT "ConnectionRequest_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_threadId_fkey" FOREIGN KEY ("threadId") REFERENCES "DMThread"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Block" ADD CONSTRAINT "Block_blockerId_fkey" FOREIGN KEY ("blockerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Block" ADD CONSTRAINT "Block_blockedId_fkey" FOREIGN KEY ("blockedId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Vote" ADD CONSTRAINT "Vote_voterId_fkey" FOREIGN KEY ("voterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReputationEvent" ADD CONSTRAINT "ReputationEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Badge" ADD CONSTRAINT "Badge_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Follow" ADD CONSTRAINT "Follow_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Follow" ADD CONSTRAINT "followed_user_fk" FOREIGN KEY ("targetId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Bookmark" ADD CONSTRAINT "Bookmark_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_resolvedById_fkey" FOREIGN KEY ("resolvedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PenaltyRecord" ADD CONSTRAINT "PenaltyRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLogEntry" ADD CONSTRAINT "AuditLogEntry_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NotificationPreference" ADD CONSTRAINT "NotificationPreference_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
