import 'package:flutter_test/flutter_test.dart';
import 'package:mychopdi/data/repository/sync_payload.dart';
import 'package:mychopdi/model/transaction.dart';

/// The app has four transaction types; the server stores two independent
/// facts — which way the money moved, and whose ledger it belongs to.
///
/// The mapping is counterintuitive in both borrowing cases, which is exactly
/// why it is pinned here: `took` is money arriving, so its direction is
/// `received`, and `paid` is money leaving, so its direction is `gave`.
void main() {
  group('direction — which way the money moved', () {
    test('lending', () {
      expect(SyncPayload.direction(TransactionType.gave), 'gave');
      expect(SyncPayload.direction(TransactionType.received), 'received');
    });

    test('borrowing is the reverse of what the name suggests', () {
      // Taking a loan means money comes IN.
      expect(SyncPayload.direction(TransactionType.took), 'received');
      // Repaying means money goes OUT.
      expect(SyncPayload.direction(TransactionType.paid), 'gave');
    });

    test('only ever produces values the server accepts', () {
      // ledger_entry_direction_valid CHECK ("direction" IN ('gave','received'))
      for (final t in TransactionType.values) {
        expect(['gave', 'received'], contains(SyncPayload.direction(t)));
      }
    });
  });

  group('ledgerSide — whose book it belongs to', () {
    test('splits lending from borrowing', () {
      expect(SyncPayload.ledgerSide(TransactionType.gave), 'lent');
      expect(SyncPayload.ledgerSide(TransactionType.received), 'lent');
      expect(SyncPayload.ledgerSide(TransactionType.took), 'borrowed');
      expect(SyncPayload.ledgerSide(TransactionType.paid), 'borrowed');
    });

    test('only ever produces values the server accepts', () {
      for (final t in TransactionType.values) {
        expect(['lent', 'borrowed'], contains(SyncPayload.ledgerSide(t)));
      }
    });
  });

  group('round trip', () {
    test('every type survives a trip through the two server fields', () {
      // A pull must be able to rebuild the exact type, or re-downloading your
      // own data would quietly reclassify it.
      for (final t in TransactionType.values) {
        expect(
          SyncPayload.toType(
            SyncPayload.direction(t),
            SyncPayload.ledgerSide(t),
          ),
          t,
          reason: '$t did not survive the round trip',
        );
      }
    });
  });

  group('signed contribution to the net position', () {
    test('money out is positive, money in is negative', () {
      expect(SyncPayload.signedPaise(TransactionType.gave, 500000), 500000);
      expect(SyncPayload.signedPaise(TransactionType.received, 500000), -500000);
    });

    test('repaying a debt increases the net position', () {
      // The bug this replaces: `type == gave ? + : -` signed `paid` negative,
      // so repaying money you owed made the balance look worse.
      expect(SyncPayload.signedPaise(TransactionType.took, 500000), -500000);
      expect(SyncPayload.signedPaise(TransactionType.paid, 500000), 500000);
    });

    test('a borrow followed by full repayment nets to zero', () {
      const amount = 250000;
      final net = SyncPayload.signedPaise(TransactionType.took, amount) +
          SyncPayload.signedPaise(TransactionType.paid, amount);

      expect(net, 0);
    });

    test('a loan followed by full repayment nets to zero', () {
      const amount = 250000;
      final net = SyncPayload.signedPaise(TransactionType.gave, amount) +
          SyncPayload.signedPaise(TransactionType.received, amount);

      expect(net, 0);
    });
  });
}
