-- AlterTable
ALTER TABLE "customer" ADD COLUMN     "name_key" TEXT NOT NULL DEFAULT '',
ADD COLUMN     "phone_key" TEXT NOT NULL DEFAULT '';

-- AlterTable
ALTER TABLE "ledger_entry" ADD COLUMN     "origin_device_id" UUID,
ADD COLUMN     "via_alias_id" UUID;

-- AlterTable
ALTER TABLE "lender" ADD COLUMN     "name_key" TEXT NOT NULL DEFAULT '',
ADD COLUMN     "phone_key" TEXT NOT NULL DEFAULT '';

-- CreateTable
CREATE TABLE "party_merge" (
    "alias_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "entity" TEXT NOT NULL,
    "main_id" UUID NOT NULL,
    "main_device_id" UUID,
    "alias_device_id" UUID,
    "alias_snapshot" JSONB NOT NULL,
    "source" TEXT NOT NULL DEFAULT 'sync',
    "winner" TEXT NOT NULL DEFAULT 'main',
    "merged_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "party_merge_pkey" PRIMARY KEY ("alias_id")
);

-- CreateIndex
CREATE INDEX "party_merge_main_id_idx" ON "party_merge"("main_id");

-- CreateIndex
CREATE INDEX "party_merge_user_id_idx" ON "party_merge"("user_id");

-- AddForeignKey
ALTER TABLE "party_merge" ADD CONSTRAINT "party_merge_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ------------------------------------------------------- matching key backfill

-- Must stay identical to partyKeys() in src/modules/sync/party-keys.ts: the
-- handler writes these on every create and update, and the cleanup script and
-- the unique index both compare rows written by either.
UPDATE "customer" SET
  "name_key"  = lower(regexp_replace(regexp_replace("name", '^[[:space:]]+|[[:space:]]+$', '', 'g'), '[[:space:]]+', ' ', 'g')),
  "phone_key" = right(regexp_replace(coalesce("phone_e164", ''), '[^0-9]', '', 'g'), 10);

UPDATE "lender" SET
  "name_key"  = lower(regexp_replace(regexp_replace("name", '^[[:space:]]+|[[:space:]]+$', '', 'g'), '[[:space:]]+', ' ', 'g')),
  "phone_key" = right(regexp_replace(coalesce("phone_e164", ''), '[^0-9]', '', 'g'), 10);

-- Lookup path for the duplicate check. Not unique yet: existing duplicates
-- have to be merged first (scripts/merge-duplicate-parties.mjs), after which
-- the party_merge_unique migration makes it a constraint.
CREATE INDEX "customer_match_key_idx" ON "customer"("user_id", "name_key", "phone_key");
CREATE INDEX "lender_match_key_idx" ON "lender"("user_id", "name_key", "phone_key");

-- ------------------------------------------------------ ledger_entry origin

-- The device that created each existing entry is already on its change-log
-- create row; copy it across so merges can tell the two devices' entries apart.
UPDATE "ledger_entry" e
   SET "origin_device_id" = l."device_id"
  FROM "sync_change_log" l
 WHERE l."entity" = 'ledger_entry'
   AND l."op_type" = 'create'
   AND l."entity_id" = e."id"
   AND e."origin_device_id" IS NULL;

CREATE INDEX "ledger_entry_via_alias_id_idx" ON "ledger_entry"("via_alias_id");

-- ------------------------------------------------------------- party_merge

ALTER TABLE "party_merge"
  ADD CONSTRAINT "party_merge_entity_valid"
  CHECK ("entity" IN ('customer', 'lender'));

ALTER TABLE "party_merge"
  ADD CONSTRAINT "party_merge_source_valid"
  CHECK ("source" IN ('sync', 'cleanup'));

ALTER TABLE "party_merge"
  ADD CONSTRAINT "party_merge_winner_valid"
  CHECK ("winner" IN ('main', 'alias'));

ALTER TABLE "party_merge"
  ADD CONSTRAINT "party_merge_not_self"
  CHECK ("alias_id" <> "main_id");

-- ---------------------------------------------------------- sync_change_log

-- `merge` tells other devices that an id they hold now lives under another.
ALTER TABLE "sync_change_log"
  DROP CONSTRAINT "sync_change_log_op_type_valid";

ALTER TABLE "sync_change_log"
  ADD CONSTRAINT "sync_change_log_op_type_valid"
  CHECK ("op_type" IN ('create', 'update', 'void', 'conflict', 'merge'));
