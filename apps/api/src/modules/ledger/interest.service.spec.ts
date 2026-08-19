import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { InterestService, type InterestFrequency, type InterestType } from './interest.service';

interface Vector {
  id: string;
  why: string;
  principalPaise: number;
  rateBp: number;
  type: InterestType;
  frequency: InterestFrequency;
  fromDate: string;
  asOf: string;
  days: number;
  expectedInterestPaise: number;
}

const FIXTURE = join(__dirname, '../../../../../docs/rnd/interest-vectors.json');

describe('InterestService', () => {
  const service = new InterestService();
  const vectors: Vector[] = JSON.parse(readFileSync(FIXTURE, 'utf8')).cases;

  it('loads the shared fixture', () => {
    // If this fails the path is wrong and every case below would vacuously
    // pass, so it is asserted rather than assumed.
    expect(vectors.length).toBeGreaterThan(10);
  });

  describe.each(vectors.map((v) => [v.id, v] as const))('%s', (_id, v) => {
    it(v.why, () => {
      const actual = service.compute({
        principalPaise: BigInt(v.principalPaise),
        rateBp: v.rateBp,
        type: v.type,
        frequency: v.frequency,
        fromDate: new Date(`${v.fromDate}T00:00:00Z`),
        asOf: new Date(`${v.asOf}T00:00:00Z`),
      });

      expect(Number(actual)).toBe(v.expectedInterestPaise);
    });
  });

  describe('day counting', () => {
    it('counts calendar days, not elapsed time', () => {
      // Both dates are business dates. An entry made late on the 3rd and read
      // early on the 4th is one day of interest, not zero.
      const from = new Date('2026-03-03T23:59:00Z');
      const to = new Date('2026-03-04T00:01:00Z');

      expect(InterestService.daysBetween(from, to)).toBe(1);
    });

    it('handles a leap day', () => {
      expect(
        InterestService.daysBetween(
          new Date('2028-02-28T00:00:00Z'),
          new Date('2028-03-01T00:00:00Z'),
        ),
      ).toBe(2);
    });
  });

  describe('guards', () => {
    it('refuses to return a non-finite result', () => {
      // Only reachable if something bypassed the CHECK constraints; returning
      // Infinity as a debt would be far worse than throwing.
      expect(() =>
        service.compute({
          principalPaise: 10_000_000_000_000n,
          rateBp: 1_000_000,
          type: 'compound',
          frequency: 'daily',
          fromDate: new Date('2020-01-01T00:00:00Z'),
          asOf: new Date('2030-01-01T00:00:00Z'),
        }),
      ).toThrow(/non-finite/);
    });
  });
});
