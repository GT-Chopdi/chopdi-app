/**
 * Proves ChangeLogService produces a gap-free, commit-ordered sequence when two
 * transactions race for the same user.
 *
 * The unit-level SQL check in verify-schema.mjs shows the row lock works. This
 * shows the *service* uses it correctly — that the sequence is taken inside the
 * caller's transaction and held, rather than fetched and released early, which
 * would compile fine and silently reintroduce the skipped-row bug.
 *
 *   DATABASE_URL=postgres://... node test/verify-change-log.mjs
 */
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('../dist/generated/prisma/client');
const { ChangeLogService } = require('../dist/modules/sync/change-log.service');

const URL = process.env.DATABASE_URL;
if (!URL) {
  console.error('DATABASE_URL is required');
  process.exit(1);
}

let pass = 0;
let fail = 0;
const ok = (label, cond, detail = '') => {
  if (cond) { pass++; console.log(`  PASS  ${label}`); }
  else { fail++; console.log(`  FAIL  ${label}${detail ? ` — ${detail}` : ''}`); }
};

const prisma = new PrismaClient({ adapter: new PrismaPg(URL) });
const changeLog = new ChangeLogService();

const USER = '018f0000-0000-7000-8000-00000000d001';
const CUST = '018f0000-0000-7000-8000-00000000d002';

/**
 * Removes a test user and everything hanging off them.
 *
 * The change log restricts deletion and its trigger blocks recent rows, so
 * this has to disable the guard deliberately — exactly what a real
 * account-deletion procedure would have to do, and a useful reminder that
 * erasing history is never accidental here.
 */
const purge = async (userId) => {
  await prisma.$executeRawUnsafe(
    'ALTER TABLE sync_change_log DISABLE TRIGGER sync_change_log_append_only_trigger',
  );
  await prisma.syncChangeLog.deleteMany({ where: { userId } });
  await prisma.$executeRawUnsafe(
    'ALTER TABLE sync_change_log ENABLE TRIGGER sync_change_log_append_only_trigger',
  );
  await prisma.appUser.deleteMany({ where: { id: userId } });
};

await purge(USER);
await prisma.appUser.create({
  data: { id: USER, phoneE164: '+919000009002' },
});
await prisma.customer.create({
  data: { id: CUST, userId: USER, name: 'Ramesh' },
});

console.log('\n1. Sequential appends');
{
  const a = await prisma.$transaction((tx) =>
    changeLog.append(tx, {
      userId: USER, entity: 'customer', entityId: CUST,
      opType: 'create', snapshot: { name: 'Ramesh' },
    }));
  const b = await prisma.$transaction((tx) =>
    changeLog.append(tx, {
      userId: USER, entity: 'customer', entityId: CUST,
      opType: 'update', snapshot: { name: 'Ramesh K' }, previous: { name: 'Ramesh' },
    }));

  ok('first append gets seq 1', Number(a) === 1, `got ${a}`);
  ok('second append gets seq 2', Number(b) === 2, `got ${b}`);
}

console.log('\n2. A non-create without previous state is refused');
{
  try {
    await prisma.$transaction((tx) =>
      changeLog.append(tx, {
        userId: USER, entity: 'customer', entityId: CUST,
        opType: 'update', snapshot: {},
      }));
    ok('rejected', false, 'was accepted');
  } catch {
    ok('rejected', true);
  }
}

console.log('\n3. Concurrency for ONE user serialises (bounded)');
{
  // Deliberately small. Every one of these contends for the same row lock, so
  // they execute one at a time no matter how many are launched — extra
  // concurrency buys nothing and costs a held connection each. Fanning out 20
  // against Neon's pooled endpoint exhausts the pool and fails with P2028
  // before any of them are wrong. That is the shape of the real constraint:
  // per-user writes are inherently serial, so the push endpoint must apply a
  // batch sequentially and must never Promise.all over it.
  const results = await Promise.all(
    Array.from({ length: 5 }, (_, i) =>
      prisma.$transaction((tx) =>
        changeLog.append(tx, {
          userId: USER, entity: 'ledger_entry', entityId: CUST,
          opType: 'create', snapshot: { i },
        })),
    ),
  );

  const nums = results.map(Number).sort((x, y) => x - y);
  ok('every sequence is unique', new Set(nums).size === 5);
  ok('no gaps in the range', nums[4] - nums[0] === 4, `${nums[0]}..${nums[4]}`);
}

console.log('\n3b. Different users do NOT contend');
{
  // The lock is per user, so unrelated tenants proceed in parallel. This is
  // what keeps the design scalable: the serialisation above is a per-user
  // property, not a global one.
  const others = [
    '018f0000-0000-7000-8000-00000000d0a1',
    '018f0000-0000-7000-8000-00000000d0a2',
    '018f0000-0000-7000-8000-00000000d0a3',
  ];

  for (const id of others) {
    await purge(id);
    await prisma.appUser.create({
      data: { id, phoneE164: `+9190000${id.slice(-4)}` },
    });
  }

  const seqs = await Promise.all(
    others.map((id) =>
      prisma.$transaction((tx) =>
        changeLog.append(tx, {
          userId: id, entity: 'customer', entityId: CUST,
          opType: 'create', snapshot: {},
        })),
    ),
  );

  ok('each tenant starts its own sequence at 1',
     seqs.every((n) => Number(n) === 1), seqs.map(Number).join(','));

  for (const id of others) await purge(id);
}

console.log('\n4. Cursor paging never skips a row');
{
  // Simulates the pull loop: read forward in pages, assert full coverage.
  const total = await prisma.syncChangeLog.count({ where: { userId: USER } });
  let cursor = 0n;
  const seen = [];
  for (;;) {
    const page = await prisma.syncChangeLog.findMany({
      where: { userId: USER, seq: { gt: cursor } },
      orderBy: { seq: 'asc' },
      take: 5,
      select: { seq: true },
    });
    if (page.length === 0) break;
    seen.push(...page.map((r) => Number(r.seq)));
    cursor = page[page.length - 1].seq;
  }
  ok('paging returns every row exactly once',
     seen.length === total && new Set(seen).size === total,
     `saw ${seen.length} of ${total}`);
}

console.log('\n5. An unknown user cannot produce a log row');
{
  try {
    await prisma.$transaction((tx) =>
      changeLog.append(tx, {
        userId: '018f0000-0000-7000-8000-0000000000ff',
        entity: 'customer', entityId: CUST,
        opType: 'create', snapshot: {},
      }));
    ok('rejected', false, 'was accepted');
  } catch {
    ok('rejected', true);
  }
}

console.log('\n6. Deleting a user cannot quietly erase their audit trail');
{
  try {
    await prisma.appUser.deleteMany({ where: { id: USER } });
    ok('user delete is refused while history exists', false, 'it succeeded');
  } catch {
    ok('user delete is refused while history exists', true);
  }
}

await purge(USER);
await prisma.$disconnect();

console.log('\n' + '='.repeat(46));
console.log(`  ${pass} passed, ${fail} failed`);
console.log('='.repeat(46));
process.exit(fail === 0 ? 0 : 1);
