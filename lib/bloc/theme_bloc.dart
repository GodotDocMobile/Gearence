import 'package:flutter/material.dart';

class ThemeChange with ChangeNotifier {
  bool isDark = false;

  ThemeChange();

  bool isListened() {
    return this.hasListeners;
  }

  bool currentThemeIsDark() {
    return isDark;
  }

  void switchTheme(bool value) {
    isDark = value;
    // print(this.isListened());
    notifyListeners();
  }

  ThemeMode currentTheme() {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
