import 'package:flutter_bloc/flutter_bloc.dart';

class TranslationBloc extends Cubit<String> {
  TranslationBloc(String initialState) : super('');
  void add(String value) => emit(value);
}
