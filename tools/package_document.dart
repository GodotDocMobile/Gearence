import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/models/config_content.dart';
import 'package:intl/intl.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart';

import 'download_isar_plus_lib.dart';
import 'fetch_isar.dart';
import 'package_document/process_translations.dart';
import 'package_document/process_xml.dart';

ConfigContent configConten = new ConfigContent();

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption('godot_path', help: "Path to Godot Engine repository")
    ..addOption('output', abbr: 'o', help: 'Output folder (e.g., assets)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage')
    ..addFlag('skip_pull',
        negatable: false, help: 'Skip pull before processing documents')
    ..addFlag('dist',
        abbr: 'd',
        negatable: false,
        help: 'Generate dist.json for file list and checksum');

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

  bool skipPull = argParseResult['skip_pull'];

  for (String version in godotVersions) {
    // 1. Fetch all updates from the remote first
    // This ensures your local machine knows about any new commits or tags
    if (!skipPull) {
      await Process.run('git', ['fetch', '--all'], workingDirectory: godotPath);
    }

    try {
      // 2. Decide if you want the "Stable Tag" or the "Maintenance Branch"
      // Usually, checking out the branch (e.g., '4.6') is better for docs.
      String target = version;

      print("Switching to: $target");

      // Use 'checkout' with a force flag to clear any accidental local changes

      final checkoutResult = await Process.run(
          'git', ['checkout', '-f', target],
          workingDirectory: godotPath);

      if (checkoutResult.exitCode != 0) {
        print("Error: Could not find $target. Skipping.");
        continue;
      }

      // 3. Pull the latest commits if it's a branch
      // Note: If 'target' is a Tag, 'git pull' will do nothing/error.

      if (!skipPull) {
        await Process.run('git', ['pull', 'origin', target],
            workingDirectory: godotPath);
        print("Successfully updated to the latest $version docs.");
      }

      // 4. Process as usual
      await processGodotVersion(godotPath, outputPath, version);
    } catch (e) {
      print("Error processing version $version: $e");
    }
  }

  // remove temp db file and lock file
  final db = join(outputPath, 'godot_temp.isar');
  final lock = '${db}.lock';
  await File(db).delete();
  await File(lock).delete();

  // write ConfigContent
  final format = DateFormat('yyyy-MM-dd');
  configConten.updateDate = format.format(DateTime.now());
  await File(join(outputPath, 'config.json'))
      .writeAsString(jsonEncode(configConten.toJson()));
  print("ConfigContent generated");

  if (argParseResult['dist'] as bool != true) return;
  print("Generating dist.json");

  final Map<String, dynamic> distManifest = {
    "generated_at": DateTime.now().toIso8601String(),
    "files": {},
  };

  for (String version in godotVersions) {
    // We assume your processGodotVersion creates a file named 'godot_$version.isar'
    final fileName = 'godot_${version.replaceAll('.', '_')}.isar';
    final filePath = join(outputPath, fileName);
    final file = File(filePath);

    if (file.existsSync()) {
      final bytes = await file.readAsBytes();

      // Calculate SHA-256 Checksum
      final hash = sha256.convert(bytes).toString();
      final size = bytes.length;

      distManifest["files"][version] = {
        "file_name": fileName,
        "sha256": hash,
        "size_in_bytes": size,
        "url": "$downloadBaseFolder/$fileName"
      };

      print("Added $version to manifest: $hash");
    } else {
      print("Warning: $filePath not found, skipping manifest entry.");
    }
  }

  final configFile = File(join(outputPath, 'config.json'));
  if (configFile.existsSync()) {
    final configBytes = await configFile.readAsBytes();
    distManifest["config"] = {
      "file_name": "config.json",
      "sha256": sha256.convert(configBytes).toString(),
      "size_in_bytes": configBytes.length,
    };
  }

  final distFile = File(join(outputPath, 'dist.json'));
  await distFile
      .writeAsString(const JsonEncoder.withIndent('  ').convert(distManifest));

  print("dist.json generated successfully at ${distFile.path}");
}

Future<void> processGodotVersion(
    String godotPath, String outPath, String version) async {
  // 1. Initialize Isar for THIS version
  final tempDBName = 'godot_temp';
  final dbName = "godot_$version".replaceAll('.', '_');
  final isar = await Isar.open(
    schemas: [
      ClassContentSchema,
      GodotIconSchema,
      TranslationSchema,
    ], // Add your schemas here
    directory: outPath,
    name: tempDBName,
    inspector: false,
    maxSizeMiB: 5120,
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
    processSingleClassFile(godotPath, isar);
  } else {
    // multiple file
    processMultipleClassFiles(godotPath, isar);
  }

  if (v >= 3.4) {
    print("Processing translations");
    configConten.branchTranslations
        .addAll({version: processTranslations(godotPath, isar)});
  } else {
    configConten.branchTranslations.addAll({version: []});
  }

  await isar.close();
  print("Saved $tempDBName.isar");

  // // Clean up the lock file so it doesn't get zipped
  // final lockFile = File(join(outPath, '$tempDBName.isar.lock'));
  // if (lockFile.existsSync()) {
  //   lockFile.deleteSync();
  //   print("🗑️ Removed lock file.");
  // }

  final isarForCompaction = await Isar.open(
      schemas: [
        ClassContentSchema,
        GodotIconSchema,
        TranslationSchema,
      ], // Add your schemas here
      directory: outPath,
      name: tempDBName,
      inspector: false);
  final dbFilePath = join(outPath, "$dbName.isar");
  final dbFile = File(dbFilePath);
  if (dbFile.existsSync()) {
    await dbFile.delete();
  }
  isarForCompaction.copyToFile(dbFilePath);
  await isarForCompaction.close();
}
