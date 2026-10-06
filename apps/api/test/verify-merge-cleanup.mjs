/**
 * Rehearses the duplicate cleanup on a copy of real data and checks nothing
 * was lost. Point it at a COPY — a local restore of a dump, or a Neon branch —
 * never at the main database.
 *
 *   DATABASE_URL=<copy> node test/verify-merge-cleanup.mjs snapshot   # before
 *   DATABASE_URL=<copy> node scripts/merge-duplicate-parties.mjs --apply
 *   DATABASE_URL=<copy> node test/verify-merge-cleanup.mjs check      # after
 *
 * `snapshot` records every entry and party before the cleanup; `check`
 * compares against it. The invariants:
 *
 * - no rows created or removed: the cleanup only voids and soft-deletes;
 * - no entry changed except by being voided as `merged_duplicate`;
 * - every voided entry belonged to a retired copy, never to a survivor;
 * - every survivor had the most live entries in its group (oldest on a tie);
 * - no live duplicates remain, and the unique indexes exist;
 * - every retired copy has a party_merge row pointing at its survivor;
 * - each user's change log is still gap-free and ends at change_seq.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import pg from 'pg';

const mode = process.argv[2];
const url = process.env.DATABASE_URL;
const file = process.env.SNAPSHOT_FILE ?? 'merge-cleanup-snapshot.json';

if (!url || !['snapshot', 'check'].includes(mode)) {
  console.error('DATABASE_URL=<copy> node test/verify-merge-cleanup.mjs snapshot|check');
  process.exit(1);
}

const client = new pg.Client({ connectionString: url });
await client.connect();
const q = async (sql, params) => (await client.query(sql, params)).rows;

const nameKey = (s) => s.trim().replace(/\s+/g, ' ').toLowerCase();
const phoneKey = (s) => (s ?? '').replace(/[^0-9]/g, '').slice(-10);

if (mode === 'snapshot') {
  const parties = await q(`
    SELECT 'customer' AS entity, id, user_id, chopdi_id, name, phone_e164, created_at, deleted_at FROM customer
    UNION ALL
    SELECT 'lender', id, user_id, chopdi_id, name, phone_e164, created_at, deleted_at FROM lender`);
  const entries = await q(`
    SELECT id, user_id, customer_id, lender_id, amount_paise::text, direction, ledger_side,
           entry_date::text, voided_at, voided_reason
      FROM ledger_entry`);

  // Expected outcome, computed independently of the script: group live
  // parties, pick the one with most live entries, oldest on a tie.
  const liveCount = new Map();
  for (const e of entries) {
    if (e.voided_at) continue;
    const parent = e.customer_id ?? e.lender_id;
    liveCount.set(parent, (liveCount.get(parent) ?? 0) + 1);
  }
  const groups = new Map();
  for (const p of parties) {
    if (p.deleted_at) continue;
    const key = [p.entity, p.user_id, p.chopdi_id ?? '', nameKey(p.name), phoneKey(p.phone_e164)].join('|');
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push({ ...p, live: liveCount.get(p.id) ?? 0 });
  }
  const expected = [...groups.values()]
    .filter((g) => g.length > 1)
    .map((g) => {
      g.sort((a, b) => b.live - a.live || new Date(a.created_at) - new Date(b.created_at));
      return { survivor: g[0].id, losers: g.slice(1).map((p) => p.id) };
    });

  writeFileSync(file, JSON.stringify({ parties, entries, expected }, null, 1));
  const losers = expected.reduce((n, g) => n + g.losers.length, 0);
  const voids = expected
    .flatMap((g) => g.losers)
    .reduce((n, id) => n + (liveCount.get(id) ?? 0), 0);
  console.log(
    `Snapshot: ${parties.length} parties, ${entries.length} entries. ` +
      `Expect ${expected.length} groups, ${losers} copies retired, ${voids} entries voided.`,
  );
  await client.end();
  process.exit(0);
}

// ---------------------------------------------------------------------- check

let pass = 0;
let fail = 0;
const ok = (label, cond, detail = '') => {
  if (cond) {
    pass++;
    console.log(`  PASS  ${label}`);
  } else {
    fail++;
    console.log(`  FAIL  ${label}${detail ? ` — ${detail}` : ''}`);
  }
};

const before = JSON.parse(readFileSync(file, 'utf8'));
const losers = new Set(before.expected.flatMap((g) => g.losers));
const survivorOf = new Map(before.expected.flatMap((g) => g.losers.map((l) => [l, g.survivor])));

const partiesNow = await q(`
  SELECT 'customer' AS entity, id, deleted_at FROM customer
  UNION ALL SELECT 'lender', id, deleted_at FROM lender`);
const entriesNow = await q(`
  SELECT id, customer_id, lender_id, amount_paise::text, direction, ledger_side,
         entry_date::text, voided_at, voided_reason
    FROM ledger_entry`);

ok('no party rows added or removed', partiesNow.length === before.parties.length,
  `${before.parties.length} → ${partiesNow.length}`);
ok('no entry rows added or removed', entriesNow.length === before.entries.length,
  `${before.entries.length} → ${entriesNow.length}`);

const partyNow = new Map(partiesNow.map((p) => [p.id, p]));
const retiredOk = [...losers].every((id) => partyNow.get(id)?.deleted_at);
ok('every expected copy retired', retiredOk);
const survivorsLive = before.expected.every((g) => !partyNow.get(g.survivor)?.deleted_at);
ok('every survivor still live (the one with most entries)', survivorsLive);

const otherDeleted = before.parties.filter(
  (p) => !p.deleted_at && !losers.has(p.id) && partyNow.get(p.id)?.deleted_at,
);
ok('no other party was deleted', otherDeleted.length === 0, otherDeleted.map((p) => p.id).join(','));

const beforeEntry = new Map(before.entries.map((e) => [e.id, e]));
let changedFields = 0;
let wrongVoids = 0;
let expectedVoids = 0;
let actualVoids = 0;
for (const e of entriesNow) {
  const b = beforeEntry.get(e.id);
  if (!b) continue;
  for (const f of ['customer_id', 'lender_id', 'amount_paise', 'direction', 'ledger_side', 'entry_date']) {
    if (String(b[f]) !== String(e[f])) changedFields++;
  }
  const parent = e.customer_id ?? e.lender_id;
  if (!b.voided_at && losers.has(parent)) expectedVoids++;
  if (!b.voided_at && e.voided_at) {
    actualVoids++;
    if (e.voided_reason !== 'merged_duplicate' || !losers.has(parent)) wrongVoids++;
  }
  if (b.voided_at && !e.voided_at) wrongVoids++;
}
ok('no amount, type, date or parent changed on any entry', changedFields === 0, `${changedFields} changes`);
ok(`exactly the retired copies' entries were voided (${expectedVoids})`,
  actualVoids === expectedVoids && wrongVoids === 0,
  `voided ${actualVoids}, expected ${expectedVoids}, wrong ${wrongVoids}`);

const dupes = await q(`
  SELECT 1 FROM (
    SELECT user_id FROM customer WHERE deleted_at IS NULL
     GROUP BY user_id, coalesce(chopdi_id::text, ''), name_key, phone_key HAVING count(*) > 1
    UNION ALL
    SELECT user_id FROM lender WHERE deleted_at IS NULL
     GROUP BY user_id, coalesce(chopdi_id::text, ''), name_key, phone_key HAVING count(*) > 1) d`);
ok('no live duplicates remain', dupes.length === 0, `${dupes.length} groups`);

const idx = await q(`SELECT indexname FROM pg_indexes WHERE indexname LIKE '%match_key_unique'`);
ok('unique indexes in place', idx.length === 2, idx.map((i) => i.indexname).join(','));

const merges = await q(`SELECT alias_id, main_id FROM party_merge WHERE source = 'cleanup'`);
const mergeOf = new Map(merges.map((m) => [m.alias_id, m.main_id]));
const badMerge = [...losers].filter((id) => mergeOf.get(id) !== survivorOf.get(id));
ok('every retired copy redirects to its survivor', badMerge.length === 0, badMerge.join(','));

const gaps = await q(`
  SELECT u.id FROM app_user u
   WHERE u.change_seq <> coalesce((SELECT max(seq) FROM sync_change_log l WHERE l.user_id = u.id), 0)
      OR (SELECT count(*) FROM sync_change_log l WHERE l.user_id = u.id)
         <> coalesce((SELECT max(seq) FROM sync_change_log l WHERE l.user_id = u.id), 0)`);
ok('change log gap-free and matches change_seq for every user', gaps.length === 0,
  gaps.map((g) => g.id).join(','));

console.log(`\n${pass} passed, ${fail} failed`);
await client.end();
process.exit(fail === 0 ? 0 : 1);
