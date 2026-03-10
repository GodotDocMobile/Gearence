import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/translation_deletage.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart'; // Import your new delegate file

extension ContextExt on BuildContext {
  String translate(String key) {
    if (key.isEmpty) return "";

    // 1. Get the localization instance
    final loc = GearenceLocalizations.of(this);
    if (loc == null) return key;

    // 2. Return the translation or the original English key as a fallback
    return loc.translate(key);
  }
}

Map<String, String> batchTranslate(List<String> keys) {
  Map<String, String> _translationCache = {};
  final docIsar = GetIt.I<Isar>(instanceName: MetadataKeys.docsIsarKey);
  final currentLocale = GetIt.I<SettingsRepository>().getTranslation();

  // 2. Perform ONE async Isar query to find all matching msgids
  final results = docIsar.translations
      .where()
      .anyOf(keys, (q, String key) => q.msgidEqualTo(key))
      .findAll();

  // // 3. Map them for instant O(1) lookup in the UI
  // setState(() {
  for (var r in results) {
    _translationCache[r.msgid!] = r.getTranslation(currentLocale.stringValue!);
  }

  return _translationCache;
  // });
}
