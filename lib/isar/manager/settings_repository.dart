import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
import 'package:isar_plus/isar_plus.dart';

class SettingsRepository {
  final Isar prefsIsar;

  SettingsRepository(this.prefsIsar);

  UserSetting? get(String key) {
    return prefsIsar.userSettings.where().keyEqualTo(key).findFirst();
  }

  Future saveSettings(UserSetting setting) async {
    UserSetting record;
    if (setting.id == -1) {
      record = UserSetting(id: prefsIsar.userSettings.autoIncrement())
        ..key = setting.key
        ..boolValue = setting.boolValue
        ..intValue = setting.intValue
        ..stringValue = setting.stringValue;
    } else {
      record = setting;
    }
    await prefsIsar.writeAsync((isar) {
      isar.userSettings.put(record);
    });
  }

  UserSetting getIsDarkMode() {
    var darkModeRecord = get(MetadataKeys.isDarkMode);
    darkModeRecord ??= UserSetting(id: -1)
      ..boolValue = false
      ..key = MetadataKeys.isDarkMode;
    return darkModeRecord;
  }

  UserSetting getTranslation() {
    var languageRecord = get(MetadataKeys.translation);
    languageRecord ??= UserSetting(id: -1)
      ..stringValue = 'en'
      ..key = MetadataKeys.translation;
    return languageRecord;
  }

  UserSetting getGodotVersion() {
    var versionRecord = get(MetadataKeys.version);
    versionRecord ??= UserSetting(id: -1)
      ..stringValue = godotVersions.last
      ..key = MetadataKeys.version;
    return versionRecord;
  }

  UserSetting getLocalDBVersion(String godotVersion) {
    var dbVersionRecord = get(MetadataKeys.getDocVersionKey(godotVersion));
    dbVersionRecord ??= UserSetting(id: -1)
      ..stringValue = '0'
      ..key = MetadataKeys.getDocVersionKey(godotVersion);
    return dbVersionRecord;
  }

  UserSetting getFontSize() {
    var dbFontSizeRecord = get(MetadataKeys.fontSize);
    dbFontSizeRecord ??= UserSetting(id: -1)
      ..intValue = 0
      ..key = MetadataKeys.fontSize;
    return dbFontSizeRecord;
  }

  UserSetting getMonospace() {
    var record = get(MetadataKeys.monoSpaceFont);
    record ??= UserSetting(id: -1)
      ..boolValue = false
      ..key = MetadataKeys.monoSpaceFont;
    return record;
  }

  // /// Adds a document to the history or updates its timestamp if it exists
  // Future<void> addToHistory(DocEntry doc) async {
  //   await _prefsIsar.write((isar) {
  //     // 1. Put the new/updated entry
  //     isar.historyEntrys.put(
  //       HistoryEntry(id: isar.userSettings.autoIncrement())
  //         ..docId = doc.docId!
  //         ..title = doc.title
  //         ..emoji = doc.emoji
  //         ..summary = doc.summary
  //         ..lastViewed = DateTime.now(),
  //     );

  //     // 2. Maintain only the last 5 entries
  //     final allHistory = isar.historyEntrys
  //         .where()
  //         .sortByLastViewedDesc()
  //         .findAll();

  //     if (allHistory.length > 5) {
  //       final idsToDelete = allHistory.sublist(5).map((e) => e.id).toList();
  //       isar.historyEntrys.deleteAll(idsToDelete);
  //     }
  //   });
  // }

  // /// Fetches the 5 most recent docs for the Home Screen
  // List<HistoryEntry> getRecentDocs() {
  //   return _prefsIsar.historyEntrys.where().sortByLastViewedDesc().findAll(
  //     limit: 5,
  //   );
  // }

  // void clearRecentlyViewed() {
  //   _prefsIsar.write((isar) {
  //     isar.historyEntrys.clear();
  //   });
  // }

  // // Inside your DocSeed screen or your main bootstrap logic
  // static Future<void> runStartupSanitySweep() async {
  //   final prefsIsar = GetIt.instance<Isar>(
  //     instanceName: MetadataKeys.preferenceIsarKey,
  //   );
  //   final docsIsar = GetIt.instance<Isar>(
  //     instanceName: MetadataKeys.docsIsarKey,
  //   );

  //   // 1. Get all docIds currently in history
  //   final historyEntries = prefsIsar.historyEntrys.where().findAll();
  //   if (historyEntries.isEmpty) return;

  //   // 2. Efficiently find which ones are missing from the Doc DB
  //   final List<int> staleIds = [];

  //   for (final entry in historyEntries) {
  //     final exists =
  //         docsIsar.docEntrys.where().docIdEqualTo(entry.docId).findFirst() !=
  //         null;

  //     if (!exists) {
  //       staleIds.add(entry.id);
  //     }
  //   }

  //   // 3. Batch delete all orphans in one trip
  //   if (staleIds.isNotEmpty) {
  //     await prefsIsar.writeAsync((isar) async {
  //       isar.historyEntrys.deleteAll(staleIds);
  //     });
  //     debugPrint(
  //       "🧹 Startup Sweep: Removed ${staleIds.length} orphan history entries.",
  //     );
  //   }
  // }

  Stream<void> watchSetting(String key) {
    return prefsIsar.userSettings.where().keyEqualTo(key).watchLazy();
  }

  Stream<void> watchAllSettings() {
    return prefsIsar.userSettings.watchLazy(fireImmediately: true);
  }

  void seedDefaultSettings() {
    final defaults = {
      MetadataKeys.version: storedValues.version,
      MetadataKeys.isDarkMode: storedValues.isDarkTheme,
      MetadataKeys.fontSize: storedValues.fontSize,
      MetadataKeys.monoSpaceFont: storedValues.isMonospaced,
      MetadataKeys.translation: storedValues.translation
    };

    prefsIsar.write((isar) {
      for (var entry in defaults.entries) {
        final exists =
            prefsIsar.userSettings.where().keyEqualTo(entry.key).findFirst();

        if (exists == null) {
          prefsIsar.userSettings.put(
            UserSetting(id: prefsIsar.userSettings.autoIncrement())
              ..key = entry.key
              ..intValue = entry.value is int ? entry.value as int : null
              ..boolValue = entry.value is bool ? entry.value as bool : null
              ..stringValue =
                  entry.value is String ? entry.value as String : null,
          );
        }
      }
    });
  }
}
