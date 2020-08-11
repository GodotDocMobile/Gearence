import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeChange with ChangeNotifier {
  bool isDark = false;

  ThemeChange(this.isDark);

  bool isListened() {
    return this.hasListeners;
  }

  bool currentThemeIsDark() {
    return isDark;
  }

  void switchTheme(bool value) {
    isDark = value;
    notifyListeners();
  }

  ThemeMode currentTheme() {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
