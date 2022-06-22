import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/models/config_content.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '/bloc/blocs.dart';
import '/constants/stored_values.dart';
import '/theme/themes.dart';
import '/screens/class_select.dart';

Future<void> main() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(400, 600),
      center: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(GCRApp());
}

class GCRApp extends StatelessWidget {
  Future<bool> readValue() async {
    storedValues.prefs = await SharedPreferences.getInstance();
    storedValues.configContent = ConfigContent.fromJson(
        jsonDecode(await rootBundle.loadString('xmls/conf.json')));
    storedValues.packageInfo = await PackageInfo.fromPlatform();
    storedValues.themeChange.isDark = storedValues.isDarkTheme;
    storedValues.monospaced.monospaced = storedValues.isMonospaced;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: readValue(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider<ThemeChange>(
            create: (context) {
              return StoredValues().themeChange;
            },
            builder: (context, widget) {
              return MaterialApp(
                //hide debug banner
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: Provider.of<ThemeChange>(context).isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: ChangeNotifierProvider<MonospaceFontBloc>(
                  create: (context) {
                    return storedValues.monospaced;
                  },
                  builder: (context, widget) {
                    return ClassSelect();
                  },
                ),
              );
            },
          );
        } else {
          return Container(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
