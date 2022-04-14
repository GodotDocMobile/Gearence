import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/config_content.dart';
import '/bloc/blocs.dart';
import '/bloc/tap_event_bloc.dart';

class StoredValues {
  SharedPreferences? prefs;

  // String docDate;
  ThemeChange themeChange = ThemeChange();
  bool? iconForNonNode;
  int? fontSize;

  // bool? monoSpaceFont;
  MonospaceFontBloc monospaced = MonospaceFontBloc();

  TapEventBloc tapEventBloc = TapEventBloc();

  late ConfigContent configContent;
  late PackageInfo packageInfo;

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {

    return _instance;
  }

  StoredValues._internal();

  Future<bool> readValue() async {
    if (prefs != null) {
      return true;
    }

    packageInfo = await PackageInfo.fromPlatform();
    prefs = await SharedPreferences.getInstance();
    var configString = await rootBundle.loadString('xmls/conf.json');
    configContent = ConfigContent.fromJson(jsonDecode(configString));
    themeChange.isDark = prefs!.getBool('darkTheme') == true;
    iconForNonNode = prefs!.getBool('iconForNonNodes') ?? true;
    fontSize = prefs!.getInt("gcrFontSize") ?? 0;
    monospaced.monospaced = prefs!.getBool('monoSpaceFont') ?? false;
    return true;
  }
}

final StoredValues storedValues = StoredValues();
