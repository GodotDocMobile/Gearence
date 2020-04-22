import 'package:shared_preferences/shared_preferences.dart';

class StoredValues {
  SharedPreferences prefs;

  static final StoredValues _instance = StoredValues._internal();

  factory StoredValues() {
    if (_instance.prefs == null) {
      _instance.readValue();
    }

    return _instance;
  }

  StoredValues._internal();

  Future<void> readValue() async {
    prefs = await SharedPreferences.getInstance();
  }
}
