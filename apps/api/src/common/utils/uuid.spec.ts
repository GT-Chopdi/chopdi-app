import { uuidv7 } from './uuid';

const UUID_SHAPE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

describe('uuidv7', () => {
  it('produces a canonically formatted UUID', () => {
    expect(uuidv7()).toMatch(UUID_SHAPE);
  });

  it('sets version 7', () => {
    // Version lives in the first nibble of the third group.
    for (let i = 0; i < 100; i++) {
      expect(uuidv7().split('-')[2][0]).toBe('7');
    }
  });

  it('sets the RFC 9562 variant', () => {
    // Variant is the top two bits of the fourth group: 0b10xx → 8, 9, a, or b.
    for (let i = 0; i < 100; i++) {
      expect(['8', '9', 'a', 'b']).toContain(uuidv7().split('-')[3][0]);
    }
  });

  it('encodes the current time in the leading 48 bits', () => {
    const before = Date.now();
    const encoded = parseInt(uuidv7().replace(/-/g, '').slice(0, 12), 16);
    const after = Date.now();

    expect(encoded).toBeGreaterThanOrEqual(before);
    expect(encoded).toBeLessThanOrEqual(after);
  });

  it('sorts lexicographically in generation order', () => {
    // This is the entire reason for choosing v7 over v4: ids created near each
    // other in time stay adjacent in a B-tree index. A v4 implementation would
    // fail this test roughly always.
    const ids = Array.from({ length: 5000 }, () => uuidv7());
    expect([...ids].sort()).toEqual(ids);
  });

  it('never repeats, even across a single millisecond', () => {
    const ids = new Set(Array.from({ length: 20_000 }, () => uuidv7()));
    expect(ids.size).toBe(20_000);
  });
});
