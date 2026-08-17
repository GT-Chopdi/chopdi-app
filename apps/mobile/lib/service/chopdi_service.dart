// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/service/isar_service.dart';

// class ChopdiService {
//   static Future<Chopdi> createChopdi(String name) async {
//     final chopdi = Chopdi()
//       ..name = name.trim()
//       ..createdAt = DateTime.now();

//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.chopdis.put(chopdi);
//     });

//     return chopdi;
//   }

//   static Future<List<Chopdi>> getAllChopdis() async {
//     return await IsarService.isar.chopdis
//         .where()
//         .sortByCreatedAt()
//         .findAll();
//   }

//   static Future<Chopdi?> getChopdi(int id) async {
//     return await IsarService.isar.chopdis.get(id);
//   }
// }

// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/service/isar_service.dart';

// class ChopdiService {

//   /// Returns the current Chopdi.
//   ///
//   /// If no Chopdi exists, automatically creates
//   /// "My Chopdi".
//   static Future<Chopdi> getCurrentChopdi() async {
//     final chopdis = await IsarService.isar.chopdis
//         .where()
//         .sortByCreatedAt()
//         .findAll();

//     if (chopdis.isEmpty) {
//       final defaultChopdi = Chopdi()
//         ..name = "My Chopdi"
//         ..createdAt = DateTime.now();

//       await IsarService.isar.writeTxn(() async {
//         await IsarService.isar.chopdis.put(defaultChopdi);
//       });

//       return defaultChopdi;
//     }

//     return chopdis.last;
//   }

//   /// Create a new Chopdi.
//   ///
//   /// Because it is created last, it becomes the
//   /// current Chopdi.
//   static Future<Chopdi> createChopdi(String name) async {
//     final chopdi = Chopdi()
//       ..name = name.trim()
//       ..createdAt = DateTime.now();

//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.chopdis.put(chopdi);
//     });

//     return chopdi;
//   }

//   static Future<List<Chopdi>> getAllChopdis() async {
//     return await IsarService.isar.chopdis
//         .where()
//         .sortByCreatedAt()
//         .findAll();
//   }

//   static Future<Chopdi?> getChopdi(int id) async {
//     return await IsarService.isar.chopdis.get(id);
//   }
// }