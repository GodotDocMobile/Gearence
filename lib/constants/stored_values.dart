import 'package:flutter/services.dart';
import 'package:godotclassreference/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredValues {
  SharedPreferences prefs;
  String docDate;
  ThemeChange themeChange;
  bool iconForNonNode;

  bool show2DNodes;
  bool show3DNodes;
  bool showControlNodes;
  bool showOtherNodes;
  bool showNonNodes;

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {
    if (_instance.prefs == null) {
      _instance.readValue();
    }

    return _instance;
  }

  StoredValues._internal();

  Future<bool> readValue() async {
    prefs = await SharedPreferences.getInstance();
    docDate = await rootBundle.loadString('xmls/conf.json');
    themeChange = ThemeChange(prefs.getBool('darkTheme') == true);
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

    return true;
  }
}
