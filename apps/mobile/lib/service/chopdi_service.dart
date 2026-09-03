// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/service/isar_service.dart';

// class ChopdiService {
//   static const String _activeChopdiKey = 'active_chopdi_id';

//   static int? _activeChopdiId;

//   /// Initialize Chopdi system.
//   /// Creates "My Chopdi" the first time if no Chopdi exists.
//   static Future<Chopdi> initialize() async {
//     final allChopdis = await getAllChopdis();

//     if (allChopdis.isEmpty) {
//       // final defaultChopdi = Chopdi()
//       //   ..name = "My Chopdi"
//       //   ..createdAt = DateTime.now();
//       final defaultChopdi = Chopdi()
//         ..name = "My Chopdi"
//         ..description =
//             'My personal lending ledger\n'
//             'to track loans and interest.'
//         ..createdAt = DateTime.now();

//       await IsarService.isar.writeTxn(() async {
//         await IsarService.isar.chopdis.put(defaultChopdi);
//       });

//       _activeChopdiId = defaultChopdi.id;

//       return defaultChopdi;
//     }

//     // If an active Chopdi is already selected and still exists.
//     if (_activeChopdiId != null) {
//       final active = await getChopdi(_activeChopdiId!);

//       if (active != null) {
//         return active;
//       }
//     }

//     // First Chopdi becomes active.
//     _activeChopdiId = allChopdis.first.id;

//     return allChopdis.first;
//   }

//   /// Get all Chopdis created by the user.
//   static Future<List<Chopdi>> getAllChopdis() async {
//     return await IsarService.isar.chopdis
//         .where()
//         .sortByCreatedAt()
//         .findAll();
//   }

//   /// Get current Chopdi.
//   static Future<Chopdi> getCurrentChopdi() async {
//     final allChopdis = await getAllChopdis();

//     if (allChopdis.isEmpty) {
//       final defaultChopdi = Chopdi()
//         ..name = "My Chopdi"
//         ..description =
//             'My personal lending ledger\n'
//             'to track loans and interest.'
//         ..createdAt = DateTime.now();

//       await IsarService.isar.writeTxn(() async {
//         await IsarService.isar.chopdis.put(defaultChopdi);
//       });

//       _activeChopdiId = defaultChopdi.id;

//       return defaultChopdi;
//     }

//     if (_activeChopdiId != null) {
//       final active =
//           await getChopdi(_activeChopdiId!);

//       if (active != null) {
//         return active;
//       }
//     }

//     _activeChopdiId = allChopdis.first.id;

//     return allChopdis.first;
//   }

//   /// Create new Chopdi.
//   /// The newly created Chopdi becomes active.
//   static Future<Chopdi> createChopdi(String name) async {
//     final chopdi = Chopdi()
//       ..name = name.trim()
//       ..description =
//           'My personal lending ledger\n'
//           'to track loans and interest.'
//       ..createdAt = DateTime.now();

//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.chopdis.put(chopdi);
//     });

//     // New Chopdi becomes active
//     _activeChopdiId = chopdi.id;

//     return chopdi;
//   }

//   /// Switch to an existing Chopdi.
//   static Future<void> setActiveChopdi(Chopdi chopdi) async {
//     _activeChopdiId = chopdi.id;
//   }

//   static int? get activeChopdiId => _activeChopdiId;

//   static Future<Chopdi?> getChopdi(int id) async {
//     return await IsarService.isar.chopdis.get(id);
//   }
// }

import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';

class ChopdiService {
  static int? _activeChopdiId;

  // ===========================================================================
  // DEFAULT VALUES
  // ===========================================================================

  static const String defaultChopdiName =
      'My Chopdi';

  static const String defaultDescription =
      'My personal lending ledger\n'
      'to track loans and interest.';

  // ===========================================================================
  // INITIALIZE
  // ===========================================================================

  static Future<Chopdi> initialize() async {
    final allChopdis = await getAllChopdis();

    // ---------------------------------------------------------------
    // NO CHOPDI EXISTS
    // ---------------------------------------------------------------

    if (allChopdis.isEmpty) {
      return await _createDefaultChopdi();
    }

    // ---------------------------------------------------------------
    // CURRENT ACTIVE CHOPDI STILL EXISTS
    // ---------------------------------------------------------------

    if (_activeChopdiId != null) {
      final active =
          await getChopdi(_activeChopdiId!);

      if (active != null) {
        return active;
      }
    }

    // ---------------------------------------------------------------
    // FALLBACK TO FIRST CHOPDI
    // ---------------------------------------------------------------

    _activeChopdiId =
        allChopdis.first.id;

    return allChopdis.first;
  }

  // ===========================================================================
  // CREATE DEFAULT CHOPDI
  // ===========================================================================

  static Future<Chopdi> _createDefaultChopdi() async {
    final defaultChopdi = Chopdi()
      ..name = defaultChopdiName
      ..description = defaultDescription
      ..createdAt = DateTime.now();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(
        defaultChopdi,
      );
    });

    _activeChopdiId =
        defaultChopdi.id;

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
    final allChopdis =
        await getAllChopdis();

    // ---------------------------------------------------------------
    // NO CHOPDI
    // ---------------------------------------------------------------

    if (allChopdis.isEmpty) {
      return await _createDefaultChopdi();
    }

    // ---------------------------------------------------------------
    // ACTIVE CHOPDI
    // ---------------------------------------------------------------

    if (_activeChopdiId != null) {
      final active =
          await getChopdi(
        _activeChopdiId!,
      );

      if (active != null) {
        return active;
      }
    }

    // ---------------------------------------------------------------
    // FALLBACK
    // ---------------------------------------------------------------

    _activeChopdiId =
        allChopdis.first.id;

    return allChopdis.first;
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
      ..createdAt = DateTime.now();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(
        chopdi,
      );
    });

    // Newly created Chopdi becomes active.
    _activeChopdiId =
        chopdi.id;

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
    final chopdi =
        await getChopdi(id);

    if (chopdi == null) {
      throw Exception(
        'Chopdi not found.',
      );
    }

    chopdi
      ..name = name.trim()
      ..description =
          description.trim().isEmpty
              ? defaultDescription
              : description.trim();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(
        chopdi,
      );
    });

    return chopdi;
  }

  // ===========================================================================
  // SET ACTIVE CHOPDI
  // ===========================================================================

  static Future<void> setActiveChopdi(
    Chopdi chopdi,
  ) async {
    _activeChopdiId =
        chopdi.id;
  }

  // ===========================================================================
  // ACTIVE CHOPDI ID
  // ===========================================================================

  static int? get activeChopdiId =>
      _activeChopdiId;

  static Future<void> updatedChopdi(Chopdi chopdi) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });
  }

  // ===========================================================================
  // GET CHOPDI
  // ===========================================================================

  static Future<Chopdi?> getChopdi(
    int id,
  ) async {
    return await IsarService.isar.chopdis.get(
      id,
    );
  }

  // ===========================================================================
  // DELETE CHOPDI
  // ===========================================================================

  /// Deletes the requested Chopdi.
  ///
  /// Returns:
  ///
  /// - [remainingChopdis] if other Chopdis exist.
  /// - A newly created default Chopdi if the deleted Chopdi was the only one.
  ///
  /// This method also updates the active Chopdi.
  // static Future<Chopdi> deleteChopdi(
  //   int chopdiId,
  // ) async {
  //   final allChopdis =
  //       await getAllChopdis();

  //   // ---------------------------------------------------------------
  //   // FIND CHOPDI
  //   // ---------------------------------------------------------------

  //   final chopdiToDelete =
  //       await getChopdi(chopdiId);

  //   if (chopdiToDelete == null) {
  //     throw Exception(
  //       'Chopdi not found.',
  //     );
  //   }

  //   // ---------------------------------------------------------------
  //   // CASE 1:
  //   // ONLY ONE CHOPDI EXISTS
  //   // ---------------------------------------------------------------

  //   if (allChopdis.length == 1) {
  //     await IsarService.isar.writeTxn(() async {
  //       await IsarService.isar.chopdis.delete(
  //         chopdiId,
  //       );
  //     });

  //     // -------------------------------------------------------------
  //     // IMPORTANT:
  //     // Always keep one default Chopdi available.
  //     // -------------------------------------------------------------

  //     return await _createDefaultChopdi();
  //   }

  //   // ---------------------------------------------------------------
  //   // CASE 2:
  //   // MULTIPLE CHOPDIS EXIST
  //   // ---------------------------------------------------------------

  //   // Find another Chopdi before deleting.
  //   final remainingChopdis =
  //       allChopdis
  //           .where(
  //             (chopdi) =>
  //                 chopdi.id != chopdiId,
  //           )
  //           .toList();

  //   // Prefer the next Chopdi after the deleted one.
  //   Chopdi nextActiveChopdi;

  //   final deletedIndex =
  //       allChopdis.indexWhere(
  //     (chopdi) =>
  //         chopdi.id == chopdiId,
  //   );

  //   if (deletedIndex >= 0 &&
  //       deletedIndex + 1 <
  //           allChopdis.length) {
  //     nextActiveChopdi =
  //         allChopdis[
  //             deletedIndex + 1];
  //   } else {
  //     nextActiveChopdi =
  //         remainingChopdis.first;
  //   }

  //   // ---------------------------------------------------------------
  //   // DELETE ONLY SELECTED CHOPDI
  //   // ---------------------------------------------------------------

  //   await IsarService.isar.writeTxn(() async {
  //     await IsarService.isar.chopdis.delete(
  //       chopdiId,
  //     );
  //   });

  //   // ---------------------------------------------------------------
  //   // MAKE ANOTHER CHOPDI ACTIVE
  //   // ---------------------------------------------------------------

  //   _activeChopdiId =
  //       nextActiveChopdi.id;

  //   return nextActiveChopdi;
  // }
  static Future<Chopdi> deleteChopdi(
  int chopdiId,
) async {
  final allChopdis =
      await getAllChopdis();

  final chopdiToDelete =
      await getChopdi(chopdiId);

  if (chopdiToDelete == null) {
    throw Exception(
      'Chopdi not found.',
    );
  }

  // ============================================================
  // ONLY ONE CHOPDI
  // ============================================================

  if (allChopdis.length == 1) {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.delete(
        chopdiId,
      );
    });

    // Create default Chopdi again.
    return await _createDefaultChopdi();
  }

  // ============================================================
  // MULTIPLE CHOPDIS
  // ============================================================

  final remainingChopdis =
      allChopdis
          .where(
            (chopdi) =>
                chopdi.id != chopdiId,
          )
          .toList();

  final deletedIndex =
      allChopdis.indexWhere(
    (chopdi) =>
        chopdi.id == chopdiId,
  );

  Chopdi nextActiveChopdi;

  if (deletedIndex >= 0 &&
      deletedIndex + 1 <
          allChopdis.length) {
    nextActiveChopdi =
        allChopdis[
            deletedIndex + 1];
  } else {
    nextActiveChopdi =
        remainingChopdis.first;
  }

  await IsarService.isar.writeTxn(() async {
    await IsarService.isar.chopdis.delete(
      chopdiId,
    );
  });

  _activeChopdiId =
      nextActiveChopdi.id;

  return nextActiveChopdi;
}
}