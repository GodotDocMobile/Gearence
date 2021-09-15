import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:godotclassreference/models/config_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/theme_bloc.dart';

class StoredValues {
  SharedPreferences prefs;

  // String docDate;
  ThemeChange themeChange = ThemeChange();
  bool iconForNonNode;

  ConfigContent configContent;

  bool show2DNodes;
  bool show3DNodes;
  bool showControlNodes;
  bool showOtherNodes;
  bool showNonNodes;
  bool showVisualScriptNodes;

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
    themeChange.isDark = prefs.getBool('darkTheme') == true;
    iconForNonNode = prefs.getBool('iconForNonNodes') == null
        ? true
        : prefs.getBool('iconForNonNodes');

    show2DNodes = prefs.getBool('show2DNodes') == null
        ? true
        : prefs.getBool('show2DNodes');

    show3DNodes = prefs.getBool('show3DNodes') == null
        ? true
        : prefs.getBool('show3DNodes');

    showControlNodes = prefs.getBool('showControlNodes') == null
        ? true
        : prefs.getBool('showControlNodes');

    showOtherNodes = prefs.getBool('showOtherNodes') == null
        ? true
        : prefs.getBool('showOtherNodes');

    showNonNodes = prefs.getBool('showNonNodes') == null
        ? true
        : prefs.getBool('showNonNodes');

    showVisualScriptNodes = prefs.getBool('showVisualScriptNodes') == null
        ? true
        : prefs.getBool('showVisualScriptNodes');
    return true;
  }
}
