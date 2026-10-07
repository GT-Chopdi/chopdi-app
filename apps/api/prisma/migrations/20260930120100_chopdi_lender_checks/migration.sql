-- Value constraints for books (chopdi) and lenders, and the widened sync
-- vocabulary. Same reasoning as domain_check_constraints: a DTO protects one
-- code path, a CHECK protects all of them.

-- ------------------------------------------------------------------ chopdi ---

ALTER TABLE "chopdi"
  ADD CONSTRAINT "chopdi_name_not_blank"
  CHECK (length(btrim("name")) > 0);

ALTER TABLE "chopdi"
  ADD CONSTRAINT "chopdi_version_positive"
  CHECK ("version" >= 1);

-- ------------------------------------------------------------------ lender ---

ALTER TABLE "lender"
  ADD CONSTRAINT "lender_name_not_blank"
  CHECK (length(btrim("name")) > 0);

ALTER TABLE "lender"
  ADD CONSTRAINT "lender_version_positive"
  CHECK ("version" >= 1);

-- ------------------------------------------------------------ ledger_entry ---

-- An entry belongs to exactly one party: a customer (I gave) or a lender (I
-- took). Neither would orphan it; both would count it in two ledgers.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_one_parent"
  CHECK (num_nonnulls("customer_id", "lender_id") = 1);

-- ---------------------------------------------------------- sync_operation ---

ALTER TABLE "sync_operation"
  DROP CONSTRAINT "sync_operation_entity_valid";

ALTER TABLE "sync_operation"
  ADD CONSTRAINT "sync_operation_entity_valid"
  CHECK ("entity" IN ('chopdi', 'customer', 'lender', 'ledger_entry'));
