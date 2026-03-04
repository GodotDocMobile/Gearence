import 'dart:io';

import 'package:args/args.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart';

import 'download_isar_plus_lib.dart';
import 'package_document/process_xml.dart';

final godotVersions = [
  "2.0",
  "2.1",
  "3.0",
  "3.1",
  "3.2",
  "3.3",
  "3.4",
  "3.5",
  "3.6",
  "4.0",
  "4.1",
  "4.2",
  "4.3",
  "4.4",
  "4.5",
  "4.6",
];

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption('godot_path', help: "Path to Godot Engine repository")
    ..addOption('output', abbr: 'o', help: 'Output folder (e.g., assets)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  ArgResults argParseResult = parser.parse(arguments);

  if (argParseResult['help']) {
    print(parser.usage);
    return;
  }

  String godotPath;
  if (argParseResult['godot_path'] == null ||
      (argParseResult['godot_path'] as String).isEmpty) {
    print("Please provide [godot_path] option");
    print(parser.usage);
    return;
  } else {
    godotPath = argParseResult['godot_path'];
  }

  String outputPath;
  if (argParseResult['output'] == null ||
      (argParseResult['output'] as String).isEmpty) {
    outputPath = '.';
    print("Using current directory as output folder");
  } else {
    outputPath = argParseResult['output'];
  }

  final Directory outputDir = Directory(outputPath);
  if (!outputDir.existsSync()) {
    print("Output directory [$outputPath] not exist, creating..");
    outputDir.createSync();
  }

  if (!File('./libisar.so').existsSync()) {
    await downloadIsarPlusLinux(version: '1.2.2', targetPath: '.');
  }
  await Isar.initialize("./libisar.so");

  final Directory godotRepoDir = Directory(godotPath);
  if (!godotRepoDir.existsSync()) {
    print("Error: Godot path does not exist.");
    return;
  }

  for (String version in godotVersions) {
    print("--- Processing Godot Version: $version ---");
    try {
      // 1. Switch Git Branch/Tag
      final tag = "$version";

      print("Switching to tag: $tag");
      final result = await Process.run(
        'git',
        ['checkout', tag],
        workingDirectory: godotPath,
      );
      // Possibly pull latest from repo

      if (result.exitCode != 0) {
        print("Failed to checkout $tag: ${result.stderr}");
        continue;
      }

      // 2. Process Files for this version
      await processGodotVersion(godotPath, outputPath, version);
    } catch (e) {
      print("Error processing version $version: $e");
    }
  }
}

Future<void> processGodotVersion(
    String repoPath, String outPath, String version) async {
  // 1. Initialize Isar for THIS version
  final dbName = "godot_$version".replaceAll('.', '_');
  final isar = await Isar.open(
    schemas: [
      ClassContentSchema,
      GodotIconSchema,
      TranslationSchema
    ], // Add your schemas here
    directory: outPath,
    name: dbName,
    inspector: false,
  );

  // clear old entries if exists
  isar.write((isar) {
    isar.classContents.clear();
    isar.godotIcons.clear();
    isar.translations.clear();
  });

  final double v = double.parse(version);
  if (v < 3) {
    // single file
    processSingleClassFile(repoPath, isar);
  } else {
    // multiple file
    processMultipleClassFiles(repoPath, isar);
  }

  await isar.close();
  print("Saved $dbName.isar");

  // Clean up the lock file so it doesn't get zipped
  final lockFile = File(join(outPath, '$dbName.isar.lock'));
  if (lockFile.existsSync()) {
    lockFile.deleteSync();
    print("🗑️ Removed lock file.");
  }
}
