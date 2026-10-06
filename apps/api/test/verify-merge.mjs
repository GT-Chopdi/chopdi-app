/**
 * Verifies duplicate customers/lenders created on two offline devices are
 * merged on sync (MergeService), against a running server and real Postgres.
 *
 * The case: Device 1 adds Ravi offline, the user signs in on Device 2 — which
 * cannot see that Ravi — and adds him again. On sync the server must keep one
 * Ravi, and keep the entries of whichever copy has more of them.
 *
 *   API_BASE=http://localhost:3111/api DEV_KEY=... node test/verify-merge.mjs
 *
 * Run the server with OTP_RESEND_COOLDOWN_SECONDS=0: the same account signs in
 * twice to get two devices.
 *
 * PHONE=+91... runs it inside an existing account (e.g. against a copy of real
 * data). Every name carries a unique tag, so it never collides with — or
 * merges into — anyone already there.
 */
const API = process.env.API_BASE ?? 'http://localhost:3111/api';
const DEV_KEY = process.env.DEV_KEY ?? '';

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

const uuid = () => crypto.randomUUID();

let counter = 0;
const uuid7 = () => {
  const ms = Date.now().toString(16).padStart(12, '0');
  const seq = (counter++).toString(16).padStart(3, '0');
  const rand = crypto.randomUUID().replace(/-/g, '').slice(0, 16);
  return `${ms.slice(0, 8)}-${ms.slice(8, 12)}-7${seq}-8${rand.slice(0, 3)}-${rand.slice(3, 15)}`;
};

const call = async (path, { method = 'POST', body, token, deviceId } = {}) => {
  const res = await fetch(`${API}${path}`, {
    method,
    headers: {
      'content-type': 'application/json',
      ...(DEV_KEY ? { 'X-Dev-Key': DEV_KEY } : {}),
      ...(token ? { authorization: `Bearer ${token}` } : {}),
      ...(deviceId ? { 'X-Device-Id': deviceId } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }
  return { status: res.status, json };
};

const signIn = async (phone) => {
  const installId = uuid();
  const req = await call('/v1/auth/otp/request', {
    body: { phone, installId, platform: 'android' },
  });
  if (!req.json.challengeId) throw new Error(`otp/request failed: ${JSON.stringify(req.json)}`);

  const verify = await call('/v1/auth/otp/verify', {
    body: {
      challengeId: req.json.challengeId,
      code: '123456',
      installId,
      platform: 'android',
      appVersion: '0.1.0',
    },
  });
  if (!verify.json.accessToken) throw new Error(`otp/verify failed: ${JSON.stringify(verify.json)}`);

  return { token: verify.json.accessToken, deviceId: verify.json.deviceId };
};

const push = (s, operations) =>
  call('/v1/sync/push', { body: { operations }, token: s.token, deviceId: s.deviceId });

const pullAll = async (s) => {
  const changes = [];
  let cursor = '0';
  for (let pages = 0; pages < 100; pages++) {
    const res = await call(`/v1/sync/pull?cursor=${cursor}`, {
      method: 'GET',
      token: s.token,
      deviceId: s.deviceId,
    });
    if (res.status !== 200) throw new Error(`pull failed: ${res.status} ${JSON.stringify(res.json)}`);
    changes.push(...res.json.changes);
    cursor = res.json.nextCursor;
    if (!res.json.hasMore) return changes;
  }
  throw new Error('pull did not terminate');
};

/** Latest state of every row, folded from a full pull the way a device would. */
const state = async (s) => {
  const rows = new Map();
  const merges = [];
  for (const c of await pullAll(s)) {
    if (c.opType === 'merge') merges.push(c);
    else rows.set(c.entityId, { entity: c.entity, ...c.data });
  }
  return { rows, merges };
};

const create = (entity, entityId, payload) => ({
  opId: uuid(),
  entity,
  entityId,
  opType: 'create',
  payload,
});

const today = new Date().toISOString().slice(0, 10);

const entry = (parent, amountPaise, direction = 'gave', ledgerSide = 'lent') => ({
  ...parent,
  amountPaise,
  direction,
  ledgerSide,
  interestRateBp: 0,
  interestType: 'none',
  interestFrequency: 'monthly',
  entryDate: today,
  description: '',
  paymentMode: 'cash',
});

const result = (res, i = 0) => res.json.results?.[i] ?? {};
const live = (row) => row && row.voidedAt === null;

const stamp = Date.now().toString().slice(-7);
const phone = process.env.PHONE ?? `+9193000${stamp}`;
const t = (name) => `${name} T${stamp}`;
const tp = (n) => `9${stamp}${n}`.padEnd(10, '0').slice(0, 10);
const device1 = await signIn(phone);
const device2 = await signIn(phone);

// ---------------------------------------------------------------------------
console.log('\n1. Same Ravi from two offline devices becomes one customer');
const ravi1 = uuid7();
const ravi2 = uuid7();
const d1Gave = uuid7();
const d2Gave = uuid7();
const d2Small = uuid7();
{
  const r1 = await push(device1, [
    create('customer', ravi1, { name: t('Ravi'), phone: tp(1) }),
    create('ledger_entry', d1Gave, entry({ customerId: ravi1 }, 500000)),
  ]);
  ok('device 1 Ravi applied', result(r1).status === 'applied', JSON.stringify(r1.json));

  // Different spacing, case and phone formatting — still the same person.
  const r2 = await push(device2, [
    create('customer', ravi2, { name: `  ${t('ravi').toLowerCase()} `, phone: `+91 ${tp(1).slice(0, 5)} ${tp(1).slice(5)}`, notes: 'from phone 2' }),
  ]);
  const res = result(r2);
  ok('device 2 Ravi reported as applied', res.status === 'applied', JSON.stringify(r2.json));
  ok('… with mergedInto = device 1 Ravi', res.mergedInto === ravi1, JSON.stringify(res));
  ok('… and entityId = device 1 Ravi', res.entityId === ravi1);

  const { rows, merges } = await state(device1);
  ok(
    'only one Ravi row exists',
    [...rows.values()].filter((r) => r.entity === 'customer' && r.name.toLowerCase().trim() === t('ravi').toLowerCase()).length === 1,
  );
  ok(
    'pull carries a merge op for the alias',
    merges.some((m) => m.entityId === ravi2 && m.data.mergedInto === ravi1),
    JSON.stringify(merges),
  );
}

// ---------------------------------------------------------------------------
console.log('\n2. Copy with more entries wins; a tie keeps the first');
{
  // 1 vs 1: tie, device 1 (first) keeps its entry; device 2's is voided.
  const a = await push(device2, [create('ledger_entry', d2Gave, entry({ customerId: ravi2 }, 500000))]);
  ok('entry sent to alias id applied', result(a).status === 'applied', JSON.stringify(a.json));

  let { rows } = await state(device1);
  ok('entry stored against the surviving Ravi', rows.get(d2Gave)?.customerId === ravi1);
  ok('tie: device 1 entry live', live(rows.get(d1Gave)));
  ok('tie: device 2 entry voided as merged_duplicate', rows.get(d2Gave)?.voidedReason === 'merged_duplicate');

  // 1 vs 2: device 2 pulls ahead — the outcome flips.
  await push(device2, [create('ledger_entry', d2Small, entry({ customerId: ravi2 }, 50000, 'received'))]);
  ({ rows } = await state(device1));
  ok('flip: device 1 entry voided', rows.get(d1Gave)?.voidedReason === 'merged_duplicate', JSON.stringify(rows.get(d1Gave)));
  ok('flip: device 2 ₹5,000 reinstated', live(rows.get(d2Gave)), JSON.stringify(rows.get(d2Gave)));
  ok('flip: device 2 ₹500 (I took back) live', live(rows.get(d2Small)));
  ok('winner notes adopted', rows.get(ravi1)?.notes === 'from phone 2', JSON.stringify(rows.get(ravi1)));

  // An entry added after the merge through the surviving id is new business.
  const later = uuid7();
  await push(device2, [create('ledger_entry', later, entry({ customerId: ravi1 }, 100000))]);
  ({ rows } = await state(device1));
  ok('post-merge entry live', live(rows.get(later)));
  ok('post-merge entry did not change the outcome', live(rows.get(d2Gave)) && !live(rows.get(d1Gave)));
}

// ---------------------------------------------------------------------------
console.log('\n3. Retries and later operations on the alias id');
{
  const again = await push(device2, [create('customer', ravi2, { name: t('Ravi'), phone: tp(1) })]);
  ok('re-create of alias under a new opId → mergedInto', result(again).mergedInto === ravi1, JSON.stringify(again.json));

  const op = create('customer', uuid7(), { name: t('Ravi'), phone: tp(1) });
  const first = await push(device2, [op]);
  const retry = await push(device2, [op]);
  ok('same op retried → duplicate', result(retry).status === 'duplicate', JSON.stringify(retry.json));
  ok('… with the same mergedInto', result(retry).mergedInto === result(first).mergedInto);

  const { rows } = await state(device1);
  const edit = await push(device2, [
    {
      opId: uuid(),
      entity: 'customer',
      entityId: ravi2,
      opType: 'update',
      expectedVersion: rows.get(ravi1).version,
      payload: { notes: 'edited via alias' },
    },
  ]);
  ok('update sent to alias applied', result(edit).status === 'applied', JSON.stringify(edit.json));
  ok('… reported as landing on device 1 Ravi', result(edit).mergedInto === ravi1);
}

// ---------------------------------------------------------------------------
console.log('\n4. Matching follows the app rules');
{
  const other = uuid7();
  const r = await push(device2, [create('customer', other, { name: t('Ravi'), phone: tp(9) })]);
  ok('same name, different phone → new customer', result(r).status === 'applied' && !result(r).mergedInto);

  const n1 = uuid7();
  const n2 = uuid7();
  await push(device1, [create('customer', n1, { name: t('Mohan') })]);
  const m = await push(device2, [create('customer', n2, { name: t('mohan'), phone: '' })]);
  ok('same name, both phones empty → merged', result(m).mergedInto === n1, JSON.stringify(m.json));

  const p1 = uuid7();
  await push(device1, [create('customer', p1, { name: t('Gita'), phone: tp(2) })]);
  const p2 = await push(device2, [create('customer', uuid7(), { name: t('Gita') })]);
  ok('same name, one phone empty → new customer', !result(p2).mergedInto, JSON.stringify(p2.json));

  const l1 = uuid7();
  await push(device1, [create('lender', l1, { name: t('Bank Wala'), phone: tp(3) })]);
  const l2 = await push(device2, [create('lender', uuid7(), { name: t('bank wala'), phone: tp(3) })]);
  ok('lenders merge the same way', result(l2).mergedInto === l1, JSON.stringify(l2.json));

  const c = await push(device2, [create('customer', uuid7(), { name: t('Bank Wala'), phone: tp(3) })]);
  ok('a customer never merges into a lender', !result(c).mergedInto);
}

// ---------------------------------------------------------------------------
console.log('\n5. Deleted customers are not matched; renames cannot collide');
{
  const s1 = uuid7();
  await push(device1, [create('customer', s1, { name: t('Suresh'), phone: tp(4) })]);
  await push(device1, [
    { opId: uuid(), entity: 'customer', entityId: s1, opType: 'void', expectedVersion: 1, payload: {} },
  ]);
  const s2 = await push(device2, [create('customer', uuid7(), { name: t('Suresh'), phone: tp(4) })]);
  ok('re-adding a deleted person creates a new customer', result(s2).status === 'applied' && !result(s2).mergedInto);

  const x = uuid7();
  await push(device1, [create('customer', x, { name: t('Xavier'), phone: tp(5) })]);
  const rename = await push(device1, [
    {
      opId: uuid(),
      entity: 'customer',
      entityId: x,
      opType: 'update',
      expectedVersion: 1,
      payload: { name: t('Ravi'), phone: tp(1) },
    },
  ]);
  ok(
    'rename onto an existing person → PARTY_EXISTS',
    result(rename).error?.code === 'PARTY_EXISTS' && result(rename).error?.permanent === true,
    JSON.stringify(rename.json),
  );
}

// ---------------------------------------------------------------------------
console.log('\n6. Both devices push the same new person at the same moment');
{
  const a = uuid7();
  const b = uuid7();
  const [ra, rb] = await Promise.all([
    push(device1, [create('customer', a, { name: t('Sita'), phone: tp(6) })]),
    push(device2, [create('customer', b, { name: t('Sita'), phone: tp(6) })]),
  ]);
  const merged = [result(ra), result(rb)].filter((r) => r.mergedInto);
  ok('both applied', result(ra).status === 'applied' && result(rb).status === 'applied', JSON.stringify([ra.json, rb.json]));
  ok('exactly one was merged into the other', merged.length === 1, JSON.stringify([result(ra), result(rb)]));

  const { rows } = await state(device1);
  const sitas = [...rows.values()].filter((r) => r.entity === 'customer' && r.name === t('Sita'));
  ok('one Sita row', sitas.length === 1, String(sitas.length));
}

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
