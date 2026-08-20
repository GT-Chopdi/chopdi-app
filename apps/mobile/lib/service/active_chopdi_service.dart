import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/service/isar_service.dart';

class ActiveChopdiService {
  static const int defaultChopdiId = 1;

  /// Get currently active Chopdi.
  static Future<Chopdi> getActiveChopdi() async {
    final chopdis = await IsarService.isar.chopdis
        .where()
        .sortByCreatedAt()
        .findAll();

    // First time app is used.
    if (chopdis.isEmpty) {
      final chopdi = Chopdi()
        ..name = "My Chopdi"
        ..createdAt = DateTime.now();

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.chopdis.put(chopdi);
      });

      return chopdi;
    }

    // For now, latest created Chopdi is active.
    return chopdis.last;
  }

  /// Create a new Chopdi and make it active.
  static Future<Chopdi> createAndActivate(String name) async {
    final chopdi = Chopdi()
      ..name = name.trim()
      ..createdAt = DateTime.now();

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.chopdis.put(chopdi);
    });

    return chopdi;
  }
}