-- Default book per user, and removal of redundant indexes.
--
-- Every statement is idempotent (IF [NOT] EXISTS, NOT EXISTS guards), so a run
-- that is interrupted part-way can be finished by marking the migration rolled
-- back (`prisma migrate resolve --rolled-back <name>`) and deploying again,
-- without duplicating a default book or failing on an index that is already
-- gone.

-- ------------------------------------------------------------ chopdi default

ALTER TABLE "chopdi" ADD COLUMN IF NOT EXISTS "is_default" BOOLEAN NOT NULL DEFAULT false;

-- At most one live default per user. Partial, so a deleted default never
-- blocks its replacement. Not expressible in schema.prisma, like the CHECKs.
CREATE UNIQUE INDEX IF NOT EXISTS "chopdi_one_default_per_user"
  ON "chopdi" ("user_id")
  WHERE "is_default" AND "deleted_at" IS NULL;

-- Give every existing user their default book, logged as a `create` so devices
-- receive it on their next pull. The sequence is taken exactly as
-- ChangeLogService.nextSequence takes it — `change_seq + 1` on the user's row,
-- which locks that row until commit — so these rows interleave correctly with
-- any push running at the same time. Users created after this migration get
-- theirs at sign-in (DefaultChopdiService).
--
-- Name, description and the snapshot shape must match DEFAULT_CHOPDI and
-- chopdiSnapshot() in src/modules/sync/handlers/chopdi.handler.ts.
-- Timestamps are truncated to milliseconds so the row and its snapshot agree.
WITH "new_book" AS (
  INSERT INTO "chopdi" ("id", "user_id", "name", "description", "is_default", "version", "created_at", "updated_at")
  SELECT gen_random_uuid(), u."id", 'My Chopdi', E'My personal lending ledger\nto track loans and interest.',
         true, 1, date_trunc('milliseconds', now()), date_trunc('milliseconds', now())
    FROM "app_user" u
   WHERE NOT EXISTS (
     SELECT 1 FROM "chopdi" c
      WHERE c."user_id" = u."id" AND c."is_default" AND c."deleted_at" IS NULL
   )
  RETURNING *
),
"bumped" AS (
  UPDATE "app_user" u
     SET "change_seq" = u."change_seq" + 1
    FROM "new_book" b
   WHERE u."id" = b."user_id"
  RETURNING u."id" AS "user_id", u."change_seq" AS "seq"
)
INSERT INTO "sync_change_log" ("user_id", "seq", "entity", "entity_id", "op_type", "snapshot")
SELECT b."user_id", s."seq", 'chopdi', b."id", 'create',
       jsonb_build_object(
         'id',          b."id",
         'name',        b."name",
         'description', b."description",
         'isDefault',   b."is_default",
         'version',     b."version",
         'createdAt',   to_char(b."created_at" AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
         'updatedAt',   to_char(b."updated_at" AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
         'deletedAt',   NULL
       )
  FROM "new_book" b
  JOIN "bumped" s ON s."user_id" = b."user_id";

-- --------------------------------------------------------- redundant indexes

-- Each duplicates the leading column(s) of another index on the same table,
-- which serves every query it did. On Neon before this migration:
--   sync_change_log_user_id_seq_idx  0 scans — same columns as the unique key
--   device_user_id_idx               0 scans — prefix of (user_id, install_id)
--   customer_user_id_idx, lender_user_id_idx — prefix of *_match_key_idx
-- Dropping them saves a write per insert and ~150 kB today.
DROP INDEX IF EXISTS "sync_change_log_user_id_seq_idx";
DROP INDEX IF EXISTS "device_user_id_idx";
DROP INDEX IF EXISTS "customer_user_id_idx";
DROP INDEX IF EXISTS "lender_user_id_idx";
