-- Value constraints and the append-only guarantee.
--
-- These live in the database, not only in DTOs, because a DTO protects one code
-- path. A CHECK constraint protects every path — a future endpoint, a script, a
-- careless migration, a compromised service.

-- ---------------------------------------------------------------- app_user ---

ALTER TABLE "app_user"
  ADD CONSTRAINT "app_user_change_seq_non_negative"
  CHECK ("change_seq" >= 0);

-- ---------------------------------------------------------------- customer ---

-- A blank name makes a customer unidentifiable in a list of hundreds.
ALTER TABLE "customer"
  ADD CONSTRAINT "customer_name_not_blank"
  CHECK (length(btrim("name")) > 0);

ALTER TABLE "customer"
  ADD CONSTRAINT "customer_version_positive"
  CHECK ("version" >= 1);

-- ------------------------------------------------------------ ledger_entry ---

-- Amounts are strictly positive; `direction` carries the sign. This makes a
-- negative amount structurally unrepresentable rather than merely rejected —
-- there is no code path, including a future one, that can create a phantom
-- credit by sending -500000.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_amount_positive"
  CHECK ("amount_paise" > 0);

-- ₹100 crore. A business ceiling, not a technical one: it turns an overflow
-- probe or a fat-fingered extra zero into a rejected write instead of a
-- plausible-looking debt.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_amount_sane"
  CHECK ("amount_paise" <= 10000000000000);

-- 0% to 10000% in basis points.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_rate_sane"
  CHECK ("interest_rate_bp" BETWEEN 0 AND 1000000);

-- Enum-like columns. Exact match, so a trailing space cannot slip past a naive
-- equality check elsewhere.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_direction_valid"
  CHECK ("direction" IN ('gave', 'received'));

ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_interest_type_valid"
  CHECK ("interest_type" IN ('none', 'simple', 'compound'));

ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_interest_frequency_valid"
  CHECK ("interest_frequency" IN ('daily', 'weekly', 'monthly', 'yearly'));

ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_version_positive"
  CHECK ("version" >= 1);

-- A voided entry must say why, so the audit trail explains itself.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_void_has_reason"
  CHECK ("voided_at" IS NULL OR "voided_reason" IS NOT NULL);

-- ---------------------------------------------------------- sync_operation ---

ALTER TABLE "sync_operation"
  ADD CONSTRAINT "sync_operation_entity_valid"
  CHECK ("entity" IN ('customer', 'ledger_entry'));

ALTER TABLE "sync_operation"
  ADD CONSTRAINT "sync_operation_op_type_valid"
  CHECK ("op_type" IN ('create', 'update', 'void'));

ALTER TABLE "sync_operation"
  ADD CONSTRAINT "sync_operation_result_status_valid"
  CHECK ("result_status" IN ('applied', 'duplicate', 'conflict', 'rejected'));

-- --------------------------------------------------------- sync_change_log ---

ALTER TABLE "sync_change_log"
  ADD CONSTRAINT "sync_change_log_seq_positive"
  CHECK ("seq" > 0);

ALTER TABLE "sync_change_log"
  ADD CONSTRAINT "sync_change_log_op_type_valid"
  CHECK ("op_type" IN ('create', 'update', 'void', 'conflict'));

-- A create has nothing before it; anything else must record what it replaced,
-- or the log is a change feed rather than an audit trail.
ALTER TABLE "sync_change_log"
  ADD CONSTRAINT "sync_change_log_previous_present"
  CHECK ("op_type" = 'create' OR "previous" IS NOT NULL);

-- Append-only enforcement.
--
-- A trigger rather than REVOKE UPDATE, DELETE. The application connects to Neon
-- as the database owner, and an owner's privileges cannot be meaningfully
-- revoked — it can simply GRANT them back. A trigger binds everyone, owner
-- included, and removing it requires deliberate, visible DDL.
--
-- DELETE is permitted only beyond the retention horizon, so the Phase 4
-- retention job can prune genuinely old partitions while no code path can erase
-- recent history. UPDATE is never permitted: rewriting an audit row in place is
-- exactly the tampering this exists to prevent.
CREATE OR REPLACE FUNCTION sync_change_log_append_only()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION
      'sync_change_log is append-only: UPDATE is never permitted (id=%)', OLD.id
      USING ERRCODE = 'check_violation';
  END IF;

  IF OLD.created_at > now() - interval '180 days' THEN
    RAISE EXCEPTION
      'sync_change_log row % is within the 180-day retention window and cannot be deleted', OLD.id
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_change_log_append_only_trigger
  BEFORE UPDATE OR DELETE ON "sync_change_log"
  FOR EACH ROW EXECUTE FUNCTION sync_change_log_append_only();
