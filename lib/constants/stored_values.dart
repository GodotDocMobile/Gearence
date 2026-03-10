import 'package:godotclassreference/constants/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:godotclassreference/models/config_content.dart';

class StoredValues {
  late SharedPreferences prefs;

  late ConfigContent configContent;

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {
    return _instance;
  }

  StoredValues._internal();

  String get version => prefs.getString('version') ?? godotVersions.last;

  double get versionDouble => double.tryParse(version) ?? 0.0;

  bool get isDarkTheme => prefs.getBool('darkTheme') ?? false;

  int get fontSize => prefs.getInt('gcrFontSize') ?? 0;

  bool get isMonospaced => prefs.getBool('monoSpaceFont') ?? false;

  String get translation => prefs.getString('translation') ?? 'en';
}

final StoredValues storedValues = StoredValues();
