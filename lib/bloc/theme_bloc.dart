import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeChangeBloc extends Cubit<bool> {
  ThemeChangeBloc(bool initialState) : super(initialState);

  void add(bool value) => emit(value);
}

// class ThemeChange with ChangeNotifier {
//   late bool isDark;

//   ThemeChange();

//   void switchTheme(bool value) {
//     isDark = value;
//     notifyListeners();
//   }
// }
