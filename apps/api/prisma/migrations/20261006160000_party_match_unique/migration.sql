-- One live customer (and one live lender) per user, book, name and phone.
--
-- The backstop behind MergeService: the handler takes the user's row lock
-- before checking for a match, so this should never fire through the API.
-- It exists for every other write path.
--
-- Created only when no duplicates exist. Databases that predate merging hold
-- duplicates until scripts/merge-duplicate-parties.mjs --apply folds them; that
-- script creates these same indexes when it finishes. Failing here instead would
-- block every deploy until the cleanup ran, coupling a code release to a data
-- operation that needs a human to approve its dry run first.
--
-- Expression indexes are invisible to Prisma's schema diff, so these live here
-- rather than in schema.prisma, like the CHECK constraints.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM "customer" WHERE "deleted_at" IS NULL
     GROUP BY "user_id", coalesce("chopdi_id"::text, ''), "name_key", "phone_key"
    HAVING count(*) > 1
  ) THEN
    CREATE UNIQUE INDEX IF NOT EXISTS "customer_match_key_unique"
      ON "customer" ("user_id", coalesce("chopdi_id"::text, ''), "name_key", "phone_key")
      WHERE "deleted_at" IS NULL;
  ELSE
    RAISE NOTICE 'customer has duplicates: run scripts/merge-duplicate-parties.mjs --apply';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM "lender" WHERE "deleted_at" IS NULL
     GROUP BY "user_id", coalesce("chopdi_id"::text, ''), "name_key", "phone_key"
    HAVING count(*) > 1
  ) THEN
    CREATE UNIQUE INDEX IF NOT EXISTS "lender_match_key_unique"
      ON "lender" ("user_id", coalesce("chopdi_id"::text, ''), "name_key", "phone_key")
      WHERE "deleted_at" IS NULL;
  ELSE
    RAISE NOTICE 'lender has duplicates: run scripts/merge-duplicate-parties.mjs --apply';
  END IF;
END $$;
