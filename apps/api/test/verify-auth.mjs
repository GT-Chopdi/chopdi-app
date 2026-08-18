/**
 * Auth flow verification — runs against a LIVE server, not a mocked one.
 *
 *   API_BASE=http://localhost:3000/api DEV_KEY=... node test/verify-auth.mjs
 *
 * This is a black-box security regression suite: every check corresponds to a
 * control that must hold in production (mass assignment rejected, dev-key gate,
 * refresh reuse revoking the family, device binding). It talks HTTP rather than
 * using Nest's testing module on purpose — these controls live in guards,
 * pipes, and filters, which an in-process unit test can bypass entirely.
 *
 * Requires AUTH_DEV_MODE=true on the target, since it authenticates with the
 * fixed code. Uses a random phone number per run so repeated runs do not trip
 * the per-phone resend cooldown.
 */
const BASE = process.env.API_BASE ?? 'http://localhost:3111/api';
const DEV_KEY = process.env.DEV_KEY ?? 'dev-key-0123456789abcdef';

// Randomised so consecutive runs don't collide on the resend cooldown or
// reuse a user row from a previous run.
const suffix = String(Math.floor(Math.random() * 90000) + 10000);
const PHONE = `+9198765${suffix}`;
const PHONE_ALT = `+9198764${suffix}`;
const INSTALL = '018f0000-0000-7000-8000-000000000abc';

let pass = 0;
let fail = 0;

function check(name, condition, detail = '') {
  if (condition) {
    pass++;
    console.log(`  PASS  ${name}`);
  } else {
    fail++;
    console.log(`  FAIL  ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

async function call(path, { method = 'POST', body, headers = {} } = {}) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: { 'content-type': 'application/json', ...headers },
    body: body ? JSON.stringify(body) : undefined,
  });
  let json = null;
  try {
    json = await res.json();
  } catch {
    /* 204 has no body */
  }
  return { status: res.status, json };
}

const devKey = { 'x-dev-key': DEV_KEY };

console.log('\n1. Health is public and unthrottled');
{
  const r = await fetch(`${BASE}/health`);
  check('GET /health → 200', r.status === 200, `got ${r.status}`);
}

console.log('\n2. Dev key gates the fixed-OTP bypass');
{
  const r = await call('/v1/auth/otp/request', {
    body: { phone: PHONE, installId: INSTALL, platform: 'android' },
  });
  check('no X-Dev-Key → 403', r.status === 403, `got ${r.status}`);
  check('code is DEV_KEY_REQUIRED', r.json?.error?.code === 'DEV_KEY_REQUIRED');
}

console.log('\n3. Mass assignment is rejected');
{
  const r = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: {
      phone: PHONE,
      installId: INSTALL,
      platform: 'android',
      userId: 'attacker-supplied',
    },
  });
  check('unknown property userId → 400', r.status === 400, `got ${r.status}`);
  check('code is VALIDATION_FAILED', r.json?.error?.code === 'VALIDATION_FAILED');
}

console.log('\n4. Malformed phone is rejected');
{
  const r = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: { phone: '9876500001', installId: INSTALL, platform: 'android' },
  });
  check('non-E.164 phone → 400', r.status === 400, `got ${r.status}`);
}

console.log('\n5. OTP request + verify (new user)');
let session;
{
  const req = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: { phone: PHONE, installId: INSTALL, platform: 'android' },
  });
  check('request → 200', req.status === 200, `got ${req.status}`);
  check('returns challengeId', typeof req.json?.challengeId === 'string');

  const wrong = await call('/v1/auth/otp/verify', {
    headers: devKey,
    body: {
      challengeId: req.json.challengeId,
      code: '000000',
      installId: INSTALL,
      platform: 'android',
      appVersion: '0.1.0',
    },
  });
  check('wrong code → 401', wrong.status === 401, `got ${wrong.status}`);
  check('code is INVALID_CODE', wrong.json?.error?.code === 'INVALID_CODE');
  check(
    'reports attempts remaining',
    wrong.json?.error?.details?.attemptsRemaining === 4,
    JSON.stringify(wrong.json?.error?.details),
  );

  const ok = await call('/v1/auth/otp/verify', {
    headers: devKey,
    body: {
      challengeId: req.json.challengeId,
      code: '123456',
      installId: INSTALL,
      platform: 'android',
      appVersion: '0.1.0',
    },
  });
  check('correct code → 200', ok.status === 200, JSON.stringify(ok.json));
  check('isNewUser is true', ok.json?.isNewUser === true);
  check('returns accessToken', typeof ok.json?.accessToken === 'string');
  check('returns refreshToken', typeof ok.json?.refreshToken === 'string');
  check('returns deviceId', typeof ok.json?.deviceId === 'string');
  session = ok.json;

  const replay = await call('/v1/auth/otp/verify', {
    headers: devKey,
    body: {
      challengeId: req.json.challengeId,
      code: '123456',
      installId: INSTALL,
      platform: 'android',
      appVersion: '0.1.0',
    },
  });
  check('consumed challenge cannot be reused', replay.status === 401);
}

console.log('\n6a. Resend cooldown blocks UNCONSUMED challenges (SMS bombing)');
{
  const first = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: { phone: PHONE_ALT, installId: INSTALL, platform: 'android' },
  });
  check('first request → 200', first.status === 200, `got ${first.status}`);

  const second = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: { phone: PHONE_ALT, installId: INSTALL, platform: 'android' },
  });
  check('immediate resend → 429', second.status === 429, `got ${second.status}`);
  check('code is RATE_LIMITED', second.json?.error?.code === 'RATE_LIMITED');
  check(
    'carries retryAfterSeconds',
    typeof second.json?.error?.details?.retryAfterSeconds === 'number',
  );
}

console.log('\n6b. A completed login does NOT block the next one');
{
  // The step-5 challenge was consumed, so a fresh request must be allowed.
  const req = await call('/v1/auth/otp/request', {
    headers: devKey,
    body: { phone: PHONE, installId: INSTALL, platform: 'android' },
  });
  check('re-login after consumed challenge → 200', req.status === 200, `got ${req.status}`);

  const ok = await call('/v1/auth/otp/verify', {
    headers: devKey,
    body: {
      challengeId: req.json.challengeId,
      code: '123456',
      installId: INSTALL,
      platform: 'android',
      appVersion: '0.1.0',
    },
  });
  check('verify → 200', ok.status === 200, JSON.stringify(ok.json));
  check('isNewUser is now false', ok.json?.isNewUser === false);
  check(
    'same phone resolved to the SAME user',
    ok.json?.user?.id === session.user.id,
    `${ok.json?.user?.id} vs ${session.user.id}`,
  );
  check(
    'same install resolved to the SAME device',
    ok.json?.deviceId === session.deviceId,
    `${ok.json?.deviceId} vs ${session.deviceId}`,
  );
}

console.log('\n7. Authenticated route requires token AND matching device');
{
  const noToken = await call('/v1/auth/logout');
  check('no token → 401', noToken.status === 401, `got ${noToken.status}`);

  const noDevice = await call('/v1/auth/logout', {
    headers: { authorization: `Bearer ${session.accessToken}` },
  });
  check('token but no X-Device-Id → 403', noDevice.status === 403, `got ${noDevice.status}`);

  const wrongDevice = await call('/v1/auth/logout', {
    headers: {
      authorization: `Bearer ${session.accessToken}`,
      'x-device-id': '018f0000-0000-7000-8000-0000000fffff',
    },
  });
  check('mismatched device → 403', wrongDevice.status === 403, `got ${wrongDevice.status}`);
}

console.log('\n8. Refresh rotation and reuse detection');
{
  const first = await call('/v1/auth/refresh', {
    body: { refreshToken: session.refreshToken, deviceId: session.deviceId },
  });
  check('refresh → 200', first.status === 200, JSON.stringify(first.json));
  check('issues a NEW refresh token', first.json?.refreshToken !== session.refreshToken);

  const reuse = await call('/v1/auth/refresh', {
    body: { refreshToken: session.refreshToken, deviceId: session.deviceId },
  });
  check('reusing the old token → 401', reuse.status === 401, `got ${reuse.status}`);
  check('code is REFRESH_REUSED', reuse.json?.error?.code === 'REFRESH_REUSED');
  check('marked permanent', reuse.json?.error?.permanent === true);

  // The whole family must now be dead, including the successor issued above.
  const successor = await call('/v1/auth/refresh', {
    body: { refreshToken: first.json.refreshToken, deviceId: session.deviceId },
  });
  check(
    'successor token revoked with the family',
    successor.status === 401,
    `got ${successor.status}`,
  );
}

console.log('\n9. Error envelope shape');
{
  const r = await call('/v1/auth/refresh', {
    body: { refreshToken: 'x'.repeat(64), deviceId: session.deviceId },
  });
  const e = r.json?.error;
  check('has error.code', typeof e?.code === 'string');
  check('has error.message', typeof e?.message === 'string');
  check('has error.permanent', typeof e?.permanent === 'boolean');
  check('has requestId', typeof r.json?.requestId === 'string');
}

console.log(`\n${'='.repeat(46)}`);
console.log(`  ${pass} passed, ${fail} failed`);
console.log('='.repeat(46));
process.exit(fail === 0 ? 0 : 1);
