import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:godotclassreference/models/config_content.dart';

class StoredValues {
  late SharedPreferences prefs;

  late ConfigContent configContent;
  late PackageInfo packageInfo;

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {
    return _instance;
  }

  StoredValues._internal();

  String get version =>
      prefs.getString('version') ?? configContent.branches.last;

  void set version(String val) {
    if (!configContent.branches.contains(val)) {
      val = configContent.branches.last;
    }
    prefs.setString('version', val);
  }

  bool get isDarkTheme => prefs.getBool('darkTheme') ?? false;

  void set isDarkTheme(bool val) {
    prefs.setBool('darkTheme', val);
  }

  int get fontSize => prefs.getInt('gcrFontSize') ?? 0;

  void set fontSize(int val) {
    prefs.setInt('gcrFontSize', val);
  }

  bool get isMonospaced {
    return prefs.getBool('monoSpaceFont') ?? false;
  }

  void set isMonospaced(bool val) {
    prefs.setBool('monoSpaceFont', val);
  }

  String get translation {
    var value = prefs.getString('translation') ?? 'en';
    if (!configContent.branchTranslations[version]!.contains(value)) {
      // translation = 'en';
      value = 'en';
    }
    return value;
  }

  void set translation(String val) {
    if (!configContent.branchTranslations[version]!.contains(val)) {
      val = 'en';
    }
    prefs.setString('translation', val);
  }
}

final StoredValues storedValues = StoredValues();
