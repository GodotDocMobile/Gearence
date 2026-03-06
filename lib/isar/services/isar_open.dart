import 'dart:io';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart' as p;

Future<Isar> openIsarSafe({
  required List<IsarGeneratedSchema> schemas,
  required String directory,
  String name = 'default',
  bool inspector = false,
  Future<void> Function()? onRecoveryNeeded, // Your new callback
}) async {
  try {
    // 1. Attempt to open normally
    return Isar.open(
      schemas: schemas,
      directory: directory,
      name: name,
      inspector: inspector,
    );
  } catch (e) {
    // 2. Check if it's a schema or database error
    print('⚠️ Isar open failed, likely a version mismatch: $e');

    // 3. Define the file paths
    // Isar files are stored as [name].isar and [name].isar.lock
    final dbFile = File(p.join(directory, '$name.isar'));
    final lockFile = File(p.join(directory, '$name.isar.lock'));

    // 4. Delete the corrupted/old files
    if (dbFile.existsSync()) {
      await dbFile.delete();
      print('🗑️ Deleted old .isar file');
    }
    if (lockFile.existsSync()) {
      await lockFile.delete();
      print('🗑️ Deleted old .lock file');
    }

    // 3. Trigger your callback to copy the "fresh" isar file from assets
    if (onRecoveryNeeded != null) {
      print('📂 Executing recovery callback (copying asset bundle)...');
      await onRecoveryNeeded();
    }

    // 5. Try opening again (this will create a fresh v1.1.0 database)
    return Isar.open(
      schemas: schemas,
      directory: directory,
      name: name,
      inspector: inspector,
    );
  }
}
