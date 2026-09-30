-- AlterTable
ALTER TABLE "customer" ADD COLUMN     "chopdi_id" UUID;

-- AlterTable
ALTER TABLE "ledger_entry" ADD COLUMN     "lender_id" UUID,
ALTER COLUMN "customer_id" DROP NOT NULL;

-- CreateTable
CREATE TABLE "chopdi" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "chopdi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lender" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "chopdi_id" UUID,
    "name" TEXT NOT NULL,
    "phone_e164" TEXT,
    "notes" TEXT NOT NULL DEFAULT '',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "lender_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "chopdi_user_id_idx" ON "chopdi"("user_id");

-- CreateIndex
CREATE INDEX "lender_user_id_idx" ON "lender"("user_id");

-- CreateIndex
CREATE INDEX "lender_chopdi_id_idx" ON "lender"("chopdi_id");

-- CreateIndex
CREATE INDEX "customer_chopdi_id_idx" ON "customer"("chopdi_id");

-- CreateIndex
CREATE INDEX "ledger_entry_lender_id_entry_date_idx" ON "ledger_entry"("lender_id", "entry_date" DESC);

-- AddForeignKey
ALTER TABLE "chopdi" ADD CONSTRAINT "chopdi_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer" ADD CONSTRAINT "customer_chopdi_id_fkey" FOREIGN KEY ("chopdi_id") REFERENCES "chopdi"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lender" ADD CONSTRAINT "lender_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lender" ADD CONSTRAINT "lender_chopdi_id_fkey" FOREIGN KEY ("chopdi_id") REFERENCES "chopdi"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entry" ADD CONSTRAINT "ledger_entry_lender_id_fkey" FOREIGN KEY ("lender_id") REFERENCES "lender"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

