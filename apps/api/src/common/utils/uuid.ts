import { randomBytes } from 'node:crypto';

/**
 * UUIDv7 generator (RFC 9562).
 *
 * Implemented here rather than taken from the `uuid` package because that
 * package is now ESM-only, and this codebase compiles to CommonJS. Local Node
 * papers over the mismatch — Node 20.19+ can `require()` an ES module — but
 * Vercel's runtime loader cannot, so the same build worked locally and died in
 * production with ERR_REQUIRE_ESM. Owning ~30 lines of a fixed, well-specified
 * format is cheaper than tracking module-format churn in a dependency, and it
 * cannot break under a different bundler.
 *
 * Layout (128 bits):
 *
 *   bytes 0-5   48-bit Unix timestamp in milliseconds, big-endian
 *   byte  6     high nibble = version (0b0111), low nibble = counter high bits
 *   byte  7     counter low bits
 *   byte  8     top two bits = variant (0b10), remaining 6 bits random
 *   bytes 9-15  random
 *
 * The time prefix is the point: UUIDv7 values generated near each other in time
 * sort near each other, so Postgres B-tree inserts stay local instead of
 * scattering across the index the way UUIDv4 does.
 */

/** Last timestamp handed out, in ms. */
let lastMs = 0;

/** 12-bit counter, used to keep ids ordered within a single millisecond. */
let counter = 0;

/** Maximum value of the 12-bit counter (4096 ids per millisecond). */
const COUNTER_MAX = 0xfff;

export function uuidv7(): string {
  const now = Date.now();

  if (now > lastMs) {
    lastMs = now;
    counter = 0;
  } else {
    // Same millisecond, or the clock jumped backwards (an NTP correction, a
    // VM resume). Either way, keep the previous timestamp and advance the
    // counter — ids must never go backwards, or the "sorts by creation time"
    // property that justifies v7 stops holding.
    counter += 1;

    if (counter > COUNTER_MAX) {
      // More than 4096 ids in one millisecond. Borrow from the next
      // millisecond rather than wrapping, which would emit a duplicate.
      lastMs += 1;
      counter = 0;
    }
  }

  const bytes = randomBytes(16);
  const ts = lastMs;

  // 48-bit big-endian timestamp. Math.floor before the mask because bitwise
  // operators coerce to int32, which would silently truncate the upper bits.
  bytes[0] = Math.floor(ts / 2 ** 40) & 0xff;
  bytes[1] = Math.floor(ts / 2 ** 32) & 0xff;
  bytes[2] = Math.floor(ts / 2 ** 24) & 0xff;
  bytes[3] = Math.floor(ts / 2 ** 16) & 0xff;
  bytes[4] = Math.floor(ts / 2 ** 8) & 0xff;
  bytes[5] = ts & 0xff;

  // Version 7 in the high nibble, counter's top 4 bits in the low nibble.
  bytes[6] = 0x70 | ((counter >>> 8) & 0x0f);
  bytes[7] = counter & 0xff;

  // RFC 9562 variant: top two bits are 0b10, the rest stays random.
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  const hex = bytes.toString('hex');

  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join('-');
}
