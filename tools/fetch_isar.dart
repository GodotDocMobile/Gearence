import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

final serverAddr = 'https://godotdocmobile.github.io';
final downloadBaseFolder = '$serverAddr/dist-assets';
void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage')
    ..addOption('output', abbr: 'o', help: 'Output folder')
    ..addFlag('force', abbr: 'f', negatable: false, help: 'Force download all');

  ArgResults argParseResult = parser.parse(arguments);
  if (argParseResult['help']) {
    print(parser.usage);
    return;
  }

  final outputPath = argParseResult['output'] ?? '.';
  final force = argParseResult['force'] ?? false;
  final outputDir = Directory(outputPath);
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  print("--- Starting Sync from $downloadBaseFolder ---");

  try {
    // 1. Fetch the Manifest first
    print("Fetching dist.json...");
    final distResponse = await http.get(Uri.parse('$downloadBaseFolder/dist.json'));
    if (distResponse.statusCode != 200) throw "Failed to fetch dist.json";

    final dist = jsonDecode(distResponse.body) as Map<String, dynamic>;
    final filesToSync = <String, dynamic>{};

    // Add config to sync list
    if (dist.containsKey('config')) {
      filesToSync['config.json'] = dist['config'];
    }

    // Add version binaries to sync list
    if (dist.containsKey('files')) {
      (dist['files'] as Map).forEach((version, info) {
        filesToSync[info['file_name']] = info;
      });
    }

    // 2. Process each file
    for (var entry in filesToSync.entries) {
      final fileName = entry.key;
      final info = entry.value;
      final remoteHash = info['sha256'];
      final localFile = File(join(outputPath, fileName));

      bool needsDownload = force;

      if (!needsDownload && localFile.existsSync()) {
        final localBytes = await localFile.readAsBytes();
        final localHash = sha256.convert(localBytes).toString();
        if (localHash != remoteHash) {
          print("Hash mismatch for $fileName. Updating...");
          needsDownload = true;
        } else {
          print("$fileName is up to date.");
        }
      } else {
        needsDownload = true;
      }

      if (needsDownload) {
        await _download(fileName, localFile, remoteHash);
      }
    }

    print("--- Sync Complete ---");
  } catch (e) {
    print("Error during sync: $e");
  }
}

Future<void> _download(
    String fileName, File localFile, String expectedHash) async {
  print("Downloading $fileName...");
  final url = '$downloadBaseFolder/$fileName';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;

    // Integrity Check before writing
    final actualHash = sha256.convert(bytes).toString();
    if (actualHash == expectedHash) {
      await localFile.writeAsBytes(bytes);
      print("Successfully verified and saved $fileName");
    } else {
      print(
          "Critical Error: Downloaded $fileName but hash mismatch! Expected: $expectedHash, Got: $actualHash");
    }
  } else {
    print("Failed to download $fileName: Status ${response.statusCode}");
  }
}
