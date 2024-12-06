import 'package:flutter_bloc/flutter_bloc.dart';

class VersionBloc extends Cubit<String> {
  VersionBloc(String initialState) : super('');
  void add(String value) => emit(value);
}
