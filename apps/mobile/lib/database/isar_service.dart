// import 'package:flutter/widgets.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';


// class IsarService {
//   static late Isar isar;

//   static Future<void> initialize() async {
//     WidgetsFlutterBinding.ensureInitialized();

//     final dir = await getApplicationDocumentsDirectory();

//     isar = await Isar.open(
//       [
//         ChopdiSchema,
//         CustomerSchema,
//       ],
//       directory: dir.path,
//     );
//   }
// }