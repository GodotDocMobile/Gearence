import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
import 'package:isar_plus/isar_plus.dart';

class SettingsRepository {
  final Isar prefsIsar;

  SettingsRepository(this.prefsIsar);

  UserSetting? get(String key) {
    return prefsIsar.userSettings.where().keyEqualTo(key).findFirst();
  }

  void saveSettings(UserSetting setting) {
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
    prefsIsar.write((isar) {
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

  // Logic for your settingsRepo
  UserSetting getEnabledNodeTypes() {
    // Assuming you store this as a comma-separated string or a bitmask
    var setting = get(MetadataKeys.enabledNodeFilters);
    setting ??= UserSetting(id: -1)
      ..stringValue =
          classNodeType.values.map((e) => e.index).toList().join(',')
      ..key = MetadataKeys.enabledNodeFilters;
    return setting;
  }

  Stream<void> watchSetting(String key) {
    return prefsIsar.userSettings
        .where()
        .keyEqualTo(key)
        .watchLazy()
        .asBroadcastStream();
  }

  Stream<void> watchAllSettings() {
    return prefsIsar.userSettings
        .watchLazy(fireImmediately: true)
        .asBroadcastStream();
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
