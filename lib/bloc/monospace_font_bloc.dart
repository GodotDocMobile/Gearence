import 'package:flutter/material.dart';

class MonospaceFontBloc with ChangeNotifier {
  bool monospaced = false;

  MonospaceFontBloc();

  void setMonospaced(bool value) {
    monospaced = value;
    notifyListeners();
  }
}
