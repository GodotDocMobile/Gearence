import 'dart:async';

class IconForNonNodeBloc {
  final _blockStateController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inArgs => _blockStateController.sink;
  Stream<bool> get argStream => _blockStateController.stream;

  final _blockEventController = StreamController<bool>();
  Sink<bool> get argSink => _blockEventController.sink;

  IconForNonNodeBloc() {
    _blockEventController.stream.listen(_onAdd);
  }
  void _onAdd(bool data) {
    _inArgs.add(data);
  }

  void dispose() {
    _blockEventController.close();
    _blockStateController.close();
  }
}
