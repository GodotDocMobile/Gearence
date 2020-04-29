import 'dart:async';

import 'package:godotclassreference/constants/tap_event_arg.dart';

class TapEventBloc {
  final _argStateController = StreamController<TapEventArg>.broadcast();
  StreamSink<TapEventArg> get _inArgs => _argStateController.sink;
  Stream<TapEventArg> get argStream => _argStateController.stream;

  final _argEventController = StreamController<TapEventArg>();
  Sink<TapEventArg> get argSink => _argEventController.sink;

  TapEventBloc() {
    _argEventController.stream.listen(_onAdd);
  }

  void _onAdd(TapEventArg data) {
    _inArgs.add(data);
  }

  void dispose() {
    _argEventController.close();
    _argStateController.close();
  }
}
