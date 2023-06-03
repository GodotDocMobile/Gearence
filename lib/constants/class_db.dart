import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:async/async.dart';

import 'package:godotclassreference/bloc/xml_load_bloc.dart';
import 'package:godotclassreference/models/class_content.dart';

// refactor this
class ClassDB {
  List<ClassContent> _classList = [];

  Isolate? runningIsolate;

  XMLLoadBloc loadBloc = XMLLoadBloc();

  static final ClassDB _instance = ClassDB._internal();
  String? version;

  factory ClassDB() {
    return _instance;
  }

  ClassDB._internal();

  loadFromJsonIndex(List<ClassContent> list, String version) {
    if (runningIsolate != null) {
      runningIsolate!.kill();
      runningIsolate = null;
    }
    this.version = version;
    _classList = List<ClassContent>.from(list);
  }

  loadFromXmls() async {
    ReceivePort p = ReceivePort();
    final events = StreamQueue<dynamic>(p);
    runningIsolate =
        await Isolate.spawn<SendPort>(loadClassXmlService, p.sendPort);

    SendPort sendPort = await events.next;

    for (var index in List<int>.generate(_classList.length, (index) => index)) {
      var _xmlLoaded = _classList[index].version != null;
      if (_xmlLoaded) {
        continue;
      }

      sendPort.send([
        _classList[index],
        await rootBundle.loadString(_classList[index].xmlFilePath!)
      ]);
      ClassContent _loadedClassContent = await events.next;
      _classList[index] = _loadedClassContent;
      loadBloc.add(_classList[index]);
    }

    sendPort.send(null);
    await events.cancel();

    runningIsolate = null;

    _classList.toSet().toList();
  }

  void loadClassXmlService(SendPort p) async {
    final commandPort = ReceivePort();
    p.send(commandPort.sendPort);
    await for (final message in commandPort) {
      if (message is List<dynamic>) {
        final clsContent = loadSingleXml(message[0], message[1]);
        p.send(clsContent);
      } else if (message == null) {
        break;
      }
    }
    debugPrint("Isolate quitting");
    Isolate.exit();
  }

  ClassContent loadSingleXml(ClassContent classContent, String content) {
    final rootNode = XmlDocument.parse(content)
        .root
        .children
        .lastWhere((w) => w.nodeType != XmlNodeType.TEXT);

    classContent.fromXml(rootNode as XmlElement);

    return classContent;
  }

  Future<ClassContent> getSingle(String? version, String className) async {
    final _className = className;

    var clsIndex =
        _classList.indexWhere((element) => element.name == _className);

    if (_classList[clsIndex].version != null) {
      return _classList[clsIndex];
    }
    _classList[clsIndex] = loadSingleXml(_classList[clsIndex],
        await rootBundle.loadString(_classList[clsIndex].xmlFilePath!));

    return _classList[clsIndex];
  }

  List<ClassContent> getDB() {
    return _classList;
  }
}
