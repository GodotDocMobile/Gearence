import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/isar/services/isar_open.dart';
import 'package:godotclassreference/screens/class_list.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DocSeed extends StatefulWidget {
  const DocSeed({super.key});

  @override
  State<DocSeed> createState() => _DocSeedState();
}

class _DocSeedState extends State<DocSeed> {
  String statusMessage = '';

  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startInitialization();
    });
  }

  Future<void> startInitialization() async {
    if (_isStarted) return;
    _isStarted = true;

    try {
      setState(() => statusMessage = "Checking documentation...");

      final settingsRepo = GetIt.I<SettingsRepository>();
      final dir = await getApplicationDocumentsDirectory();
      final godotVersion = settingsRepo.getGodotVersion().stringValue!;
      final packageInfo = GetIt.I<PackageInfo>();

      // Clean formatting for filename
      final docIsarFileName = 'godot_${godotVersion.replaceAll('.', '_')}';
      final localDbFile = File('${dir.path}/$docIsarFileName.isar');

      final localDBVerSetting = settingsRepo.getLocalDBVersion(godotVersion);
      final int localBuild =
          int.tryParse(localDBVerSetting.stringValue ?? '0') ?? 0;
      final int currentBuild = int.parse(packageInfo.buildNumber);

      bool needsCopy = !localDbFile.existsSync() || currentBuild > localBuild;

      if (needsCopy) {
        setState(
            () => statusMessage = "Optimizing Godot $godotVersion library...");

        // 1. Properly close existing instance if open
        if (GetIt.I
            .isRegistered<Isar>(instanceName: MetadataKeys.docsIsarKey)) {
          final Isar openedIsar =
              GetIt.I(instanceName: MetadataKeys.docsIsarKey);
          openedIsar.close();
        }

        // 2. Copy the bytes
        final data = await rootBundle.load('assets/$docIsarFileName.isar');
        // writeAsBytes can be slow for 110MB, using flush: true is safer
        await localDbFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );

        // 3. Update the version in your settings repo
        localDBVerSetting.stringValue = packageInfo.buildNumber;
        settingsRepo.saveSettings(localDBVerSetting);
      }

      // 4. Open the instance (Always use the constant name for the app)
      setState(() => statusMessage = "Opening database...");
      final docIsar = await openIsarSafe(
        schemas: [
          ClassContentSchema,
          GodotIconSchema,
          TranslationSchema,
        ],
        directory: dir.path,
        name: docIsarFileName, // Constant name for the whole app
        inspector: true,
      );

      // 5. Register with GetIt (Unregister first if exists)
      if (GetIt.I.isRegistered<Isar>(instanceName: MetadataKeys.docsIsarKey)) {
        await GetIt.I.unregister<Isar>(instanceName: MetadataKeys.docsIsarKey);
      }
      GetIt.I.registerSingleton<Isar>(docIsar,
          instanceName: MetadataKeys.docsIsarKey);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ClassList()),
        );
      }
    } catch (e) {
      debugPrint("Seed Error: $e");
      if (mounted) setState(() => statusMessage = "Initialization Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(statusMessage),
          ],
        ),
      ),
    );
  }
}
