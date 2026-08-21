-- DropForeignKey
ALTER TABLE "sync_change_log" DROP CONSTRAINT "sync_change_log_user_id_fkey";

-- AddForeignKey
ALTER TABLE "sync_change_log" ADD CONSTRAINT "sync_change_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
