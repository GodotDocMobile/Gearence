import 'dart:async';

import 'package:godotclassreference/models/class_content.dart';

class XMLLoadBloc {
  final _loadStateController = StreamController<ClassContent>.broadcast();
  StreamSink<ClassContent> get _inArgs => _loadStateController.sink;
  Stream<ClassContent> get argStream => _loadStateController.stream;

  final _loadEventController = StreamController<ClassContent>();
  Sink<ClassContent> get argSink => _loadEventController.sink;

  XMLLoadBloc() {
    _loadEventController.stream.listen(_onAdd);
  }

  void _onAdd(ClassContent data) {
    _inArgs.add(data);
  }

  void dispose() {
    _loadEventController.close();
    _loadStateController.close();
  }
}
