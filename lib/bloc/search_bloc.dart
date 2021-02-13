import 'dart:async';

import 'package:godotclassreference/bloc/tap_event_arg.dart';

class SearchBloc {
  final _searchStateController = StreamController<TapEventArg>();
  StreamSink<TapEventArg> get _inArgs => _searchStateController.sink;
  Stream<TapEventArg> get argStream => _searchStateController.stream;

  final _searchEventController = StreamController<TapEventArg>();
  Sink<TapEventArg> get argSink => _searchEventController.sink;

  SearchBloc() {
    _searchEventController.stream.listen(_onAdd);
  }

  void _onAdd(TapEventArg data) {
    // print(data);
    _inArgs.add(data);
  }

  void dispose() {
    _searchEventController.close();
    _searchStateController.close();
  }
}
