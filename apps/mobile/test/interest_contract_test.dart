import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/utils/interest_calculator.dart';

/// Pins the client's interest maths to the same fixture the server asserts
/// against (`apps/api/src/modules/ledger/interest.service.spec.ts`).
///
/// The server's figure is authoritative. The client computes its own so an
/// offline user sees a correct number before syncing — which is only useful if
/// the two agree. Without this test they would drift silently, and the symptom
/// would be a user watching an amount change after sync and losing confidence
/// in the ledger.
void main() {
  final fixture = File('../../docs/rnd/interest-vectors.json');

  late List<dynamic> cases;

  setUpAll(() {
    expect(fixture.existsSync(), isTrue,
        reason: 'Missing ${fixture.path} — the contract cannot be checked, '
            'which is a failure, not a pass.');
    cases = (jsonDecode(fixture.readAsStringSync()) as Map)['cases'] as List;
  });

  test('fixture is non-trivial', () {
    expect(cases.length, greaterThan(10));
  });

  test('every vector matches the server', () {
    final failures = <String>[];

    for (final raw in cases) {
      final v = raw as Map<String, dynamic>;

      // The fixture speaks the server's units: paise and basis points. The
      // client calculator takes a plain amount and a percentage. Interest is
      // linear in the principal, so feeding it paise yields paise.
      final actual = InterestCalculator.calculate(
        principal: (v['principalPaise'] as num).toDouble(),
        rate: (v['rateBp'] as num) / 100.0,
        startDate: DateTime.parse('${v['fromDate']}T00:00:00Z'),
        endDate: DateTime.parse('${v['asOf']}T00:00:00Z'),
        interestType: v['type'] == 'simple' ? 'Simple Interest' : 'Compound',
        frequency: _frequency(v['frequency'] as String),
      );

      // `type: none` has no equivalent in the client calculator — the caller is
      // responsible for not calling it. Treat it as zero here.
      final expected = (v['expectedInterestPaise'] as num).toInt();
      final got = v['type'] == 'none' ? 0 : actual.round();

      if (got != expected) {
        failures.add('${v['id']}: expected $expected paise, got $got '
            '(${v['why']})');
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  group('day counting matches the server', () {
    // The fixture uses midnight-to-midnight dates, which cannot catch this:
    // real entries carry a time, and the end date defaults to DateTime.now().
    // Counting elapsed time instead of calendar days made a loan recorded at
    // 6pm show zero interest the next morning, then jump on sync.
    test('an overnight entry counts as one day, not zero', () {
      expect(
        InterestCalculator.daysBetween(
          DateTime.utc(2026, 3, 3, 18, 0),
          DateTime.utc(2026, 3, 4, 10, 0),
        ),
        1,
      );
    });

    test('the same calendar day counts as zero', () {
      expect(
        InterestCalculator.daysBetween(
          DateTime.utc(2026, 3, 3, 0, 1),
          DateTime.utc(2026, 3, 3, 23, 59),
        ),
        0,
      );
    });

    test('a leap day is counted', () {
      expect(
        InterestCalculator.daysBetween(
          DateTime.utc(2028, 2, 28),
          DateTime.utc(2028, 3, 1),
        ),
        2,
      );
    });

    test('an evening loan accrues the same as the server the next morning', () {
      final interest = InterestCalculator.calculate(
        principal: 500000,
        rate: 2.0,
        startDate: DateTime.utc(2026, 3, 3, 18, 0),
        endDate: DateTime.utc(2026, 3, 4, 10, 0),
        interestType: 'Simple Interest',
        frequency: 'Monthly',
      );

      // 500000 paise x 2% x (1/30) = 333.33 -> 333
      expect(interest.round(), 333);
    });
  });
}

String _frequency(String serverValue) => switch (serverValue) {
      'daily' => 'Daily',
      'weekly' => 'Weekly',
      'monthly' => 'Monthly',
      'yearly' => 'Yearly',
      _ => 'Monthly',
    };
