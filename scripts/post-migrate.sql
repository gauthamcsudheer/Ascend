-- Post-migration enhancements that Prisma cannot express in schema.prisma.
-- Run once after the initial migration: scripts/run-post-migrate.sh

-- ============================================================
-- FULL-TEXT SEARCH: GIN indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS question_search_idx ON "Question" USING GIN ("searchVector");
CREATE INDEX IF NOT EXISTS answer_search_idx   ON "Answer"   USING GIN ("searchVector");
CREATE INDEX IF NOT EXISTS post_search_idx     ON "Post"     USING GIN ("searchVector");
CREATE INDEX IF NOT EXISTS resource_search_idx ON "Resource" USING GIN ("searchVector")
  WHERE status = 'LIBRARY';

-- ============================================================
-- FULL-TEXT SEARCH: triggers to maintain searchVector columns
-- ============================================================

CREATE OR REPLACE FUNCTION question_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW."searchVector" :=
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.body,  '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER question_search_update
  BEFORE INSERT OR UPDATE ON "Question"
  FOR EACH ROW EXECUTE FUNCTION question_search_trigger();

-- ---

CREATE OR REPLACE FUNCTION answer_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW."searchVector" :=
    setweight(to_tsvector('english', coalesce(NEW.body, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER answer_search_update
  BEFORE INSERT OR UPDATE ON "Answer"
  FOR EACH ROW EXECUTE FUNCTION answer_search_trigger();

-- ---

CREATE OR REPLACE FUNCTION post_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW."searchVector" :=
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.body,  '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER post_search_update
  BEFORE INSERT OR UPDATE ON "Post"
  FOR EACH ROW EXECUTE FUNCTION post_search_trigger();

-- ---

CREATE OR REPLACE FUNCTION resource_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW."searchVector" :=
    setweight(to_tsvector('english', coalesce(NEW.title,       '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER resource_search_update
  BEFORE INSERT OR UPDATE ON "Resource"
  FOR EACH ROW EXECUTE FUNCTION resource_search_trigger();

-- ============================================================
-- CHECK CONSTRAINTS
-- ============================================================

ALTER TABLE "Vote"
  ADD CONSTRAINT vote_direction_check
  CHECK (direction IN (-1, 1));

ALTER TABLE "Vote"
  ADD CONSTRAINT vote_no_downvote_post_pending
  CHECK (NOT (direction = -1 AND "targetType" IN ('POST', 'RESOURCE_PENDING')));

ALTER TABLE "ConnectionRequest"
  ADD CONSTRAINT no_self_connection
  CHECK ("senderId" <> "recipientId");

ALTER TABLE "Block"
  ADD CONSTRAINT no_self_block
  CHECK ("blockerId" <> "blockedId");

ALTER TABLE "ReputationEvent"
  ADD CONSTRAINT rep_event_nonzero
  CHECK (delta <> 0);

-- ============================================================
-- NOTE: AuditLogEntry append-only REVOKE is a production-only
-- step (requires ascend_app_role to exist). Skip in local dev.
-- ============================================================
