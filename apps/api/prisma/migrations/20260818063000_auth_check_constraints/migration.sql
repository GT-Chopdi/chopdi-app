-- Value constraints for the auth tables.
--
-- These live in the database rather than only in DTOs so that no code path can
-- bypass them: a future service method, a data-repair script, or a manual psql
-- session all hit the same wall. Prisma's DSL cannot express CHECK constraints,
-- so they are applied as raw SQL here.
--
-- Written as plain TEXT + CHECK rather than Postgres ENUM types deliberately.
-- Adding a value to an ENUM requires ALTER TYPE, which cannot run inside a
-- transaction block in older Postgres and is awkward to reverse; widening a
-- CHECK is a single ALTER TABLE.

ALTER TABLE "app_user"
  ADD CONSTRAINT "app_user_status_valid"
  CHECK ("status" IN ('active', 'suspended'));

ALTER TABLE "device"
  ADD CONSTRAINT "device_platform_valid"
  CHECK ("platform" IN ('android', 'ios'));

-- An OTP challenge must always be able to expire, and its attempt cap must be
-- meaningful. A row with max_attempts = 0 would be unverifiable; a negative
-- attempts count would let a caller wind the counter backwards.
ALTER TABLE "otp_challenge"
  ADD CONSTRAINT "otp_challenge_attempts_sane"
  CHECK ("attempts" >= 0 AND "max_attempts" > 0);
