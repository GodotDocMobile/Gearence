import 'package:flutter/services.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredValues {
  SharedPreferences prefs;
  String docDate;
  ThemeChange themeChange;

  static final StoredValues _instance = StoredValues._internal();

  static final List<int> scrollIndexes = List<int>();
  static final List<int> tabIndexes = List<int>();
  static final List<String> classes = List<String>();

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

    int _scrollIndex = prefs.getInt('scrollIndex');
    if (_scrollIndex != null) {
      scrollIndexes.add(_scrollIndex);
    }

    int _tabIndex = prefs.getInt('tabIndex');
    if (_tabIndex != null) {
      scrollIndexes.add(_tabIndex);
    }

    String _className = prefs.getString('className');
    if (_className != null && _className.length > 0) {
      classes.add(_className);
    }
    return true;
  }
}
