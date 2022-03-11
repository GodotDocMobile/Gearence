import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/bloc/tap_event_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/config_content.dart';
import '../bloc/theme_bloc.dart';

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

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {
    if (_instance.prefs == null) {
      _instance.readValue();
    }

    return _instance;
  }

  StoredValues._internal();

  Future<bool> readValue() async {
    if (prefs != null) {
      return true;
    }

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
