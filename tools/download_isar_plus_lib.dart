import 'dart:io';
import 'package:path/path.dart' as p;

/// Downloads the Linux x64 libisar binary specifically from the ahmtydn/isar_plus repo.
/// [version] e.g., '1.2.1'
/// [targetPath] The directory where your packaging tool runs
Future<void> downloadIsarPlusLinux({
  required String version,
  required String targetPath,
}) async {
  // Filename pattern used in ahmtydn/isar_plus releases
  final fileName = 'libisar_linux_x64.so';
  final url =
      'https://github.com/ahmtydn/isar_plus/releases/download/$version/$fileName';

  final directory = Directory(targetPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // The Dart FFI looks for 'libisar.so' (no version suffix, no 'linux' prefix)
  final outputFile = File(p.join(targetPath, 'libisar.so'));

  print('🌐 Downloading Isar Plus Linux Core ($version) from ahmtydn repo...');

  final httpClient = HttpClient();
  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode == 200) {
      await response.pipe(outputFile.openWrite());

      // Essential for Proxmox/Linux execution
      await Process.run('chmod', ['755', outputFile.path]);

      print(
          '✅ Success! Binary saved and permissions set at: ${outputFile.path}');
    } else {
      throw Exception(
          'Download failed: HTTP ${response.statusCode}. Check if version $version exists.');
    }
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    httpClient.close();
  }
}
