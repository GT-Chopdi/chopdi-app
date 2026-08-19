import { Injectable } from '@nestjs/common';

export type InterestType = 'none' | 'simple' | 'compound';
export type InterestFrequency = 'daily' | 'weekly' | 'monthly' | 'yearly';

export interface InterestInput {
  /** Principal in paise. */
  principalPaise: bigint;
  /** Rate in basis points, **per period**: 2% monthly is 200 with frequency 'monthly'. */
  rateBp: number;
  type: InterestType;
  frequency: InterestFrequency;
  /** Business date the loan starts accruing from. */
  fromDate: Date;
  /** Date to compute as of. */
  asOf: Date;
}

/** Days in one period, by frequency. */
const PERIOD_DAYS: Record<InterestFrequency, number> = {
  daily: 1,
  weekly: 7,
  monthly: 30,
  yearly: 365,
};

/**
 * Server-authoritative interest calculation.
 *
 * ## Why interest is computed and never stored
 *
 * Accrued interest is a function of *time*, not a fact about a transaction. The
 * client's calculator defaults its end date to "now", so any value it produces
 * is correct only at the instant it was produced and stale the next morning.
 * Two devices computing "the interest on this loan" at different moments get
 * different numbers and **neither is wrong** — which means treating a
 * disagreement between them as a sync conflict is a category error.
 *
 * So the ledger stores the *terms* — principal, rate, type, frequency, start
 * date — and this computes the amount on read. There is nothing to sync and
 * nothing to reconcile.
 *
 * ## Why this uses float64 rather than exact decimal
 *
 * Every other money value in this system is an integer count of paise,
 * precisely to keep floating point away from balances. This is the deliberate
 * exception, and the reason is the client.
 *
 * Dart has no built-in decimal type: `InterestCalculator` in the Flutter app
 * computes with `double`. If the server used exact decimal arithmetic it would
 * disagree with the client in the final paise on many inputs — not because
 * either is buggy, but because they would be evaluating different arithmetic.
 * Mirroring IEEE-754 double, in the same operation order, is what lets the two
 * agree.
 *
 * The rounding to whole paise happens once, at the very end. Intermediate
 * values are never rounded, so error cannot accumulate across the calculation.
 * The result is authoritative; the client's copy is for offline display only.
 *
 * Both implementations are pinned to the same fixture — see
 * `docs/rnd/interest-vectors.json` — so a change to either side that alters a
 * number fails a test rather than surfacing as a customer dispute.
 */
@Injectable()
export class InterestService {
  /**
   * Whole calendar days between two dates.
   *
   * Calendar days, not elapsed milliseconds: "3 March to 4 March" is one day of
   * interest regardless of the clock time either date carries, and both dates
   * are business dates rather than instants.
   */
  static daysBetween(from: Date, to: Date): number {
    const startUtc = Date.UTC(
      from.getUTCFullYear(),
      from.getUTCMonth(),
      from.getUTCDate(),
    );
    const endUtc = Date.UTC(to.getUTCFullYear(), to.getUTCMonth(), to.getUTCDate());

    return Math.floor((endUtc - startUtc) / 86_400_000);
  }

  /**
   * Accrued interest in paise, rounded half-up.
   *
   * Returns 0 for a same-day or future `asOf`: interest accrues over elapsed
   * days, and a loan cannot owe interest before it exists.
   */
  compute(input: InterestInput): bigint {
    const { principalPaise, rateBp, type, frequency, fromDate, asOf } = input;

    if (type === 'none' || rateBp === 0 || principalPaise === 0n) return 0n;

    const days = InterestService.daysBetween(fromDate, asOf);
    if (days <= 0) return 0n;

    const principal = Number(principalPaise);
    const periods = days / PERIOD_DAYS[frequency];
    const periodicRate = rateBp / 10_000;

    const interest =
      type === 'simple'
        ? principal * periodicRate * periods
        : principal * (Math.pow(1 + periodicRate, periods) - 1);

    if (!Number.isFinite(interest) || interest < 0) {
      // A rate and duration extreme enough to overflow is a data problem, not a
      // number to quietly return. The CHECK constraints bound the inputs, so
      // reaching here means something bypassed them.
      throw new Error(
        `Interest computation produced a non-finite result ` +
          `(principal=${principalPaise}, rateBp=${rateBp}, ${type}/${frequency}, days=${days})`,
      );
    }

    return InterestService.roundHalfUp(interest);
  }

  /**
   * Rounds to a whole paise, half away from zero.
   *
   * `Math.round` rounds half *up* toward positive infinity, which is a
   * different rule for negative values. Interest is never negative here, but
   * being explicit costs nothing and matches Dart's `.round()`, which is what
   * the client uses.
   */
  private static roundHalfUp(value: number): bigint {
    return BigInt(Math.sign(value) * Math.round(Math.abs(value)));
  }
}
