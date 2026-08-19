/**
 * Verifies the Phase 1 schema against a real Postgres.
 *
 * Two things are being proven. First, that every CHECK constraint actually
 * rejects the value it names — a constraint nobody has seen fire is a comment.
 * Second, and more important, that the per-user sequence really does serialise:
 * the entire pull cursor depends on sequence order matching commit order, and
 * that is a property of a row lock, not of a column type.
 *
 *   DATABASE_URL=postgres://... node test/verify-schema.mjs
 */
import pg from 'pg';

const URL = process.env.DATABASE_URL;
if (!URL) {
  console.error('DATABASE_URL is required');
  process.exit(1);
}

let pass = 0;
let fail = 0;

const ok = (label, condition, detail = '') => {
  if (condition) {
    pass++;
    console.log(`  PASS  ${label}`);
  } else {
    fail++;
    console.log(`  FAIL  ${label}${detail ? ` — ${detail}` : ''}`);
  }
};

const client = new pg.Client({ connectionString: URL });
await client.connect();

const USER = '018f0000-0000-7000-8000-00000000c001';
const CUST = '018f0000-0000-7000-8000-00000000c002';

await client.query(`DELETE FROM app_user WHERE id = $1`, [USER]);
await client.query(
  `INSERT INTO app_user (id, phone_e164, updated_at) VALUES ($1, $2, now())`,
  [USER, '+919000009001'],
);
await client.query(
  `INSERT INTO customer (id, user_id, name, updated_at) VALUES ($1, $2, 'Ramesh', now())`,
  [CUST, USER],
);

/** Runs SQL that must be rejected. */
const rejects = async (label, sql, params = []) => {
  try {
    await client.query(sql, params);
    ok(label, false, 'was ACCEPTED but should have been rejected');
  } catch (e) {
    ok(label, true);
  }
};

const entry = (over = {}) => {
  const v = {
    id: '018f0000-0000-7000-8000-' + Math.random().toString(16).slice(2, 14).padEnd(12, '0'),
    amount: 500000,
    direction: 'gave',
    rate: 1250,
    itype: 'simple',
    ifreq: 'monthly',
    ...over,
  };
  return [
    `INSERT INTO ledger_entry (id, user_id, customer_id, amount_paise, direction,
       interest_rate_bp, interest_type, interest_frequency, entry_date, updated_at)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,CURRENT_DATE,now())`,
    [v.id, USER, CUST, v.amount, v.direction, v.rate, v.itype, v.ifreq],
  ];
};

console.log('\n1. Money cannot be malformed');
await rejects('negative amount rejected', ...entry({ amount: -500000 }));
await rejects('zero amount rejected', ...entry({ amount: 0 }));
await rejects('absurd amount rejected', ...entry({ amount: 99999999999999 }));

console.log('\n2. Enum-like columns are exact');
await rejects('unknown direction rejected', ...entry({ direction: 'sent' }));
await rejects("direction with trailing space rejected", ...entry({ direction: 'gave ' }));
await rejects('unknown interest type rejected', ...entry({ itype: 'flat' }));
await rejects('unknown frequency rejected', ...entry({ ifreq: 'fortnightly' }));
await rejects('absurd interest rate rejected', ...entry({ rate: 99999999 }));

console.log('\n3. Rows must stay identifiable and explainable');
await rejects(
  'blank customer name rejected',
  `INSERT INTO customer (id, user_id, name, updated_at)
   VALUES ('018f0000-0000-7000-8000-00000000c009', $1, '   ', now())`,
  [USER],
);
{
  const [sql, params] = entry();
  await client.query(sql, params);
  const id = params[0];
  await rejects(
    'voiding without a reason rejected',
    `UPDATE ledger_entry SET voided_at = now() WHERE id = $1`,
    [id],
  );
  await client.query(
    `UPDATE ledger_entry SET voided_at = now(), voided_reason = 'duplicate' WHERE id = $1`,
    [id],
  );
  ok('voiding with a reason accepted', true);
}

console.log('\n4. The audit log is append-only');
await client.query(
  `INSERT INTO sync_change_log (user_id, seq, entity, entity_id, op_type, snapshot)
   VALUES ($1, 1, 'customer', $2, 'create', '{"name":"Ramesh"}'::jsonb)`,
  [USER, CUST],
);
await rejects(
  'UPDATE on the change log rejected',
  `UPDATE sync_change_log SET snapshot = '{"name":"tampered"}'::jsonb WHERE user_id = $1`,
  [USER],
);
await rejects(
  'DELETE of a recent change-log row rejected',
  `DELETE FROM sync_change_log WHERE user_id = $1`,
  [USER],
);
await rejects(
  'non-create without `previous` rejected',
  `INSERT INTO sync_change_log (user_id, seq, entity, entity_id, op_type, snapshot)
   VALUES ($1, 2, 'customer', $2, 'update', '{}'::jsonb)`,
  [USER, CUST],
);
{
  // Backdate past the retention horizon: the retention job must still work.
  await client.query(
    `UPDATE app_user SET id = id WHERE id = $1`, [USER],
  );
  await client.query(
    `ALTER TABLE sync_change_log DISABLE TRIGGER sync_change_log_append_only_trigger`,
  );
  await client.query(
    `UPDATE sync_change_log SET created_at = now() - interval '200 days' WHERE user_id = $1`,
    [USER],
  );
  await client.query(
    `ALTER TABLE sync_change_log ENABLE TRIGGER sync_change_log_append_only_trigger`,
  );
  const r = await client.query(`DELETE FROM sync_change_log WHERE user_id = $1`, [USER]);
  ok('DELETE beyond the retention horizon allowed', r.rowCount === 1,
     `deleted ${r.rowCount} rows`);
}

console.log('\n5. The per-user sequence serialises (the cursor depends on this)');
{
  const a = new pg.Client({ connectionString: URL });
  const b = new pg.Client({ connectionString: URL });
  await a.connect();
  await b.connect();

  await a.query('BEGIN');
  const first = await a.query(
    `UPDATE app_user SET change_seq = change_seq + 1 WHERE id = $1 RETURNING change_seq`,
    [USER],
  );

  let bResolved = false;
  const bPromise = (async () => {
    await b.query('BEGIN');
    const r = await b.query(
      `UPDATE app_user SET change_seq = change_seq + 1 WHERE id = $1 RETURNING change_seq`,
      [USER],
    );
    bResolved = true;
    await b.query('COMMIT');
    return r.rows[0].change_seq;
  })();

  await new Promise((r) => setTimeout(r, 400));
  ok('second writer BLOCKS while the first holds the lock', bResolved === false);

  await a.query('COMMIT');
  const second = await bPromise;

  ok('sequence strictly increases', Number(second) > Number(first.rows[0].change_seq),
     `first=${first.rows[0].change_seq} second=${second}`);
  ok('no gap between them', Number(second) === Number(first.rows[0].change_seq) + 1);

  await a.end();
  await b.end();
}

await client.query(`DELETE FROM app_user WHERE id = $1`, [USER]);
await client.end();

console.log('\n' + '='.repeat(46));
console.log(`  ${pass} passed, ${fail} failed`);
console.log('='.repeat(46));
process.exit(fail === 0 ? 0 : 1);
