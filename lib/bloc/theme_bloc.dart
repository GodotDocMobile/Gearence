import 'package:flutter/material.dart';

class ThemeChange with ChangeNotifier {
  late bool isDark;

  ThemeChange();

  void switchTheme(bool value) {
    isDark = value;
    notifyListeners();
  }
}
