import 'dart:io';

import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

void processSingleClassFile(String godotPath, Isar isar) {
  final xmlFilePath = join(godotPath, 'doc/base/classes.xml');
  final xmlFile = new File(xmlFilePath);
  final xmlParsed = XmlDocument.parse(xmlFile.readAsStringSync());
  List<ClassContent> classContents = [];
  final svgPath = join(godotPath, "editor", "icons", "source");
  for (final node in xmlParsed.rootElement.childElements) {
    final classContent = parseXML(node, isar);
    copySvg(svgPath, classContent.name!, isar);
    classContents.add(classContent);
  }
  isar.write((isar) {
    isar.classContents.putAll(classContents);
  });
}

void processMultipleClassFiles(String godotPath, Isar isar) {
  final xmlsFolder = join(godotPath, 'doc/classes');
  final dir = Directory(xmlsFolder);
  List<ClassContent> classContents = [];

  final svgPath = join(godotPath, "editor", "icons");

  print("Procerssing standard docs");
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && extension(entity.path) == '.xml') {
      print("Processing ${relative(entity.path, from: godotPath)}");
      final xmlParsed = XmlDocument.parse(entity.readAsStringSync());

      final classContent = parseXML(xmlParsed.rootElement, isar);
      copySvg(svgPath, classContent.name!, isar);
      classContents.add(classContent);
    }
  }

  print("Processing module docs");
  final modulesFolder = join(godotPath, 'modules');
  final moduleDir = Directory(modulesFolder);
  for (final entity in moduleDir.listSync(recursive: true)) {
    if (entity is File &&
        extension(entity.path) == '.xml' &&
        entity.path.contains('/doc_classes/')) {
      print("Processing ${relative(entity.path, from: godotPath)}");
      final xmlParsed = XmlDocument.parse(entity.readAsStringSync());

      final classContent = parseXML(xmlParsed.rootElement, isar);
      copySvg(svgPath, classContent.name!, isar);
      classContents.add(classContent);
    }
  }

  isar.write((isar) {
    isar.classContents.putAll(classContents);
  });
}

ClassContent parseXML(XmlElement node, Isar isar) {
  final rootAttrs = node.attributes;

  ClassContent rtn = ClassContent(id: isar.classContents.autoIncrement());

  // attribute fields
  rtn.name = _getAttrByName(rootAttrs, 'name');
  // print("Processing class [${rtn.name}]");

  rtn.inherits = _getAttrByName(rootAttrs, 'inherits');

  rtn.category = _getAttrByName(rootAttrs, 'category');

  rtn.version = _getAttrByName(rootAttrs, 'version');

  rtn.briefDescription =
      node.findElements('brief_description').first.innerText.trim();

  rtn.description = node.findElements('description').first.innerText.trim();

  // constants
  final constantRoot = node.findElements('constants');
  if (constantRoot.length > 0) {
    final constantNodes = constantRoot.first.children;
    rtn.constants = constantNodes.whereType<XmlElement>().map((f) {
      final List<XmlAttribute?> nodeAttr = f.attributes;
      return Constant()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..value = _getAttrByName(nodeAttr, 'value')
        ..enumValue = _getAttrByName(nodeAttr, 'enum')
        ..constantText = f.innerText.trim();
    }).toList();
  }

  // members
  final memberRoot = node.findElements('members');
  if (memberRoot.length > 0) {
    final memberNodes = memberRoot.first.children;
    rtn.members = memberNodes.whereType<XmlElement>().map((f) {
      final List<XmlAttribute?> nodeAttr = f.attributes;
      return Member()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..type = _getAttrByName(nodeAttr, 'type')
        ..setter = _getAttrByName(nodeAttr, 'setter')
        ..getter = _getAttrByName(nodeAttr, 'getter')
        ..enumValue = _getAttrByName(nodeAttr, 'enum')
        ..memberText = f.innerText.trim();
    }).toList();
  }

  // methods
  final methodRoot = node.findElements('methods');
  if (methodRoot.length > 0) {
    final methodNodes = methodRoot.first.children;
    rtn.methods = methodNodes.whereType<XmlElement>().map((element) {
      // final element = f as XmlElement;
      final List<XmlAttribute?> nodeAttr = element.attributes;

      var args = element.findElements('argument');
      final argumentNodes =
          args.length > 0 ? args : element.findAllElements('param');
      final methodReturnNodes = element.findAllElements('return');

      MethodReturn? methodRtn;
      if (methodReturnNodes.length > 0) {
        final methodReturnAttr = methodReturnNodes.first.attributes;
        methodRtn = MethodReturn()
          ..type = _getAttrByName(methodReturnAttr, 'type')
          ..enumValue = _getAttrByName(methodReturnAttr, 'enum');
      }

      List<MethodArgument> _arguments = argumentNodes.map((a) {
        final argumentAttr = a.attributes;
        return MethodArgument()
          ..index = _getAttrByName(argumentAttr, 'index')
          ..name = _getAttrByName(argumentAttr, 'name')
          ..type = _getAttrByName(argumentAttr, 'type')
          ..enumValue = _getAttrByName(argumentAttr, 'enum')
          ..defaultValue = _getAttrByName(argumentAttr, 'default');
      }).toList();

      _arguments.sort((a, b) => a.index!.compareTo(b.index!));

      return Method()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..qualifiers = _getAttrByName(nodeAttr, 'qualifiers')
        ..description =
            element.findAllElements('description').first.innerText.trim()
        ..arguments = _arguments
        ..returnValue = methodRtn;
    }).toList();
  }

  // signals
  final signalRoot = node.findElements('signals');
  if (signalRoot.length > 0) {
    final signalNodes = signalRoot.first.children;
    rtn.signals = signalNodes.whereType<XmlElement>().map((element) {
      // final element = f as XmlElement;
      final List<XmlAttribute?> nodeAttr = element.attributes;
      final argumentNodes = element.findElements('argument');
      return Signal()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..description =
            element.findElements('description').first.innerText.trim()
        ..arguments = argumentNodes.map((a) {
          final argumentAttr = a.attributes;
          return SignalArgument()
            ..index = _getAttrByName(argumentAttr, 'index')
            ..name = _getAttrByName(argumentAttr, 'name')
            ..type = _getAttrByName(argumentAttr, 'type');
        }).toList();
    }).toList();
  }

  // theme_items
  final themeItemRoot = node.findElements('theme_items');
  if (themeItemRoot.length > 0) {
    final themeItemNodes = themeItemRoot.first.children;
    rtn.themeItems = themeItemNodes.whereType<XmlElement>().map((f) {
      final List<XmlAttribute?> nodeAttr = f.attributes;
      return ThemeItem()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..type = _getAttrByName(nodeAttr, 'type')
        ..description = f.innerText.trim();
    }).toList();
  }

  // annotations
  final annotationRoot = node.findElements('annotations');
  if (annotationRoot.length > 0) {
    final annotationNodes = annotationRoot.first.children;
    rtn.annotations = annotationNodes.whereType<XmlElement>().map((element) {
      final List<XmlAttribute?> nodeAttr = element.attributes;

      final argumentNodes = element.findElements("param");
      List<MethodArgument> args = argumentNodes.map((a) {
        final argumentAttr = a.attributes;
        return MethodArgument()
          ..index = _getAttrByName(argumentAttr, 'index')
          ..name = _getAttrByName(argumentAttr, 'name')
          ..type = _getAttrByName(argumentAttr, 'type')
          ..defaultValue = _getAttrByName(argumentAttr, 'default');
      }).toList();

      args.sort((a, b) => a.index!.compareTo(b.index!));

      MethodReturn? annReturn;
      final annReturnNodes = element.findAllElements("return");
      if (annReturnNodes.length > 0) {
        final annReturnAttr = annReturnNodes.first.attributes;
        annReturn = MethodReturn()
          ..type = _getAttrByName(annReturnAttr, 'type');
      }

      return Annotation()
        ..name = _getAttrByName(nodeAttr, 'name')
        ..params = args
        ..description =
            element.findAllElements('description').first.innerText.trim()
        ..annotationReturn = annReturn;
    }).toList();
  }

  return rtn;
}

String? _getAttrByName(List<XmlAttribute?> attrs, String attrName) {
  if (attrs.any((element) => element!.name.local == attrName)) {
    return attrs
        .firstWhere((element) => element!.name.local == attrName)
        ?.value;
  }
  return null;
}

void copySvg(String svgSourceFolder, String className, Isar isar) {
  final svgFilePath = findSvgFile(svgSourceFolder, className);
  if (svgFilePath != null && svgFilePath.isNotEmpty) {
    final svgFile = File(join(svgSourceFolder, svgFilePath));

    String svgContent = svgFile.readAsStringSync();

    svgContent =
        svgContent // 1. Remove XML comments: .replaceAll(RegExp(r''), '')
            // 2. Remove line breaks and tabs
            .replaceAll(RegExp(r'[\n\r\t]'), ' ')
            // 3. Collapse multiple spaces into one
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            // 4. Remove spaces between tags
            .replaceAll(RegExp(r'>\s+<'), '><')
            .trim();

    isar.write((isar) {
      isar.godotIcons.put(GodotIcon(
          id: isar.godotIcons.autoIncrement(),
          fileName: basename(svgFilePath),
          content: svgContent));
    });
    print("SVG file $svgFilePath copied");
  }
}

String? findSvgFile(String svgSourceFolder, String className) {
  // 1. Initial cleanup
  String cleanName = className.replaceAll(".xml", "");
  StringBuffer svgNameBuffer = StringBuffer();
  bool prevIsNumber = false;

  // 2. Build the snake_case name logic
  for (int i = 0; i < cleanName.length; i++) {
    String c = cleanName[i];

    if (c == "@") continue;

    // Check if character is uppercase or numeric
    bool isUpper = c.toUpperCase() == c && RegExp(r'[A-Z]').hasMatch(c);
    bool isNumeric = RegExp(r'[0-9]').hasMatch(c);

    if ((isUpper && !prevIsNumber) || isNumeric) {
      svgNameBuffer.write("_");
      svgNameBuffer.write(c.toLowerCase());
    } else {
      svgNameBuffer.write(c.toLowerCase());
    }

    prevIsNumber = isNumeric;
  }

  String svgName = svgNameBuffer.toString();

  // // 3. Define the source folder
  // String svgSourceFolder = join(godotRepo, "editor", "icons");
  // if (customPath) {
  //   svgSourceFolder = join(svgSourceFolder, "source");
  // }

  // 4. Try the first path (Standard Snake Case)
  String svgFile = 'icon$svgName.svg';
  String svgFilePath = join(svgSourceFolder, svgFile);

  if (!File(svgFilePath).existsSync()) {
    // 5. Try the Second path (Separated numbers: 2d -> 2_d)
    svgFile = svgFile
        .replaceAll("1d", "1_d")
        .replaceAll("2d", "2_d")
        .replaceAll("3d", "3_d");
    svgFilePath = join(svgSourceFolder, svgFile);

    if (!File(svgFilePath).existsSync()) {
      // 6. Try the Third path (Godot 4.0 style: Raw class name)
      svgFile = '$cleanName.svg';
      svgFilePath = join(svgSourceFolder, svgFile);

      if (!File(svgFilePath).existsSync()) {
        print("svg $svgFile not found");
        return null;
      }
    }
  }

  return svgFile;
}
