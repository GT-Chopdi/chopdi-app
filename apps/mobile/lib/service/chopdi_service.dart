import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';

class ChopdiService {
  static const String _activeChopdiKey = 'active_chopdi_id';

  static int? _activeChopdiId;

  /// Initialize Chopdi system.
  /// Creates "My Chopdi" the first time if no Chopdi exists.
  static Future<Chopdi> initialize() async {
    final allChopdis = await getAllChopdis();

    if (allChopdis.isEmpty) {
      // final defaultChopdi = Chopdi()
      //   ..name = "My Chopdi"
      //   ..createdAt = DateTime.now();
      final defaultChopdi = Chopdi()
        ..name = "My Chopdi"
        ..description =
            'My personal lending ledger\n'
            'to track loans and interest.'
        ..createdAt = DateTime.now();

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.chopdis.put(defaultChopdi);
      });

      _activeChopdiId = defaultChopdi.id;

      return defaultChopdi;
    }

    // If an active Chopdi is already selected and still exists.
    if (_activeChopdiId != null) {
      final active = await getChopdi(_activeChopdiId!);

      if (active != null) {
        return active;
      }
    }

    // First Chopdi becomes active.
    _activeChopdiId = allChopdis.first.id;

    return allChopdis.first;
  }

  /// Get all Chopdis created by the user.
  static Future<List<Chopdi>> getAllChopdis() async {
    return await IsarService.isar.chopdis
        .where()
        .sortByCreatedAt()
        .findAll();
  }

  /// Get current Chopdi.
  static Future<Chopdi> getCurrentChopdi() async {
    final allChopdis = await getAllChopdis();

    if (allChopdis.isEmpty) {
      final defaultChopdi = Chopdi()
        ..name = "My Chopdi"
        ..description =
            'My personal lending ledger\n'
            'to track loans and interest.'
        ..createdAt = DateTime.now();

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.chopdis.put(defaultChopdi);
      });

      _activeChopdiId = defaultChopdi.id;

      return defaultChopdi;
    }

    if (_activeChopdiId != null) {
      final active =
          await getChopdi(_activeChopdiId!);

      if (active != null) {
        return active;
      }
    }

    _activeChopdiId = allChopdis.first.id;

    return allChopdis.first;
  }

  /// Create new Chopdi.
  /// The newly created Chopdi becomes active.
  static Future<Chopdi> createChopdi(String name) async {
    final chopdi = Chopdi()
      ..name = name.trim()
      ..description =
          'My personal lending ledger\n'
          'to track loans and interest.'
      ..createdAt = DateTime.now();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });

    // New Chopdi becomes active
    _activeChopdiId = chopdi.id;

    return chopdi;
  }

  /// Switch to an existing Chopdi.
  static Future<void> setActiveChopdi(Chopdi chopdi) async {
    _activeChopdiId = chopdi.id;
  }

  static int? get activeChopdiId => _activeChopdiId;

  static Future<Chopdi?> getChopdi(int id) async {
    return await IsarService.isar.chopdis.get(id);
  }
}