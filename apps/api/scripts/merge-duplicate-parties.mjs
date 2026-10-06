/**
 * One-time cleanup: folds the duplicate customers and lenders that existed
 * before the server merged them on sync (see MergeService).
 *
 *   node scripts/merge-duplicate-parties.mjs              # dry run: report only
 *   node scripts/merge-duplicate-parties.mjs --apply      # write
 *   node scripts/merge-duplicate-parties.mjs --user <id>  # one account only
 *
 * Connects with DIRECT_URL, falling back to DATABASE_URL, from the environment
 * or apps/api/.env.
 *
 * ## Rules (the same ones live sync uses)
 *
 * - Same person: same user, same book, same name key and phone key, both live.
 * - Survivor: the copy with the most live entries; a tie keeps the oldest.
 * - Every other copy: its live entries are voided with reason
 *   `merged_duplicate` (voided, not deleted — restorable), the copy itself is
 *   soft-deleted, and its id is recorded in `party_merge` so a phone still
 *   holding it sends future operations to the survivor.
 *
 * Every write goes to the change log, so devices see it on their next pull.
 * One transaction per user, holding that user's row lock — the same lock the
 * API takes — so the script can run while the API is serving.
 *
 * When it finishes with no duplicates left, it creates the unique indexes the
 * party_match_unique migration skips on a database that still had them.
 */
import 'dotenv/config';
import pg from 'pg';

const MERGED_DUPLICATE = 'merged_duplicate';

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const onlyUser = args.includes('--user') ? args[args.indexOf('--user') + 1] : null;

const url = process.env.DIRECT_URL || process.env.DATABASE_URL;
if (!url) {
  console.error('Set DIRECT_URL or DATABASE_URL.');
  process.exit(1);
}

const client = new pg.Client({ connectionString: url });
await client.connect();

// --------------------------------------------------------------- snapshots
// Must match partySnapshot and ledgerEntrySnapshot in src/modules/sync: a
// device applies these exactly as it applies the API's own.

const iso = (d) => (d ? new Date(d).toISOString() : null);

const partySnapshot = (r) => ({
  id: r.id,
  chopdiId: r.chopdi_id,
  name: r.name,
  phone: r.phone_e164,
  notes: r.notes,
  version: r.version,
  createdAt: iso(r.created_at),
  updatedAt: iso(r.updated_at),
  deletedAt: iso(r.deleted_at),
});

const entrySnapshot = (r) => ({
  id: r.id,
  customerId: r.customer_id,
  lenderId: r.lender_id,
  amountPaise: String(r.amount_paise),
  direction: r.direction,
  ledgerSide: r.ledger_side,
  interestRateBp: r.interest_rate_bp,
  interestType: r.interest_type,
  interestFrequency: r.interest_frequency,
  entryDate: new Date(r.entry_date).toISOString().slice(0, 10),
  description: r.description,
  paymentMode: r.payment_mode,
  version: r.version,
  createdAt: iso(r.created_at),
  updatedAt: iso(r.updated_at),
  voidedAt: iso(r.voided_at),
  voidedReason: r.voided_reason,
});

// ------------------------------------------------------------------- writes

const append = async (userId, entity, entityId, opType, snapshot, previous) => {
  const { rows } = await client.query(
    'UPDATE app_user SET change_seq = change_seq + 1 WHERE id = $1 RETURNING change_seq',
    [userId],
  );
  await client.query(
    `INSERT INTO sync_change_log (user_id, seq, entity, entity_id, op_type, snapshot, previous)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [userId, rows[0].change_seq, entity, entityId, opType, snapshot, previous],
  );
};

/** Duplicate groups for one user and table, survivor first in each. */
const groupsFor = async (table, userId) => {
  const parentCol = table === 'customer' ? 'customer_id' : 'lender_id';
  const { rows } = await client.query(
    `SELECT p.*,
            (SELECT count(*)::int FROM ledger_entry e
              WHERE e.${parentCol} = p.id AND e.voided_at IS NULL) AS live_entries
       FROM ${table} p
      WHERE p.user_id = $1 AND p.deleted_at IS NULL`,
    [userId],
  );

  const byKey = new Map();
  for (const r of rows) {
    const key = `${r.chopdi_id ?? ''}|${r.name_key}|${r.phone_key}`;
    if (!byKey.has(key)) byKey.set(key, []);
    byKey.get(key).push(r);
  }

  return [...byKey.values()]
    .filter((g) => g.length > 1)
    .map((g) =>
      g.sort(
        (a, b) =>
          b.live_entries - a.live_entries || new Date(a.created_at) - new Date(b.created_at),
      ),
    );
};

const fold = async (table, userId, survivor, loser) => {
  const parentCol = table === 'customer' ? 'customer_id' : 'lender_id';

  const { rows: entries } = await client.query(
    `SELECT * FROM ledger_entry WHERE ${parentCol} = $1 AND voided_at IS NULL ORDER BY created_at`,
    [loser.id],
  );
  for (const before of entries) {
    const { rows } = await client.query(
      `UPDATE ledger_entry
          SET voided_at = now(), voided_reason = $2, version = version + 1, updated_at = now()
        WHERE id = $1 RETURNING *`,
      [before.id, MERGED_DUPLICATE],
    );
    await append(userId, 'ledger_entry', before.id, 'void', entrySnapshot(rows[0]), entrySnapshot(before));
  }

  const { rows: retired } = await client.query(
    `UPDATE ${table} SET deleted_at = now(), version = version + 1, updated_at = now()
      WHERE id = $1 RETURNING *`,
    [loser.id],
  );
  await append(userId, table, loser.id, 'void', partySnapshot(retired[0]), partySnapshot(loser));

  const alias = {
    chopdiId: loser.chopdi_id,
    name: loser.name,
    phone: loser.phone_e164,
    notes: loser.notes,
  };
  await client.query(
    `INSERT INTO party_merge (alias_id, user_id, entity, main_id, alias_snapshot, source, winner)
     VALUES ($1, $2, $3, $4, $5, 'cleanup', 'main')`,
    [loser.id, userId, table, survivor.id, alias],
  );
  await append(
    userId,
    table,
    loser.id,
    'merge',
    { id: loser.id, version: survivor.version, mergedInto: survivor.id },
    { id: loser.id, ...alias },
  );

  return entries.length;
};

// --------------------------------------------------------------------- main

const { rows: users } = await client.query(
  `SELECT id, phone_e164 FROM app_user ${onlyUser ? 'WHERE id = $1' : ''} ORDER BY created_at`,
  onlyUser ? [onlyUser] : [],
);

console.log(apply ? 'APPLYING\n' : 'DRY RUN — nothing is written. Re-run with --apply.\n');

const totals = { groups: 0, losers: 0, entries: 0 };

for (const user of users) {
  await client.query('BEGIN');
  try {
    await client.query('SELECT 1 FROM app_user WHERE id = $1 FOR UPDATE', [user.id]);

    const lines = [];
    for (const table of ['customer', 'lender']) {
      for (const group of await groupsFor(table, user.id)) {
        const [survivor, ...losers] = group;
        totals.groups++;
        totals.losers += losers.length;

        const voided = losers.reduce((n, l) => n + l.live_entries, 0);
        totals.entries += voided;
        lines.push(
          `  ${table} "${survivor.name}" ${survivor.phone_e164 ?? '(no phone)'}: ` +
            `keep ${survivor.id} (${survivor.live_entries} entries), ` +
            `fold ${losers.length} cop${losers.length === 1 ? 'y' : 'ies'}, void ${voided} entries`,
        );

        if (apply) {
          for (const loser of losers) await fold(table, user.id, survivor, loser);
        }
      }
    }

    if (lines.length) console.log(`${user.phone_e164} (${user.id})\n${lines.join('\n')}`);
    await client.query(apply ? 'COMMIT' : 'ROLLBACK');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error(`\nFailed for ${user.id}; that account was left untouched.`);
    throw error;
  }
}

console.log(
  `\n${totals.groups} duplicate groups, ${totals.losers} copies folded, ` +
    `${totals.entries} entries voided${apply ? '' : ' (would be)'}.`,
);

if (apply && !onlyUser) {
  for (const table of ['customer', 'lender']) {
    await client.query(
      `CREATE UNIQUE INDEX IF NOT EXISTS "${table}_match_key_unique"
         ON "${table}" ("user_id", coalesce("chopdi_id"::text, ''), "name_key", "phone_key")
         WHERE "deleted_at" IS NULL`,
    );
  }
  console.log('Unique indexes customer_match_key_unique / lender_match_key_unique in place.');
}

await client.end();
