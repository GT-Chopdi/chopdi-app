/**
 * Verifies GET /v2/sync/pull (books → customers / lenders → entries), the
 * server-created default book, and the entry cascade on party delete —
 * against a running server and real Postgres.
 *
 *   API_BASE=http://localhost:3111/api DEV_KEY=... node test/verify-pull-v2.mjs
 *
 * Run with a small SYNC_MAX_PULL_LIMIT (e.g. 5) on the server so paging is
 * exercised: the client-side merge below must reach the same tree whatever
 * the page size.
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
  const seq = (counter++ % 4096).toString(16).padStart(3, '0');
  const rand = crypto.randomUUID().replace(/-/g, '').slice(0, 16);
  return `${ms.slice(0, 8)}-${ms.slice(8, 12)}-7${seq}-8${rand.slice(0, 3)}-${rand.slice(3, 15)}`;
};

const phone = () => `+9198${Math.floor(10_000_000 + Math.random() * 89_999_999)}`;
const today = new Date().toISOString().slice(0, 10);

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

const signIn = async (number, installId = uuid()) => {
  const req = await call('/v1/auth/otp/request', {
    body: { phone: number, installId, platform: 'android' },
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
    deviceId: verify.json.deviceId,
    defaultChopdiId: verify.json.defaultChopdiId,
  };
};

const push = (s, operations) =>
  call('/v1/sync/push', { body: { operations }, token: s.token, deviceId: s.deviceId });

const get = (s, path) => call(path, { method: 'GET', token: s.token, deviceId: s.deviceId });

const op = (entity, entityId, payload, extra = {}) => ({
  opId: uuid(),
  entity,
  entityId,
  opType: 'create',
  payload,
  ...extra,
});

const entryPayload = (parent, direction, amountPaise) => ({
  ...parent,
  amountPaise,
  direction,
  ledgerSide: parent.customerId ? 'lent' : 'borrowed',
  interestRateBp: 1200,
  interestType: 'simple',
  interestFrequency: 'monthly',
  entryDate: today,
});

// ------------------------------------------------------- the client's merge

/**
 * Applies v2 pages the way the app is told to: upsert every record by id at
 * every level, never replace a list. Returns the final state as a tree.
 */
const pullTree = async (s, from = '0') => {
  const books = new Map();
  const parties = new Map(); // id -> { side, chopdiId|null, row }
  const entries = new Map(); // id -> { partyId, row }
  let cursor = from;
  let pages = 0;
  const raw = [];

  for (;;) {
    const res = await get(s, `/v2/sync/pull?cursor=${cursor}`);
    if (res.status !== 200) throw new Error(`v2 pull ${res.status} ${JSON.stringify(res.json)}`);
    raw.push(res.json);
    pages++;

    const takeParties = (list, side, chopdiId) => {
      for (const p of list) {
        const { entries: es, ...row } = p;
        parties.set(p.id, { side, chopdiId, row });
        for (const e of es) entries.set(e.id, { partyId: p.id, row: e });
      }
    };
    for (const c of res.json.chopdis) {
      const { customers, lenders, ...row } = c;
      books.set(c.id, row);
      takeParties(customers, 'customers', c.id);
      takeParties(lenders, 'lenders', c.id);
    }
    takeParties(res.json.unassigned.customers, 'customers', null);
    takeParties(res.json.unassigned.lenders, 'lenders', null);

    cursor = res.json.nextCursor;
    if (!res.json.hasMore) break;
    if (pages > 200) throw new Error('v2 pull did not terminate');
  }

  return { books, parties, entries, cursor, pages, raw };
};

const KEYS = {
  top: ['nextCursor', 'hasMore', 'serverCursor', 'chopdis', 'unassigned'],
  chopdi: ['id', 'name', 'description', 'isDefault', 'version', 'createdAt', 'updatedAt', 'deletedAt', 'customers', 'lenders'],
  party: ['id', 'name', 'phone', 'notes', 'version', 'createdAt', 'updatedAt', 'deletedAt', 'mergedIds', 'entries'],
  entry: ['id', 'amountPaise', 'direction', 'interestRateBp', 'interestType', 'interestFrequency', 'entryDate', 'description', 'paymentMode', 'version', 'createdAt', 'updatedAt', 'voidedAt', 'voidedReason'],
};

/** Every object in every page has exactly the contract's keys, in order. */
const shapeErrors = (page) => {
  const errors = [];
  const check = (obj, keys, where) => {
    const got = Object.keys(obj).join(',');
    if (got !== keys.join(',')) errors.push(`${where}: ${got}`);
  };
  check(page, KEYS.top, 'top');
  check(page.unassigned, ['customers', 'lenders'], 'unassigned');
  const parties = (list, where) =>
    list.forEach((p) => {
      check(p, KEYS.party, where);
      p.entries.forEach((e) => check(e, KEYS.entry, `${where}.entry`));
    });
  page.chopdis.forEach((c) => {
    check(c, KEYS.chopdi, 'chopdi');
    parties(c.customers, 'customer');
    parties(c.lenders, 'lender');
  });
  parties(page.unassigned.customers, 'unassigned.customer');
  parties(page.unassigned.lenders, 'unassigned.lender');
  return errors;
};

// ------------------------------------------------------------------- run

console.log(`\nverify-pull-v2 against ${API}\n`);

// 1. Default book: created by the server, exactly once.
console.log('Default book');
const number = phone();
const [a, b] = await Promise.all([signIn(number), signIn(number)]);
ok('sign-in returns defaultChopdiId', /^[0-9a-f-]{36}$/.test(a.defaultChopdiId ?? ''), a.defaultChopdiId);
ok('two first sign-ins at once agree on one default', a.defaultChopdiId === b.defaultChopdiId, `${a.defaultChopdiId} vs ${b.defaultChopdiId}`);
const again = await signIn(number);
ok('a later sign-in returns the same default', again.defaultChopdiId === a.defaultChopdiId);

const fresh = await pullTree(a);
const freshBooks = [...fresh.books.values()];
ok('a new account pulls exactly one book', freshBooks.length === 1, String(freshBooks.length));
ok('it is the default "My Chopdi"', freshBooks[0]?.isDefault === true && freshBooks[0]?.name === 'My Chopdi' && freshBooks[0]?.id === a.defaultChopdiId);

// 2. Three books with customers and lenders, through push.
console.log('\nThree books');
const mine = a.defaultChopdiId;
const teat = uuid7();
const harsh = uuid7();
const ids = {
  ravi: uuid7(), suresh: uuid7(), amit: uuid7(), mahesh: uuid7(), neha: uuid7(),
  e1: uuid7(), e2: uuid7(), e3: uuid7(), e4: uuid7(), e5: uuid7(),
  legacy: uuid7(),
};

const setup = await push(a, [
  op('chopdi', teat, { name: 'Teat', isDefault: true }),
  op('chopdi', harsh, { name: 'Harsh' }),
  op('customer', ids.ravi, { name: 'Ravi Kumar', phone: '9045164399', notes: '', chopdiId: mine }),
  op('lender', ids.suresh, { name: 'Suresh Patel', phone: '9876500002', notes: '', chopdiId: mine }),
  op('customer', ids.amit, { name: 'Amit Sharma', phone: '9123400003', notes: 'Pays monthly', chopdiId: teat }),
  op('lender', ids.mahesh, { name: 'Mahesh Gupta', phone: null, notes: '', chopdiId: teat }),
  op('customer', ids.neha, { name: 'Neha Verma', phone: '9988700004', notes: '', chopdiId: harsh }),
  op('customer', ids.legacy, { name: 'Old Customer', phone: null, notes: '' }),
  op('ledger_entry', ids.e1, entryPayload({ customerId: ids.ravi }, 'gave', 500000)),
  op('ledger_entry', ids.e2, entryPayload({ lenderId: ids.suresh }, 'received', 2000000)),
  op('ledger_entry', ids.e3, entryPayload({ customerId: ids.amit }, 'gave', 1000000)),
  op('ledger_entry', ids.e4, entryPayload({ lenderId: ids.mahesh }, 'received', 5000000)),
  op('ledger_entry', ids.e5, entryPayload({ customerId: ids.neha }, 'gave', 250000)),
]);
const notApplied = setup.json.results?.filter((r) => r.status !== 'applied') ?? ['no results'];
ok('every setup operation applied', setup.status === 200 && notApplied.length === 0, JSON.stringify(notApplied));

const full = await pullTree(a);
ok('paged (small SYNC_MAX_PULL_LIMIT)', full.pages > 1, `${full.pages} page(s)`);

const allShapeErrors = full.raw.flatMap(shapeErrors);
ok('every page matches the contract keys and order', allShapeErrors.length === 0, allShapeErrors.slice(0, 3).join(' | '));

const books = [...full.books.values()];
ok('three books', books.length === 3, books.map((x) => x.name).join(','));
ok('exactly one default book', books.filter((x) => x.isDefault).length === 1);
ok('isDefault sent by the app is ignored', full.books.get(teat)?.isDefault === false);

const where = (id) => full.parties.get(id);
ok('Ravi and Suresh are in My Chopdi', where(ids.ravi)?.chopdiId === mine && where(ids.suresh)?.chopdiId === mine);
ok('Amit and Mahesh are in Teat', where(ids.amit)?.chopdiId === teat && where(ids.mahesh)?.chopdiId === teat);
ok('Neha is in Harsh', where(ids.neha)?.chopdiId === harsh && where(ids.neha)?.side === 'customers');
ok('lenders are under lenders', where(ids.suresh)?.side === 'lenders' && where(ids.mahesh)?.side === 'lenders');
ok('a party without a book is unassigned', where(ids.legacy)?.chopdiId === null);

const entryAt = (id) => full.entries.get(id);
ok('each entry sits under its own party', entryAt(ids.e1)?.partyId === ids.ravi && entryAt(ids.e4)?.partyId === ids.mahesh && entryAt(ids.e5)?.partyId === ids.neha);
ok('amountPaise is a string', entryAt(ids.e2)?.row.amountPaise === '2000000');
ok('no record of another book leaks into Harsh', [...full.parties.values()].filter((p) => p.chopdiId === harsh).length === 1);

const lastPage = full.raw.at(-1);
ok('final page: hasMore false, cursors agree', lastPage.hasMore === false && lastPage.nextCursor === lastPage.serverCursor);

// 3. Incremental: only what changed, with its parents.
console.log('\nIncremental pull');
const cursorBefore = full.cursor;
const edit = await push(a, [
  op('ledger_entry', ids.e3, { amountPaise: 1500000 }, { opType: 'update', expectedVersion: 1 }),
]);
ok('entry update applied', edit.json.results?.[0]?.status === 'applied');

const inc = await get(a, `/v2/sync/pull?cursor=${cursorBefore}`);
ok('incremental pull 200', inc.status === 200);
ok('only the changed book is present', inc.json.chopdis?.length === 1 && inc.json.chopdis[0].id === teat, JSON.stringify(inc.json.chopdis?.map((c) => c.name)));
const incTeat = inc.json.chopdis?.[0];
ok('with only the changed party', incTeat?.customers.length === 1 && incTeat.customers[0].id === ids.amit && incTeat.lenders.length === 0);
ok('carrying the updated entry', incTeat?.customers[0].entries[0]?.amountPaise === '1500000' && incTeat.customers[0].entries[0].version === 2);

// 4. Delete: cascade, and the app's own entry voids still succeed.
console.log('\nDelete');
const cursorBeforeDelete = inc.json.nextCursor;
const del = await push(a, [
  op('customer', ids.neha, { reason: 'Deleted by user' }, { opType: 'void', expectedVersion: 1 }),
  op('ledger_entry', ids.e5, { reason: 'Customer deleted' }, { opType: 'void', expectedVersion: 1 }),
]);
ok('customer void applied', del.json.results?.[0]?.status === 'applied', JSON.stringify(del.json.results?.[0]));
ok("the app's own entry void still succeeds", del.json.results?.[1]?.status === 'applied', JSON.stringify(del.json.results?.[1]));

const afterDelete = await get(a, `/v2/sync/pull?cursor=${cursorBeforeDelete}`);
const deletedNeha = afterDelete.json.chopdis?.find((c) => c.id === harsh)?.customers.find((p) => p.id === ids.neha);
ok('deleted customer comes back in place, marked deleted', typeof deletedNeha?.deletedAt === 'string');
ok('its entry is voided by the server cascade', typeof deletedNeha?.entries[0]?.voidedAt === 'string' && deletedNeha.entries[0].voidedReason === 'Party deleted', JSON.stringify(deletedNeha?.entries[0]));

// Lender delete with no entry voids at all (what the app sends today).
const lenderDel = await push(a, [
  op('lender', ids.mahesh, { reason: 'Deleted by user' }, { opType: 'void', expectedVersion: 1 }),
]);
ok('lender void applied', lenderDel.json.results?.[0]?.status === 'applied');
const afterLender = await pullTree(a);
ok("lender delete voids the lender's entries", typeof afterLender.entries.get(ids.e4)?.row.voidedAt === 'string');
ok('entries of other parties untouched', afterLender.entries.get(ids.e3)?.row.voidedAt === null && afterLender.entries.get(ids.e1)?.row.voidedAt === null);

// 5. Merged duplicate shows up as mergedIds.
console.log('\nMerge');
const dupe = uuid7();
const merged = await push(a, [
  op('customer', dupe, { name: 'ravi  kumar', phone: '+91 90451 64399', notes: '', chopdiId: mine }),
]);
ok('duplicate Ravi merged', merged.json.results?.[0]?.mergedInto === ids.ravi, JSON.stringify(merged.json.results?.[0]));
const afterMerge = await pullTree(a);
ok('Ravi lists the merged id', JSON.stringify(afterMerge.parties.get(ids.ravi)?.row.mergedIds) === JSON.stringify([dupe]));
ok('the alias is not a party of its own', !afterMerge.parties.has(dupe));

// 6. Isolation, versions, errors.
console.log('\nIsolation and errors');
const other = await signIn(phone());
const otherTree = await pullTree(other);
ok("another user sees only their own default book", otherTree.books.size === 1 && !otherTree.books.has(mine) && otherTree.parties.size === 0);

const v1 = await get(a, '/v1/sync/pull?cursor=0&limit=500');
const v1Book = v1.json.changes?.find((c) => c.entity === 'chopdi' && c.entityId === mine);
ok('v1 pull still works', v1.status === 200 && Array.isArray(v1.json.changes));
ok('v1 book changes now carry isDefault', v1Book?.data.isDefault === true);

const ahead = await get(a, '/v2/sync/pull?cursor=999999');
ok('v2 refuses a cursor from the future (CURSOR_AHEAD)', ahead.status === 409 && ahead.json.error?.code === 'CURSOR_AHEAD');
const bad = await get(a, '/v2/sync/pull?cursor=0&userId=x');
ok('v2 refuses unknown query params', bad.status === 400);
const anon = await call('/v2/sync/pull', { method: 'GET' });
ok('v2 requires authentication', anon.status === 401);

console.log(`\n${pass} passed, ${fail} failed\n`);
process.exit(fail === 0 ? 0 : 1);
