/**
 * Verifies GET /v1/sync/pull — restoring a user's data on sign-in — and the
 * chopdi / lender entities it depends on, against a running server and real
 * Postgres.
 *
 * The cases that matter: a new device gets back exactly what the account
 * wrote, in an order it can apply; nobody else's data leaks in; paging never
 * skips or repeats; and malformed or impossible cursors are refused.
 *
 *   API_BASE=http://localhost:3111/api DEV_KEY=... node test/verify-pull.mjs
 *
 * Run with a small SYNC_MAX_PULL_LIMIT (e.g. 5) on the server so paging is
 * actually exercised.
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
  return { status: res.status, json, headers: res.headers };
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

  return {
    token: verify.json.accessToken,
    userId: verify.json.user.id,
    deviceId: verify.json.deviceId,
  };
};

const push = (s, operations) =>
  call('/v1/sync/push', { body: { operations }, token: s.token, deviceId: s.deviceId });

const pull = (s, query = '') =>
  call(`/v1/sync/pull${query}`, { method: 'GET', token: s.token, deviceId: s.deviceId });

/** Pages until hasMore is false, the way the client does. */
const pullAll = async (s, from = '0') => {
  const changes = [];
  let cursor = from;
  let pages = 0;
  for (;;) {
    const res = await pull(s, `?cursor=${cursor}`);
    if (res.status !== 200) throw new Error(`pull failed: ${res.status} ${JSON.stringify(res.json)}`);
    pages++;
    changes.push(...res.json.changes);
    cursor = res.json.nextCursor;
    if (!res.json.hasMore) return { changes, cursor, pages, last: res.json };
    if (pages > 100) throw new Error('pull did not terminate');
  }
};

const op = (entity, entityId, payload, extra = {}) => ({
  opId: uuid(),
  entity,
  entityId,
  opType: 'create',
  payload,
  ...extra,
});

const entry = (parent, direction, ledgerSide) => ({
  ...parent,
  amountPaise: 250000,
  direction,
  ledgerSide,
  interestRateBp: 0,
  interestType: 'none',
  interestFrequency: 'monthly',
  entryDate: '2026-03-03',
  description: '',
  paymentMode: 'cash',
});

const stamp = Date.now().toString().slice(-7);
const phone = `+9191000${stamp}`;
const deviceA = await signIn(phone);

// ---------------------------------------------------------------------------
console.log('\n1. A brand-new account pulls nothing, cleanly');
{
  const res = await pull(deviceA, '?cursor=0');
  ok('200', res.status === 200, `${res.status} ${JSON.stringify(res.json)}`);
  ok('no changes', Array.isArray(res.json.changes) && res.json.changes.length === 0);
  ok('nextCursor stays 0', res.json.nextCursor === '0');
  ok('hasMore false', res.json.hasMore === false);
  ok('Cache-Control: no-store', res.headers.get('cache-control') === 'no-store');

  const bare = await pull(deviceA);
  ok('cursor may be omitted', bare.status === 200 && bare.json.nextCursor === '0');
}

// ---------------------------------------------------------------------------
console.log('\n2. Device A pushes a book, a customer (gave), a lender (took) and entries');
const bookId = uuid7();
const customerId = uuid7();
const lenderId = uuid7();
const gaveEntry = uuid7();
const tookEntry = uuid7();
const legacyTookEntry = uuid7();
{
  const res = await push(deviceA, [
    // Deliberately out of order: the server must still apply parents first.
    op('ledger_entry', gaveEntry, entry({ customerId }, 'gave', 'lent')),
    op('lender', lenderId, { name: 'Suresh', phone: '+919876500002', notes: '', chopdiId: bookId }),
    op('customer', customerId, { name: 'Ramesh', phone: '+919876500001', notes: '', chopdiId: bookId }),
    op('chopdi', bookId, { name: 'Shop book', description: 'Main' }),
    op('ledger_entry', tookEntry, entry({ lenderId }, 'received', 'borrowed')),
    // Frozen by an older build: a "took" entry naming its lender as customerId.
    op('ledger_entry', legacyTookEntry, entry({ customerId: lenderId }, 'gave', 'borrowed')),
  ]);
  const statuses = res.json.results?.map((r) => r.status);
  ok('all six applied', statuses?.every((s) => s === 'applied'), JSON.stringify(res.json));
}

// ---------------------------------------------------------------------------
console.log('\n3. Signing in on a new device restores everything, paged');
const deviceB = await signIn(phone);
let cursorB;
{
  const { changes, cursor, pages } = await pullAll(deviceB);
  cursorB = cursor;

  ok('more than one page (server cap is small)', pages > 1, `pages=${pages}`);
  ok('six changes', changes.length === 6, `got ${changes.length}`);

  const seqs = changes.map((c) => BigInt(c.seq));
  ok(
    'strictly increasing seq, no repeats',
    seqs.every((s, i) => i === 0 || s > seqs[i - 1]),
  );

  const byId = Object.fromEntries(changes.map((c) => [c.entityId, c]));
  ok('book restored', byId[bookId]?.entity === 'chopdi' && byId[bookId].data.name === 'Shop book');
  ok(
    'customer restored into its book',
    byId[customerId]?.entity === 'customer' && byId[customerId].data.chopdiId === bookId,
  );
  ok(
    'lender restored as a lender, into its book',
    byId[lenderId]?.entity === 'lender' && byId[lenderId].data.chopdiId === bookId,
  );
  ok(
    'gave entry points at the customer',
    byId[gaveEntry]?.data.customerId === customerId && byId[gaveEntry].data.lenderId === null,
  );
  ok(
    'took entry points at the lender',
    byId[tookEntry]?.data.lenderId === lenderId && byId[tookEntry].data.customerId === null,
  );
  ok(
    'legacy customerId=lender entry was filed under the lender',
    byId[legacyTookEntry]?.data.lenderId === lenderId &&
      byId[legacyTookEntry].data.customerId === null,
  );
  ok('amount is an exact string', byId[gaveEntry]?.data.amountPaise === '250000');

  const pos = (id) => changes.findIndex((c) => c.entityId === id);
  ok(
    'parents arrive before children',
    pos(bookId) < pos(customerId) &&
      pos(bookId) < pos(lenderId) &&
      pos(customerId) < pos(gaveEntry) &&
      pos(lenderId) < pos(tookEntry),
  );
}

// ---------------------------------------------------------------------------
console.log('\n4. Catching up returns only what changed since');
{
  const idle = await pull(deviceB, `?cursor=${cursorB}`);
  ok('nothing new', idle.status === 200 && idle.json.changes.length === 0);
  ok('cursor unchanged', idle.json.nextCursor === cursorB);

  const edit = await push(deviceA, [
    {
      opId: uuid(),
      entity: 'customer',
      entityId: customerId,
      opType: 'update',
      expectedVersion: 1,
      payload: { name: 'Ramesh Kumar', phone: '+919876500001', notes: '' },
    },
    { opId: uuid(), entity: 'lender', entityId: lenderId, opType: 'void', expectedVersion: 1, payload: { reason: 'x' } },
  ]);
  ok('edit + void applied', edit.json.results?.every((r) => r.status === 'applied'), JSON.stringify(edit.json));

  const { changes } = await pullAll(deviceB, cursorB);
  ok('exactly two changes', changes.length === 2, `got ${changes.length}`);
  ok('update carries the new name', changes[0]?.opType === 'update' && changes[0].data.name === 'Ramesh Kumar');
  ok('void carries deletedAt', changes[1]?.opType === 'void' && typeof changes[1].data.deletedAt === 'string');
}

// ---------------------------------------------------------------------------
console.log('\n5. Another account sees none of it');
{
  const stranger = await signIn(`+9192000${stamp}`);
  const { changes } = await pullAll(stranger);
  ok('stranger pulls nothing', changes.length === 0, `got ${changes.length}`);

  const hijack = await push(stranger, [
    op('ledger_entry', uuid7(), entry({ lenderId }, 'received', 'borrowed')),
  ]);
  ok(
    "cannot attach an entry to someone else's lender",
    hijack.json.results?.[0]?.error?.code === 'PARENT_NOT_FOUND',
    JSON.stringify(hijack.json),
  );
}

// ---------------------------------------------------------------------------
console.log('\n6. Query validation');
{
  const bad = async (query, label, expected = 400) => {
    const res = await pull(deviceA, query);
    ok(`${label} → ${expected}`, res.status === expected, `${res.status} ${JSON.stringify(res.json)}`);
    return res;
  };

  await bad('?cursor=-1', 'negative cursor');
  await bad('?cursor=abc', 'non-numeric cursor');
  await bad('?cursor=1.5', 'fractional cursor');
  await bad('?cursor=007', 'leading zeros');
  await bad('?cursor=99999999999999999999', '20-digit cursor');
  await bad('?cursor=9223372036854775808', 'cursor above 2^63-1');
  await bad('?limit=0', 'limit 0');
  await bad('?limit=abc', 'non-numeric limit');
  await bad('?limit=2.5', 'fractional limit');
  await bad(`?userId=${uuid()}`, 'userId in query is refused');
  await bad('?foo=bar', 'unknown query param');

  const ahead = await bad('?cursor=999999999', 'cursor ahead of the server', 409);
  ok('…with CURSOR_AHEAD', ahead.json.error?.code === 'CURSOR_AHEAD', JSON.stringify(ahead.json));
  ok('…marked permanent', ahead.json.error?.permanent === true);

  const capped = await pull(deviceA, '?cursor=0&limit=1000');
  ok('limit above the cap is served at the cap', capped.status === 200 && capped.json.changes.length <= 5 && capped.json.hasMore === true);

  const one = await pull(deviceA, '?cursor=0&limit=1');
  ok('limit=1 returns one change', one.json.changes.length === 1 && one.json.hasMore === true);
}

// ---------------------------------------------------------------------------
console.log('\n7. Authentication');
{
  const anon = await call('/v1/sync/pull', { method: 'GET' });
  ok('no token → 401', anon.status === 401, String(anon.status));

  const wrongDevice = await call('/v1/sync/pull', {
    method: 'GET',
    token: deviceA.token,
    deviceId: deviceB.deviceId,
  });
  ok('token presented from another device → refused', wrongDevice.status === 401 || wrongDevice.status === 403, String(wrongDevice.status));
}

// ---------------------------------------------------------------------------
console.log('\n8. Push-side validation for the new entities');
{
  const res = await push(deviceA, [
    op('ledger_entry', uuid7(), entry({ customerId, lenderId }, 'gave', 'lent')),
    op('customer', uuid7(), { name: 'Orphan', chopdiId: uuid7() }),
    op('chopdi', uuid7(), { name: '   ' }),
    op('lender', uuid7(), { name: 'Bad book', chopdiId: 'not-a-uuid' }),
  ]);
  const [both, noBook, blank, badBook] = res.json.results ?? [];
  ok('entry with two parents rejected', both?.error?.code === 'VALIDATION_FAILED' && both.error.permanent === true);
  ok('party in an unknown book waits for it', noBook?.error?.code === 'PARENT_NOT_FOUND' && noBook.error.permanent === false);
  ok('blank book name rejected', blank?.error?.code === 'VALIDATION_FAILED');
  ok('malformed chopdiId rejected', badBook?.error?.code === 'VALIDATION_FAILED');
}

// ---------------------------------------------------------------------------
console.log('\n9. A legacy customer that was really a lender is converted in place');
{
  const legacyId = uuid7();
  const legacyEntry = uuid7();

  const before = await push(deviceA, [
    op('customer', legacyId, { name: 'Old lender', phone: null, notes: '' }),
    op('ledger_entry', legacyEntry, entry({ customerId: legacyId }, 'received', 'borrowed')),
  ]);
  ok('legacy rows applied', before.json.results?.every((r) => r.status === 'applied'));

  const { cursor } = await pullAll(deviceB, '0');

  const convert = await push(deviceA, [
    op('lender', legacyId, { name: 'Old lender', phone: null, notes: '', chopdiId: bookId }),
  ]);
  ok('lender/create over the legacy id applied', convert.json.results?.[0]?.status === 'applied', JSON.stringify(convert.json));

  const { changes } = await pullAll(deviceB, cursor);
  const kinds = changes.map((c) => `${c.entity}:${c.opType}`);
  ok(
    'pull shows lender created, entry moved, customer retired — in that order',
    JSON.stringify(kinds) === JSON.stringify(['lender:create', 'ledger_entry:update', 'customer:void']),
    JSON.stringify(kinds),
  );
  ok('moved entry now names the lender', changes[1]?.data.lenderId === legacyId && changes[1].data.customerId === null);
}

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
