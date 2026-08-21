import '../../service/isar_service.dart';
import 'customer_repository.dart';
import 'ledger_repository.dart';

/// Access point for the repositories.
///
/// Static to match how the rest of the app already reaches Isar
/// (`IsarService.isar`), so wiring the UI to it is a one-line change per call
/// site rather than a dependency-injection refactor landing in the same release
/// as an irreversible data migration.
///
/// Instances are created lazily on first use because [IsarService.isar] is not
/// open until `main()` has run.
class Repositories {
  const Repositories._();

  static CustomerRepository? _customers;
  static LedgerRepository? _ledger;

  static CustomerRepository get customers =>
      _customers ??= CustomerRepository(IsarService.isar);

  static LedgerRepository get ledger =>
      _ledger ??= LedgerRepository(IsarService.isar);

  /// Drops the cached instances. Tests reopen Isar between cases, so a stale
  /// repository would hold a closed database.
  static void reset() {
    _customers = null;
    _ledger = null;
  }
}
