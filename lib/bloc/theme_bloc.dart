import 'package:flutter/material.dart';

class ThemeChange with ChangeNotifier {
  bool isDark = false;

  ThemeChange();

  void switchTheme(bool value) {
    isDark = value;
    notifyListeners();
  }
}
