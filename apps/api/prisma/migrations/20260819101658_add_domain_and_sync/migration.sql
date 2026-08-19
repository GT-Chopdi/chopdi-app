-- AlterTable
ALTER TABLE "app_user" ADD COLUMN     "change_seq" BIGINT NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "customer" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "phone_e164" TEXT,
    "notes" TEXT NOT NULL DEFAULT '',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_entry" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "amount_paise" BIGINT NOT NULL,
    "direction" TEXT NOT NULL,
    "interest_rate_bp" INTEGER NOT NULL DEFAULT 0,
    "interest_type" TEXT NOT NULL DEFAULT 'none',
    "interest_frequency" TEXT NOT NULL DEFAULT 'monthly',
    "entry_date" DATE NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "payment_mode" TEXT NOT NULL DEFAULT '',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "voided_at" TIMESTAMPTZ(6),
    "voided_reason" TEXT,

    CONSTRAINT "ledger_entry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sync_operation" (
    "id" BIGSERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "op_id" UUID NOT NULL,
    "device_id" UUID NOT NULL,
    "entity" TEXT NOT NULL,
    "entity_id" UUID NOT NULL,
    "op_type" TEXT NOT NULL,
    "payload_hash" TEXT NOT NULL,
    "result_status" TEXT NOT NULL,
    "result_body" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sync_operation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sync_change_log" (
    "id" BIGSERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "seq" BIGINT NOT NULL,
    "entity" TEXT NOT NULL,
    "entity_id" UUID NOT NULL,
    "op_type" TEXT NOT NULL,
    "snapshot" JSONB NOT NULL,
    "previous" JSONB,
    "device_id" UUID,
    "op_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sync_change_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "customer_user_id_idx" ON "customer"("user_id");

-- CreateIndex
CREATE INDEX "ledger_entry_customer_id_entry_date_idx" ON "ledger_entry"("customer_id", "entry_date" DESC);

-- CreateIndex
CREATE INDEX "ledger_entry_user_id_idx" ON "ledger_entry"("user_id");

-- CreateIndex
CREATE INDEX "sync_operation_created_at_idx" ON "sync_operation"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "sync_operation_user_id_op_id_key" ON "sync_operation"("user_id", "op_id");

-- CreateIndex
CREATE INDEX "sync_change_log_user_id_seq_idx" ON "sync_change_log"("user_id", "seq");

-- CreateIndex
CREATE UNIQUE INDEX "sync_change_log_user_id_seq_key" ON "sync_change_log"("user_id", "seq");

-- AddForeignKey
ALTER TABLE "customer" ADD CONSTRAINT "customer_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entry" ADD CONSTRAINT "ledger_entry_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entry" ADD CONSTRAINT "ledger_entry_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_operation" ADD CONSTRAINT "sync_operation_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sync_change_log" ADD CONSTRAINT "sync_change_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;
