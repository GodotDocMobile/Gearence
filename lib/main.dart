import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/helpers/localizations.dart';
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
  storedValues.packageInfo = packageInfo;
  storedValues.configContent = ConfigContent.fromJson(
      jsonDecode(await rootBundle.loadString('assets/config.json')));

  final settingsRepo = SettingsRepository(prefsIsar);
  getIt.registerSingleton(settingsRepo);
  settingsRepo.seedDefaultSettings();
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
  @override
  Widget build(BuildContext context) {
    final repo = GetIt.I<SettingsRepository>();

    return StreamBuilder(
        stream: repo.watchAllSettings(),
        builder: (context, snapshoot) {
          // Using your isDarkMode() logic for the initial/current state
          final isDarkRecord = repo.getIsDarkMode();
          final langCode = repo.getLanguage();
          final version = repo.getGodotVersion();

          final hasTranslation = double.parse(version.stringValue!) >= 3.4;

          late Locale appLocale;
          late List<Locale> supportedLocales;
          if (hasTranslation) {
            switch (langCode.stringValue) {
              case 'zh-Hans':
                appLocale = Locale.fromSubtags(
                  languageCode: 'zh',
                  scriptCode: 'Hans',
                );
                break;
              default:
                appLocale = Locale(langCode.stringValue!);
                break;
            }

            supportedLocales = [Locale('en')];
          }

          return MaterialApp(
            // locale: appLocale,
            // supportedLocales: supportedLocales,
            // localizationsDelegates: hasTranslation
            //     ? [
            //         // GearenceGettextLocalizationsDelegate(),
            //         GlobalMaterialLocalizations.delegate,
            //         GlobalCupertinoLocalizations.delegate,
            //         GlobalWidgetsLocalizations.delegate,
            //         FallbackLocalizationDelegate(),
            //       ]
            //     : null,
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
