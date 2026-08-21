-- Constrain ledger_side to the two values the client can produce.
--
-- Enum-like and exact, matching how direction is handled: a value the
-- application never intends must be rejected by the database, not merely
-- unlikely. Without this a typo syncs cleanly and is only noticed when a
-- balance looks wrong months later.
ALTER TABLE "ledger_entry"
  ADD CONSTRAINT "ledger_entry_ledger_side_valid"
  CHECK ("ledger_side" IN ('lent', 'borrowed'));
