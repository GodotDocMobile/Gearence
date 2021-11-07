import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:godotclassreference/models/config_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/theme_bloc.dart';

class StoredValues {
  SharedPreferences? prefs;

  // String docDate;
  ThemeChange themeChange = ThemeChange();
  bool? iconForNonNode;

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
    iconForNonNode = prefs!.getBool('iconForNonNodes') == null
        ? true
        : prefs!.getBool('iconForNonNodes');

    return true;
  }
}
