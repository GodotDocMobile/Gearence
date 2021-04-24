//this is a singleton class
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

import '../bloc/xml_load_bloc.dart';
import '../models/class_content.dart';

class ClassDB {
  List<ClassContent> _classContent = [];

  XMLLoadBloc loadBloc = XMLLoadBloc();

  static final ClassDB _instance = ClassDB._internal();
  String _version;
  bool loading = false;

  // String _loadingClass;

  factory ClassDB() {
    return _instance;
  }

  ClassDB._internal();

  updateList(List<ClassContent> list) {
    _classContent = List<ClassContent>.from(list);
    _classContent.sort((a, b) {
      return a.name.compareTo(b.name);
    });
  }

  updateDB(String version) async {
//    print("loading");
    if (!loading) {
      loading = true;
      _version = version;
      _updateDB(version);
      loading = false;
    }
  }

  void _updateDB(String version) async {
    final _updatingVersion = version;
    for (var _classFileName in _classContent) {
      if (_updatingVersion != _version) {
        break;
      }
      // _loadingClass = _classFileName.name;
      await _loadSingle(version, _classFileName.name);
      // _loadingClass = null;
    }
    _classContent.toSet().toList();
  }

  Future<ClassContent> _loadSingle(String version, String classFileName,
      {bool skipCheck = true}) async {
    ClassContent _toRtn;
    var _existIndex = _classContent.indexWhere(
        (element) => element.name == classFileName.replaceAll('.xml', ''));

    var _xmlLoaded =
        _existIndex != -1 && _classContent[_existIndex].version != null;

    if (_xmlLoaded) {
      _toRtn = _classContent[_existIndex];
    } else {
      final file = await rootBundle
          .loadString('xmls/' + version + '/' + classFileName + '.xml');
      final rootNode = xml.XmlDocument.parse(file)
          .root
          .children
          .lastWhere((w) => w.nodeType != xml.XmlNodeType.TEXT);

      ClassContent _xmlContent = ClassContent.fromXml(rootNode);
      _xmlContent.inheritChain = _classContent[_existIndex].inheritChain;
      _classContent[_existIndex] = _xmlContent;

      _toRtn = _xmlContent;
    }

    if (skipCheck) {
      loadBloc.argSink.add(_toRtn);
    }

    return _toRtn;
  }

  Future<ClassContent> getSingle(String version, String className) async {
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
