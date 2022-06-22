import 'package:flutter/material.dart';

class MonospaceFontBloc with ChangeNotifier {
  late bool monospaced;

  MonospaceFontBloc();

  void setMonospaced(bool value) {
    monospaced = value;
    notifyListeners();
  }
}
