import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';

class ChopdiService {
  // ===========================================================================
  // DEFAULT VALUES
  // ===========================================================================

  static const String defaultChopdiName = 'My Chopdi';

  static const String defaultDescription =
      'My personal lending ledger\n'
      'to track loans and interest.';

  // ===========================================================================
  // INITIALIZE
  // ===========================================================================

  static Future<Chopdi> initialize() async {
    final allChopdis = await getAllChopdis();

    // -------------------------------------------------------------------------
    // NO CHOPDI EXISTS
    // -------------------------------------------------------------------------

    if (allChopdis.isEmpty) {
      return await _createDefaultChopdi();
    }

    // -------------------------------------------------------------------------
    // FIND PERSISTED ACTIVE CHOPDI
    // -------------------------------------------------------------------------

    final activeChopdis =
        allChopdis.where((chopdi) => chopdi.isActive).toList();

    if (activeChopdis.isNotEmpty) {
      return activeChopdis.first;
    }

    // -------------------------------------------------------------------------
    // FALLBACK
    // -------------------------------------------------------------------------

    return await setActiveChopdi(allChopdis.first);
  }

  // ===========================================================================
  // CREATE DEFAULT CHOPDI
  // ===========================================================================

  static Future<Chopdi> _createDefaultChopdi() async {
    final defaultChopdi = Chopdi()
      ..name = defaultChopdiName
      ..description = defaultDescription
      ..createdAt = DateTime.now()
      ..isActive = true;

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(defaultChopdi);
    });

    return defaultChopdi;
  }

  // ===========================================================================
  // GET ALL CHOPDIS
  // ===========================================================================

  static Future<List<Chopdi>> getAllChopdis() async {
    return await IsarService.isar.chopdis
        .where()
        .sortByCreatedAt()
        .findAll();
  }

  // ===========================================================================
  // GET CURRENT CHOPDI
  // ===========================================================================

  static Future<Chopdi> getCurrentChopdi() async {
    final allChopdis = await getAllChopdis();

    // -------------------------------------------------------------------------
    // NO CHOPDI
    // -------------------------------------------------------------------------

    if (allChopdis.isEmpty) {
      return await _createDefaultChopdi();
    }

    // -------------------------------------------------------------------------
    // FIND SAVED ACTIVE CHOPDI
    // -------------------------------------------------------------------------

    final activeChopdis =
        allChopdis.where((chopdi) => chopdi.isActive).toList();

    if (activeChopdis.isNotEmpty) {
      return activeChopdis.first;
    }

    // -------------------------------------------------------------------------
    // FALLBACK
    // -------------------------------------------------------------------------

    return await setActiveChopdi(allChopdis.first);
  }

  // ===========================================================================
  // CREATE NEW CHOPDI
  // ===========================================================================

  static Future<Chopdi> createChopdi(
    String name, {
    String? description,
  }) async {
    final chopdi = Chopdi()
      ..name = name.trim()
      ..description =
          description?.trim().isNotEmpty == true
              ? description!.trim()
              : defaultDescription
      ..createdAt = DateTime.now()
      ..isActive = false;

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });

    // Newly created Chopdi becomes active.
    await setActiveChopdi(chopdi);

    return chopdi;
  }

  // ===========================================================================
  // UPDATE CHOPDI
  // ===========================================================================

  static Future<Chopdi> updateChopdi({
    required int id,
    required String name,
    required String description,
  }) async {
    final chopdi = await getChopdi(id);

    if (chopdi == null) {
      throw Exception('Chopdi not found.');
    }

    chopdi
      ..name = name.trim()
      ..description =
          description.trim().isEmpty
              ? defaultDescription
              : description.trim();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });

    return chopdi;
  }

  // ===========================================================================
  // SET ACTIVE CHOPDI
  // ===========================================================================

  static Future<Chopdi> setActiveChopdi(
    Chopdi selectedChopdi,
  ) async {
    await IsarService.isar.writeTxn(() async {
      // First deactivate all Chopdis.
      final allChopdis = await IsarService.isar.chopdis
          .where()
          .findAll();

      for (final chopdi in allChopdis) {
        chopdi.isActive = chopdi.id == selectedChopdi.id;

        await IsarService.isar.chopdis.put(chopdi);
      }
    });

    return selectedChopdi;
  }

  // ===========================================================================
  // GET ACTIVE CHOPDI
  // ===========================================================================

  static Future<Chopdi?> getActiveChopdi() async {
    final activeChopdis = await IsarService.isar.chopdis
        .filter()
        .isActiveEqualTo(true)
        .findAll();

    if (activeChopdis.isEmpty) {
      return null;
    }

    return activeChopdis.first;
  }

  // ===========================================================================
  // GET CHOPDI
  // ===========================================================================

  static Future<Chopdi?> getChopdi(int id) async {
    return await IsarService.isar.chopdis.get(id);
  }

  // ===========================================================================
  // UPDATE CHOPDI
  // ===========================================================================

  static Future<void> updatedChopdi(Chopdi chopdi) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });
  }

  // ===========================================================================
  // DELETE CHOPDI
  // ===========================================================================

  static Future<Chopdi> deleteChopdi(
    int chopdiId,
  ) async {
    final allChopdis = await getAllChopdis();

    final chopdiToDelete = await getChopdi(chopdiId);

    if (chopdiToDelete == null) {
      throw Exception('Chopdi not found.');
    }

    // -------------------------------------------------------------------------
    // ONLY ONE CHOPDI
    // -------------------------------------------------------------------------

    if (allChopdis.length == 1) {
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.chopdis.delete(chopdiId);
      });

      return await _createDefaultChopdi();
    }

    // -------------------------------------------------------------------------
    // MULTIPLE CHOPDIS
    // -------------------------------------------------------------------------

    final remainingChopdis = allChopdis
        .where((chopdi) => chopdi.id != chopdiId)
        .toList();

    final deletedIndex = allChopdis.indexWhere(
      (chopdi) => chopdi.id == chopdiId,
    );

    Chopdi nextActiveChopdi;

    if (deletedIndex >= 0 &&
        deletedIndex + 1 < allChopdis.length) {
      nextActiveChopdi = allChopdis[deletedIndex + 1];
    } else {
      nextActiveChopdi = remainingChopdis.first;
    }

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.delete(chopdiId);
    });

    return await setActiveChopdi(nextActiveChopdi);
  }
}