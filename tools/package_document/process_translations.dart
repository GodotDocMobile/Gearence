import 'dart:io';

import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart';

void processTranslations(String godotPath, Isar isar) {
  final translationFolderPath = join(godotPath, 'doc/translations');
  final translationDir = Directory(translationFolderPath);

  if (translationDir.existsSync()) {
    final poFiles = translationDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.po'));

    for (var file in poFiles) {
      print("Processing ${file.path}");
      final locale = basenameWithoutExtension(file.path); // e.g. "zh_CN"
      final translations = parsePoFile(file.path);

      isar.write((isar) {
        for (var entry in translations.entries) {
          final msgid = entry.key;
          final msgstr = entry.value;

          // Check if we already have this English string in this Isar file
          var existing =
              isar.translations.where().msgidEqualTo(msgid).findFirst();

          if (existing != null) {
            // Add this language to the existing record
            existing.translations!.add(LocaleString()
              ..locale = locale
              ..value = msgstr);
            isar.translations.put(existing);
          } else {
            // New English string, create the record
            isar.translations
                .put(Translation(id: isar.translations.autoIncrement())
                  ..msgid = msgid
                  ..translations = [
                    LocaleString()
                      ..locale = locale
                      ..value = msgstr
                  ]);
          }
        }
      });
    }
  }
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
