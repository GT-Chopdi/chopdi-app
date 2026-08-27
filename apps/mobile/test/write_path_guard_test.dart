import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the single-write-path rule.
///
/// The repository is only worth having if nothing goes around it. A write that
/// bypasses it never reaches the outbox, so the row lives on the device and
/// silently never syncs — no error, no pending indicator, just data the server
/// has never heard of. That failure is invisible until someone loses a phone.
///
/// The allowlist holds exactly one entry, and every addition needs a reason.
/// A new file writing to Isar outside the repository fails this test with an
/// explanation, instead of quietly reintroducing the problem months later.
void main() {
  // Every remaining offender, to be emptied as each is migrated.
  const knownDirectWriters = <String>{
    // The one legitimate exception. The migration converts every existing row
    // in a single transaction and seeds the outbox itself, so it cannot call
    // repository methods that would each open their own transaction and mint a
    // fresh identity. It is a one-time bulk conversion, covered by
    // test/local_migration_test.dart.
    'lib/data/migration/local_migration.dart',

    // Arrived with the borrowing feature and still writes to Isar directly, so
    // nothing it saves reaches the outbox — those entries live on the device
    // and silently never sync. It must move to the repository before borrowing
    // ships. Listed rather than ignored so the debt is visible.
    //
    // The two lender-creation screens that used to sit here have been migrated:
    // writing a customer without the repository left it with no uuid, which
    // LedgerRepository refuses, so every entry added to such a lender failed
    // silently.
    'lib/view/took_loan_customer_details_screen.dart',

    // The sync layer itself. It applies what the server has already accepted —
    // marking rows synced, storing the version the server assigned — and those
    // writes must *not* enqueue anything: an acknowledgement that queued a
    // fresh operation would sync forever in a loop. Covered by
    // test/sync_engine_test.dart.
    'lib/data/sync/sync_engine.dart',

    // Both call `Repositories.ledger.update` first — the synced fields go
    // through the repository correctly — and then write `Transaction.interest`,
    // a value derived locally from principal, rate and dates. It is absent from
    // `_payloadFor`, so nothing the server stores is lost here. Allowed on that
    // basis alone: the moment either writes a field that *is* in the payload,
    // the change stops syncing with no error to show for it.
    'lib/view/edit_transaction_bottom_sheet.dart',
    'lib/widgets/edit_transaction_details.dart',
  };

  final writePattern = RegExp(
    r'(customers|transactions)\s*\.\s*(put|delete|clear)\b',
  );

  test('no new code writes to Isar outside the repository', () {
    final offenders = <String>{};

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;
      if (entity.path.startsWith('lib/data/repository/')) continue;

      final source = entity.readAsStringSync();

      // Ignore commented-out lines — this codebase keeps a lot of history in
      // comments, and flagging it would make the guard noise rather than signal.
      final live = source
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');

      if (writePattern.hasMatch(live)) offenders.add(entity.path);
    }

    final unexpected = offenders.difference(knownDirectWriters);

    expect(
      unexpected,
      isEmpty,
      reason: '\nThese files write to Isar outside the repository:\n'
          '${unexpected.map((f) => '  - $f').join('\n')}\n\n'
          'Route the write through CustomerRepository or LedgerRepository so it '
          'is enqueued for sync in the same transaction. If the write genuinely '
          'must bypass sync, add the file to knownDirectWriters with a comment '
          'saying why.',
    );
  });

  test('the ratchet does not list files that are already clean', () {
    // Keeps the list honest: once a file is migrated it must be removed, or the
    // guard slowly turns into a permanent allowlist that protects nothing.
    final stale = <String>{};

    for (final path in knownDirectWriters) {
      final file = File(path);
      if (!file.existsSync()) {
        stale.add('$path (missing)');
        continue;
      }
      final live = file
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      if (!writePattern.hasMatch(live)) stale.add('$path (already clean)');
    }

    expect(stale, isEmpty,
        reason: '\nRemove these from knownDirectWriters:\n'
            '${stale.map((f) => '  - $f').join('\n')}');
  });
}
