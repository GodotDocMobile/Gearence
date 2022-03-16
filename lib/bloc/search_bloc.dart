import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/search_arg.dart';

import 'tap_event_arg.dart';

abstract class SearchEvent {}

class SearchBloc extends Cubit<TapEventArg> {
  SearchBloc() : super(TapEventArg(className: '-', fieldName: '-'));

  void add(TapEventArg eventArg) {
    emit(eventArg);
  }
}
