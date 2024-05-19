import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:godotclassreference/models/config_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/screens/class_select.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
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

class GCRApp extends StatefulWidget {
  @override
  State<GCRApp> createState() => _GCRAppState();
}

class _GCRAppState extends State<GCRApp> {
  Future<bool> readValue() async {
    storedValues.prefs = await SharedPreferences.getInstance();
    storedValues.configContent = ConfigContent.fromJson(
        jsonDecode(await rootBundle.loadString('xmls/conf.json')));
    storedValues.packageInfo = await PackageInfo.fromPlatform();

    return true;
  }

  Widget _buildBlocProvider(MaterialApp child) {
    return MultiBlocListener(listeners: [
      BlocListener<MonospaceFontBloc, bool>(
        bloc: blocs.monospaceFontBloc,
        listener: (context, state) {
          setState(() {
            storedValues.isMonospaced = state;
          });
        },
      ),
      BlocListener<ThemeChangeBloc, bool>(
          bloc: blocs.themeChangeBloc,
          listener: (context, state) {
            setState(() {
              storedValues.isDarkTheme = state;
            });
          })
    ], child: child);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: readValue(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _buildBlocProvider(MaterialApp(
            //hide debug banner
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                storedValues.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: ClassSelect(),
          ));
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
