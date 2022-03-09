//this is a singleton class
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

import '../bloc/xml_load_bloc.dart';
import '../models/class_content.dart';

class ClassDB {
  List<ClassContent> _classContent = [];

  XMLLoadBloc loadBloc = XMLLoadBloc();

  static final ClassDB _instance = ClassDB._internal();
  String? version;
  bool loading = false;

  factory ClassDB() {
    return _instance;
  }

  ClassDB._internal();

  loadFromParseJson(List<ClassContent> list, String version) {
    this.version = version;
    _classContent = List<ClassContent>.from(list);
    _classContent.sort((a, b) {
      return a.name!.compareTo(b.name!);
    });
    loading = false;
  }

  loadFromXmls() async {
    if (!loading) {
      loading = true;
      for (var _classFileName in _classContent) {
        if (!loading) break;
        await _loadSingle(version, _classFileName.name);
      }
      _classContent.toSet().toList();
      loading = false;
    }
  }

  Future<ClassContent> _loadSingle(String? version, String? classFileName,
      {bool skipCheck = true}) async {
    ClassContent _toRtn;
    var _existIndex = _classContent.indexWhere(
        (element) => element.name == classFileName!.replaceAll('.xml', ''));

    var _xmlLoaded =
        _existIndex != -1 && _classContent[_existIndex].version != null;

    if (_xmlLoaded) {
      _toRtn = _classContent[_existIndex];
    } else {
      final file = await rootBundle
          .loadString('xmls/' + version! + '/' + classFileName! + '.xml');
      final rootNode = xml.XmlDocument.parse(file)
          .root
          .children
          .lastWhere((w) => w.nodeType != xml.XmlNodeType.TEXT);

      _classContent[_existIndex].fromXml(rootNode as XmlElement);

      _toRtn = _classContent[_existIndex];
    }

    if (skipCheck) {
      // loadBloc.argSink.add(_toRtn);
      loadBloc.add(XMLLoadFinish());
    }

    return _toRtn;
  }

  Future<ClassContent> getSingle(String? version, String className) async {
    final _className = className;

    if (_classContent.any(
        (element) => element.name == _className && element.version != null)) {
      return _classContent.firstWhere((element) => element.name == _className);
    }

    return await _loadSingle(version, className, skipCheck: false);
  }

  List<ClassContent> getDB() {
    return _classContent;
  }
}
