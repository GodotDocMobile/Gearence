import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/helpers/translation_deletage.dart';
import 'package:godotclassreference/isar/manager/class_repository.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/services/isar_open.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
import 'package:godotclassreference/models/config_content.dart';
import 'package:godotclassreference/screens/doc_seed.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

Future injectUserPref() async {
  final getIt = GetIt.instance;

  getIt.registerSingleton(snackbarKey);

  final dir = await getApplicationSupportDirectory();
  final prefsIsar = await openIsarSafe(
    schemas: [UserSettingSchema],
    directory: dir.path,
    name: 'user_prefs',
    inspector: false,
  );

  getIt.registerSingleton(
    prefsIsar,
    instanceName: MetadataKeys.preferenceIsarKey,
  );

  final packageInfo = await PackageInfo.fromPlatform();
  getIt.registerSingleton(packageInfo);

  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton(sharedPrefs);
  storedValues.prefs = sharedPrefs;
  storedValues.configContent = ConfigContent.fromJson(
      jsonDecode(await rootBundle.loadString('assets/config.json')));

  final settingsRepo = SettingsRepository(prefsIsar);
  getIt.registerSingleton(settingsRepo);
  settingsRepo.seedDefaultSettings();

  final classDB = new ClassRepository();
  GetIt.I.registerSingleton(classDB);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectUserPref();

  runApp(GCRApp());
}

class GCRApp extends StatefulWidget {
  @override
  State<GCRApp> createState() => _GCRAppState();
}

class _GCRAppState extends State<GCRApp> {
  Locale processLangCode(String localeString) {
    // Handles formats like "zh_CN", "zh_Hans", or "sr_Cyrl"
    final parts = localeString.split('_');
    final language = parts[0];

    if (parts.length == 1) {
      return Locale(language);
    }

    final subtag = parts[1];

    if (subtag.length == 4) {
      // 4 characters = ISO 15924 Script Code (Hans, Hant, Cyrl)
      return Locale.fromSubtags(
        languageCode: language,
        scriptCode: subtag,
      );
    } else if (subtag.length == 2) {
      // 2 characters = ISO 3166-1 Country Code (CN, TW, HK)
      return Locale(language, subtag);
    }

    return Locale(language); // Fallback
  }

  @override
  Widget build(BuildContext context) {
    final repo = GetIt.I<SettingsRepository>();

    return StreamBuilder(
        stream: repo.watchAllSettings(),
        builder: (context, snapshoot) {
          final isDarkRecord = repo.getIsDarkMode();
          final translation = repo.getTranslation();
          final version = repo.getGodotVersion();

          final hasTranslation = double.parse(version.stringValue!) >= 3.4;

          Locale appLocale = processLangCode(translation.stringValue!);
          List<Locale> supportedLocales = [Locale('en')];
          if (hasTranslation) {
            final godotLocales = storedValues
                .configContent.branchTranslations[version.stringValue!]!
                .map((lc) => processLangCode(lc))
                .toList();
            supportedLocales.addAll(godotLocales);
          }

          return MaterialApp(
            locale: appLocale,
            supportedLocales: supportedLocales,
            localizationsDelegates: hasTranslation
                ? [
                    GearenceLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ]
                : null,
            //hide debug banner
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: isDarkRecord.boolValue == true
                ? ThemeMode.dark
                : ThemeMode.light,
            home: DocSeed(),
          );
        });
  }
}
