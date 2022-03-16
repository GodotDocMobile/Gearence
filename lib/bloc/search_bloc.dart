import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/search_arg.dart';

import 'tap_event_arg.dart';

abstract class SearchEvent {}

class SearchBloc extends Cubit<SearchEventArg> {
  SearchBloc()
      : super(SearchEventArg(
            tapEventArg: TapEventArg(className: '-', fieldName: '-'),
            rank: 10));

  void add(SearchEventArg eventArg) {
    emit(eventArg);
  }
}
