//this is a singleton class
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:xml/xml.dart' as xml;

class ClassDB {
  List<ClassContent> _classContent = List<ClassContent>();

  static final ClassDB _instance = ClassDB._internal();
  bool loaded = false;
  String _version;
  bool _loading = false;

  String _loadingClass;

  factory ClassDB() {
    return _instance;
  }

  ClassDB._internal();

  updateList(List<ClassContent> list) {
    _classContent = List<ClassContent>.from(list);
  }

  updateDB(String version) async {
//    print("loading");
    if (!_loading) {
      _loading = true;
      loaded = false;
      _version = version;
      _updateDB(version);
      loaded = true;
      _loading = false;
    }
  }

  void _updateDB(String version) async {
    final _updatingVersion = version;
    for (var _classFileName in _classContent) {
      if (_updatingVersion != _version) {
        break;
      }
      _loadingClass = _classFileName.name;
      await _loadSingle(version, _classFileName.name);
      _loadingClass = null;
    }
    _classContent.toSet().toList();
//    print("all class loaded");
//    print(_classContent.length);
//    print(ClassList().getList().length);
  }

  Future<ClassContent> _loadSingle(String version, String classFileName,
      {bool skipCheck = true}) async {
    // ClassContent _toRtn;
    var _existIndex = _classContent.indexWhere(
        (element) => element.name == classFileName.replaceAll('.xml', ''));

    var _xmlLoaded =
        _existIndex != -1 && _classContent[_existIndex].version != null;

    if (_xmlLoaded) {
      return _classContent[_existIndex];
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

      // _classContent[_existIndex].inherits = _xmlContent.inherits;
      // _classContent[_existIndex].version = _xmlContent.version;
      // _classContent[_existIndex].briefDescription =
      //     _xmlContent.briefDescription;
      // _classContent[_existIndex].category = _xmlContent.category;
      // _classContent[_existIndex].constants = _xmlContent.constants;
      // _classContent[_existIndex].demos = _xmlContent.demos;
      // _classContent[_existIndex].description = _xmlContent.description;
      // _classContent[_existIndex].members = _xmlContent.members;
      // _classContent[_existIndex].methods = _xmlContent.methods;
      // _classContent[_existIndex].signals = _xmlContent.signals;
      // _classContent[_existIndex].themeItems = _xmlContent.themeItems;
      // _classContent[_existIndex].tutorials = _xmlContent.tutorials;

      return _xmlContent;
    }

    // return _toRtn;
  }

  Future<ClassContent> getSingle(String version, String className) async {
//    ClassContent _toReturn;
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
