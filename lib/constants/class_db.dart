import 'dart:async';

import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'package:godotclassreference/bloc/xml_load_bloc.dart';
import 'package:godotclassreference/models/class_content.dart';

// refactor this
class ClassDB {
  List<ClassContent> _classList = [];

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
    _classList = List<ClassContent>.from(list);
    // _classContent.sort((a, b) {
    //   return a.name!.compareTo(b.name!);
    // });
    loading = false;
  }

  loadFromXmls() async {
    if (!loading) {
      loading = true;
      for (var _classContent in _classList) {
        if (!loading) break;
        await _loadSingle(version, _classContent.name);
      }
      _classList.toSet().toList();
      loading = false;
    }
  }

  Future<ClassContent> _loadSingle(String? version, String? classFileName,
      {bool skipCheck = true}) async {
    ClassContent _toRtn;
    var _existIndex = _classList.indexWhere(
        (element) => element.name == classFileName!.replaceAll('.xml', ''));

    var _xmlLoaded =
        _existIndex != -1 && _classList[_existIndex].version != null;

    if (_xmlLoaded) {
      _toRtn = _classList[_existIndex];
    } else {
      final file = await rootBundle
          .loadString('xmls/' + version! + '/' + classFileName! + '.xml');
      final rootNode = XmlDocument.parse(file)
          .root
          .children
          .lastWhere((w) => w.nodeType != XmlNodeType.TEXT);

      _classList[_existIndex].fromXml(rootNode as XmlElement);

      _toRtn = _classList[_existIndex];
    }

    if (skipCheck) {
      // loadBloc.argSink.add(_toRtn);
      loadBloc.add(XMLLoadFinish());
    }

    return _toRtn;
  }

  Future<ClassContent> getSingle(String? version, String className) async {
    final _className = className;

    if (_classList.any(
        (element) => element.name == _className && element.version != null)) {
      return _classList.firstWhere((element) => element.name == _className);
    }

    return await _loadSingle(version, className, skipCheck: false);
  }

  List<ClassContent> getDB() {
    return _classList;
  }
}
