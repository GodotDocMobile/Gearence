import 'dart:io';

import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart';

List<String> processTranslations(String godotPath, Isar isar) {
  final languages = <String>[];
  final translationFolderPath = join(godotPath, 'doc/translations');
  final translationDir = Directory(translationFolderPath);

  if (!translationDir.existsSync()) return languages;

  final poFiles = translationDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.po'));

  for (var file in poFiles) {
    final locale = basenameWithoutExtension(file.path);
    languages.add(locale);

    print("Parsing $locale...");
    final Map<String, String> newTranslations = parsePoFile(file.path);

    // 1. Pull existing translations into a Map for O(1) lookup
    final allExisting = isar.translations.where().findAll();
    final Map<String, Translation> cache = {
      for (var t in allExisting) t.msgid!: t
    };

    // 2. Process in RAM
    for (var entry in newTranslations.entries) {
      final msgid = entry.key;
      final msgstr = entry.value;

      if (cache.containsKey(msgid)) {
        // Update existing object in RAM
        cache[msgid]!.translations ??= [];
        cache[msgid]!.translations!.add(LocaleString()
          ..locale = locale
          ..value = msgstr);
      } else {
        // Create new object in RAM
        cache[msgid] = Translation(id: isar.translations.autoIncrement())
          ..msgid = msgid
          ..translations = [
            LocaleString()
              ..locale = locale
              ..value = msgstr
          ];
      }
    }

    // 3. ONE big transaction per file
    print("Writing $locale to Isar...");
    isar.write((isar) {
      isar.translations.putAll(cache.values.toList());
    });
  }

  return languages;
}

Map<String, String> parsePoFile(String filePath) {
  final Map<String, String> translations = {};
  final file = File(filePath);
  if (!file.existsSync()) return translations;

  final lines = file.readAsLinesSync();

  String currentId = "";
  String currentStr = "";
  String state = "IDLE"; // States: IDLE, ID, STR

  void commit() {
    if (currentId.isNotEmpty && currentStr.isNotEmpty) {
      translations[currentId] = currentStr;
    }
    currentId = "";
    currentStr = "";
  }

  for (var line in lines) {
    line = line.trim();

    if (line.startsWith('msgid "')) {
      commit(); // Save previous pair if existing
      state = "ID";
      currentId = _extractContent(line, 'msgid "');
    } else if (line.startsWith('msgstr "')) {
      state = "STR";
      currentStr = _extractContent(line, 'msgstr "');
    } else if (line.startsWith('"') && line.endsWith('"')) {
      // Continuation line
      final content = _extractContent(line, '"');
      if (state == "ID") {
        currentId += content;
      } else if (state == "STR") {
        currentStr += content;
      }
    } else if (line.isEmpty) {
      state = "IDLE";
    }
  }

  commit(); // Final commit for the last entry in the file
  return translations;
}

String _extractContent(String line, String prefix) {
  // Removes the prefix and the trailing quote
  // e.g., msgid "Hello" -> Hello
  // e.g., " world" ->  world
  final start = prefix.length;
  final end = line.length - 1;
  if (start >= end) return "";

  return line
      .substring(start, end)
      .replaceAll(r'\"', '"') // Handle escaped quotes
      .replaceAll(r'\n', '\n'); // Handle literal newlines
}
