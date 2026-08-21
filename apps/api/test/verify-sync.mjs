/**
 * Verifies POST /v1/sync/push against a running server and real Postgres.
 *
 * The push endpoint is where a user's offline ledger becomes durable, so the
 * cases that matter are the ugly ones: a retry after a lost response, an entry
 * that arrives before its customer, two devices editing the same row, a batch
 * where one operation is poison.
 *
 *   API_BASE=http://localhost:3111/api DEV_KEY=... node test/verify-sync.mjs
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

/** UUIDv7-shaped ids, so they sort the way the client's would. */
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
      // Must match the `did` claim in the token: a token lifted onto another
      // handset is refused. The Flutter client sends this on every request.
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

/** Signs in a fresh user and returns its credentials. */
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

  return {
    token: verify.json.accessToken,
    userId: verify.json.user.id,
    deviceId: verify.json.deviceId,
  };
};

const push = (session, operations) =>
  call('/v1/sync/push', {
    body: { operations },
    token: session.token,
    deviceId: session.deviceId,
  });

const customerOp = (entityId, name = 'Ramesh', overrides = {}) => ({
  opId: uuid(),
  entity: 'customer',
  entityId,
  opType: 'create',
  payload: { name, phone: '+919876500001', notes: '' },
  ...overrides,
});

const entryOp = (entityId, customerId, overrides = {}) => ({
  opId: uuid(),
  entity: 'ledger_entry',
  entityId,
  opType: 'create',
  payload: {
    customerId,
    amountPaise: 500000,
    direction: 'gave',
    ledgerSide: 'lent',
    interestRateBp: 200,
    interestType: 'simple',
    interestFrequency: 'monthly',
    entryDate: '2026-03-03',
    description: '',
    paymentMode: 'cash',
  },
  ...overrides,
});

const stamp = Date.now().toString().slice(-7);
const user = await signIn(`+9190000${stamp}`);

console.log('\n1. A batch applies and reports each operation');
{
  const cid = uuid7();
  const eid = uuid7();
  const res = await push(user, [customerOp(cid), entryOp(eid, cid)]);

  ok('responds 200', res.status === 200, `got ${res.status}`);
  ok('two results', res.json.results?.length === 2);
  ok('both applied', res.json.results?.every((r) => r.status === 'applied'),
     JSON.stringify(res.json.results?.map((r) => [r.status, r.error?.code])));
  ok('versions returned', res.json.results?.every((r) => r.version === 1));
  ok('serverCursor advanced', BigInt(res.json.serverCursor ?? '0') >= 2n,
     res.json.serverCursor);
}

console.log('\n2. A retry after a lost response applies nothing twice');
{
  const cid = uuid7();
  const ops = [customerOp(cid, 'Retry Test')];

  const first = await push(user, ops);
  const second = await push(user, ops);
  const third = await push(user, ops);

  ok('first applies', first.json.results[0].status === 'applied');
  ok('second is duplicate', second.json.results[0].status === 'duplicate',
     second.json.results[0].status);
  ok('third is duplicate', third.json.results[0].status === 'duplicate');
  ok('replays the original version', second.json.results[0].version === 1);
}

console.log('\n3. The same key with different content is refused');
{
  const cid = uuid7();
  const op = customerOp(cid, 'Original');
  await push(user, [op]);

  const spliced = { ...op, payload: { ...op.payload, name: 'Tampered' } };
  const res = await push(user, [spliced]);

  ok('rejected', res.json.results[0].status === 'rejected');
  ok('code is IDEMPOTENCY_KEY_REUSE',
     res.json.results[0].error?.code === 'IDEMPOTENCY_KEY_REUSE',
     res.json.results[0].error?.code);
  ok('marked permanent', res.json.results[0].error?.permanent === true);
}

console.log('\n4. An entry sent before its customer still applies');
{
  const cid = uuid7();
  const eid = uuid7();
  // Deliberately reversed: the server must not trust client ordering.
  const res = await push(user, [entryOp(eid, cid), customerOp(cid, 'Out Of Order')]);

  ok('both applied', res.json.results.every((r) => r.status === 'applied'),
     JSON.stringify(res.json.results.map((r) => [r.entityId?.slice(0, 8), r.status, r.error?.code])));
  ok('results keep the client\'s order', res.json.results[0].entityId === eid,
     'the client matches results to its outbox by position');
}

console.log('\n5. Concurrent edits are reported, not silently merged');
{
  const cid = uuid7();
  await push(user, [customerOp(cid, 'Conflict Base')]);

  const update = {
    opId: uuid(), entity: 'customer', entityId: cid, opType: 'update',
    expectedVersion: 1, payload: { name: 'First Edit', phone: null, notes: '' },
  };
  const applied = await push(user, [update]);
  ok('the first edit applies', applied.json.results[0].status === 'applied');

  const stale = {
    opId: uuid(), entity: 'customer', entityId: cid, opType: 'update',
    expectedVersion: 1, payload: { name: 'Second Edit', phone: null, notes: '' },
  };
  const res = await push(user, [stale]);

  ok('a stale edit is a conflict, not a rejection',
     res.json.results[0].status === 'conflict', res.json.results[0].status);
  ok('code is STALE_VERSION', res.json.results[0].error?.code === 'STALE_VERSION');
  ok('not permanent — resolvable', res.json.results[0].error?.permanent === false);
  ok('reports both versions',
     res.json.results[0].error?.details?.actualVersion === 2,
     JSON.stringify(res.json.results[0].error?.details));
}

console.log('\n6. One bad operation does not block the rest');
{
  const good1 = uuid7(), good2 = uuid7(), bad = uuid7();
  const res = await push(user, [
    customerOp(good1, 'Good One'),
    customerOp(bad, ''),                    // blank name — permanently invalid
    customerOp(good2, 'Good Two'),
  ]);

  const byId = Object.fromEntries(res.json.results.map((r) => [r.entityId, r]));
  ok('the valid ones apply', byId[good1].status === 'applied' && byId[good2].status === 'applied');
  ok('the invalid one is rejected', byId[bad].status === 'rejected');
  ok('and is permanent, so the client dead-letters it',
     byId[bad].error?.permanent === true);
}

console.log('\n7. Deletes behave idempotently');
{
  const cid = uuid7();
  const eid = uuid7();
  await push(user, [customerOp(cid), entryOp(eid, cid)]);

  const v = { opId: uuid(), entity: 'ledger_entry', entityId: eid, opType: 'void',
              expectedVersion: 1, payload: { reason: 'entered twice' } };
  const first = await push(user, [v]);
  ok('void applies', first.json.results[0].status === 'applied');

  const again = await push(user, [{ ...v, opId: uuid() }]);
  ok('voiding again succeeds rather than erroring',
     again.json.results[0].status === 'applied', again.json.results[0].error?.code);

  const edit = { opId: uuid(), entity: 'ledger_entry', entityId: eid, opType: 'update',
                 expectedVersion: 2, payload: { amountPaise: 999999 } };
  const res = await push(user, [edit]);
  ok('editing a voided entry is refused',
     res.json.results[0].error?.code === 'ENTITY_VOIDED', res.json.results[0].error?.code);
}

console.log('\n8. Ownership cannot be asserted or crossed');
{
  const other = await signIn(`+9190001${stamp}`);
  const theirs = uuid7();
  await push(other, [customerOp(theirs, 'Their Customer')]);

  // Our user updating a row that belongs to someone else.
  const res = await push(user, [{
    opId: uuid(), entity: 'customer', entityId: theirs, opType: 'update',
    expectedVersion: 1, payload: { name: 'Stolen', phone: null, notes: '' },
  }]);

  ok('reported as not found, never as forbidden',
     res.json.results[0].error?.code === 'NOT_FOUND', res.json.results[0].error?.code);

  // A payload trying to name its own owner.
  const smuggle = await push(user, [{
    ...customerOp(uuid7()), userId: other.userId,
  }]);
  ok('a request declaring userId is rejected outright',
     smuggle.status === 400, `got ${smuggle.status}`);
}

console.log('\n9. Invalid data is refused before it reaches the database');
{
  const cid = uuid7();
  await push(user, [customerOp(cid, 'Validation')]);

  const cases = [
    ['negative amount', { amountPaise: -500000 }],
    ['zero amount', { amountPaise: 0 }],
    ['unknown direction', { direction: 'sideways' }],
    ['unknown ledger side', { ledgerSide: 'elsewhere' }],
    ['future date', { entryDate: '2099-01-01' }],
    ['malformed date', { entryDate: '03-03-2026' }],
  ];

  for (const [label, override] of cases) {
    const op = entryOp(uuid7(), cid);
    const res = await push(user, [{ ...op, payload: { ...op.payload, ...override } }]);
    ok(label, res.json.results[0].status === 'rejected',
       JSON.stringify(res.json.results[0].error?.code));
  }
}

console.log('\n10. An entry with no customer is retryable, not fatal');
{
  // Its customer is in a batch that has not landed. The client retries; the
  // entry must not be dead-lettered on the first attempt.
  const res = await push(user, [entryOp(uuid7(), uuid7())]);

  ok('code is PARENT_NOT_FOUND',
     res.json.results[0].error?.code === 'PARENT_NOT_FOUND', res.json.results[0].error?.code);
  ok('not permanent, so the client retries',
     res.json.results[0].error?.permanent === false);
}

console.log('\n11. Batch limits are enforced');
{
  const tooMany = Array.from({ length: 201 }, () => customerOp(uuid7()));
  const res = await push(user, tooMany);
  ok('201 operations rejected', res.status === 400, `got ${res.status}`);

  const empty = await push(user, []);
  ok('an empty batch rejected', empty.status === 400, `got ${empty.status}`);
}

console.log('\n12. Unauthenticated pushes are refused');
{
  const res = await call('/v1/sync/push', { body: { operations: [customerOp(uuid7())] } });
  ok('401 without a token', res.status === 401, `got ${res.status}`);
}

console.log('\n' + '='.repeat(50));
console.log(`  ${pass} passed, ${fail} failed`);
console.log('='.repeat(50));
process.exit(fail === 0 ? 0 : 1);
