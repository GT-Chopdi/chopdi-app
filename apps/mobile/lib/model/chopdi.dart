
import 'package:isar_community/isar.dart';

import 'sync_status.dart';

part 'chopdi.g.dart';

@collection
class Chopdi {
/// Local Isar ID.
/// Never assign the server's UUID to this field.
Id id = Isar.autoIncrement;

/// Server Chopdi UUID from the API response's `id` field.
@Index()
String uuid = '';

/// Chopdi name from the API response.
late String name;

/// Chopdi description from the API response.
String description =
'My personal lending ledger\n'
'to track loans and interest.';

/// Whether this is the default Chopdi on the server.
bool isDefault = false;

/// Local-only field: tracks the currently selected Chopdi.
/// This field is not provided by the API.
bool isActive = false;

/// Creation timestamp from the API's `createdAt` field.
late DateTime createdAt;

/// Server version used for synchronization.
int version = 0;

/// Last server update timestamp.
DateTime updatedAt = DateTime.utc(1970);

/// Soft deletion timestamp. Null means not deleted.
DateTime? deletedAt;

/// Local synchronization state.
@enumerated
SyncStatus syncStatus = SyncStatus.pending;
}