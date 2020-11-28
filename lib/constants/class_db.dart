//this is a singleton class
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:xml/xml.dart' as xml;

class ClassDB {
  List<ClassContent> _classContent = List<ClassContent>();
  List<String> _classAreNode = List<String>();

  final _loadClassController = StreamController<ClassContent>.broadcast();
  StreamSink<ClassContent> get _inArgs => _loadClassController.sink;
  Stream<ClassContent> get argStream => _loadClassController.stream;

  static final ClassDB _instance = ClassDB._internal();
  bool loaded = false;
  String _version;
  bool _loading = false;

  String _loadingClass;

  factory ClassDB() {
    return _instance;
  }

  ClassDB._internal();

  updateDB(String version) async {
//    print("loading");
    if (!_loading) {
      _loading = true;
      loaded = false;
      _classContent.clear();
      _classAreNode.clear();
      _version = version;

      argStream.listen((event) {
        if (_classContent.indexOf(event) == -1) {
          _classContent.add(event);
        }
      });
      _updateDB(version);
//    for (var _classFileName in ClassList().getList()) {
//      _classContent.add(await _loadSingle(_version, _classFileName));
//    }
      loaded = true;
      _loading = false;
    }
  }

  void _updateNodeList() async {
    await _findChildClasses("Node");
    print("nodes loaded");
  }

  Future<void> _findChildClasses(String className) async {
    _classAreNode.add(className);
    var childes = _classContent
        .where((element) => element.inherits == className)
        .toList();
    if (childes.length > 0) {
      for (var child in childes) {
        await _findChildClasses(child.name);
      }
    }
  }

  void _updateDB(String version) async {
    final _updatingVersion = version;
    for (var _classFileName in ClassList().getList()) {
      if (_updatingVersion != _version) {
        break;
      }

      _loadingClass = _classFileName;
      _inArgs.add(await _loadSingle(version, _classFileName));
      _loadingClass = null;
    }
    _classContent.toSet().toList();
    _updateNodeList();
//    print("all class loaded");
//    print(_classContent.length);
//    print(ClassList().getList().length);
  }

  Future<ClassContent> _loadSingle(String version, String classFileName,
      {bool skipCheck = true}) async {
    ClassContent _toRtn;
    var _existIndex = _classContent.indexWhere(
        (element) => element.name == classFileName.replaceAll('.xml', ''));
    if (_existIndex == -1) {
      final file = await rootBundle.loadString(
          'xmls/' + version + '/' + classFileName.replaceAll('#Node#', ''));
      final rootNode = xml.XmlDocument.parse(file)
          .root
          .children
          .lastWhere((w) => w.nodeType != xml.XmlNodeType.TEXT);

      _toRtn = ClassContent.fromXml(rootNode);
    } else {
      _toRtn = _classContent[_existIndex];
    }
    return _toRtn;
  }

  Future<ClassContent> getSingle(String version, String classFileName) async {
//    ClassContent _toReturn;
    final _className = classFileName.replaceAll('.xml', '');

    if (_classContent.any((element) => element.name == _className)) {
      return _classContent.firstWhere((element) => element.name == _className);
    }

    return await _loadSingle(version, classFileName, skipCheck: false);
  }

  List<ClassContent> getDB() {
    return _classContent;
  }

  void dispose() {
    _loadClassController.close();
  }
}
