import 'package:flutter_bloc/flutter_bloc.dart';

class MonospaceFontBloc extends Cubit<bool> {
  MonospaceFontBloc(bool initialState) : super(initialState);

  void add(bool value) => emit(value);
}

// class MonospaceFontBloc with ChangeNotifier {
//   late bool monospaced;

//   MonospaceFontBloc();

//   void setMonospaced(bool value) {
//     monospaced = value;
//     notifyListeners();
//   }
// }
