import 'dart:io';

import 'package:godotclassreference/bloc/tap_event_arg.dart';
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
    var classContent = parseXML(node, isar);
    processSearchableItem(classContent, isar);
    copySvg(svgPath, classContent, isar);
    classContents.add(classContent);
  }

  parsePostProcess(classContents);

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

      var classContent = parseXML(xmlParsed.rootElement, isar);
      processSearchableItem(classContent, isar);
      copySvg(svgPath, classContent, isar);
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

      var classContent = parseXML(xmlParsed.rootElement, isar);
      processSearchableItem(classContent, isar);
      copySvg(svgPath, classContent, isar);
      classContents.add(classContent);
    }
  }

  parsePostProcess(classContents);

  isar.write((isar) {
    isar.classContents.putAll(classContents);
  });
}

void parsePostProcess(List<ClassContent> classContents) {
  final Map<String, ClassContent> classMap = {
    for (var c in classContents) c.name!: c
  };

  // 2. Iterate and pre-calculate the chain for every class
  for (var c in classContents) {
    c.inheritChain = buildChainString(c.inherits, classMap);
  }
}

String removeIndent(String input) {
  var lines = input.split('\n');
  if (lines.isEmpty) return input;

  // Find the minimum indentation (excluding empty lines)
  int? minIndent;
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    int indent = line.indexOf(RegExp(r'[^ \t]'));
    if (indent != -1 && (minIndent == null || indent < minIndent)) {
      minIndent = indent;
    }
  }

  if (minIndent == null || minIndent == 0) return input.trim();

  // Remove that common prefix from every line
  return lines
      .map((line) {
        return line.length >= minIndent! ? line.substring(minIndent) : line;
      })
      .join('\n')
      .trim();
}

String buildChainString(String? startParent, Map<String, ClassContent> map) {
  if (startParent == null || startParent.isEmpty) return "";

  List<String> chain = [];
  String? current = startParent;

  // Follow the breadcrumbs up to the root (Object)
  while (current != null && current.isNotEmpty) {
    chain.add("[$current]");

    // Look up the next ancestor
    final parentObj = map[current];
    current = parentObj?.inherits;
  }

  return chain.join(" >> ");
}

// void setNodeType(ClassContent classContent) {
//   for (var e in classNodeType.values) {
//     if ((classContent.inheritChain != null &&
//             classContent.inheritChain!.contains('[${getNodeName(e)}]')) ||
//         classContent.name == getNodeName(e)) {
//       classContent.nodeType = e;
//       return;
//     }
//   }
// }

void processSearchableItem(ClassContent classContent, Isar isar) {
  final String className = classContent.name!;
  final List<SearchableItem> searchableItems = [];

  // 1. Helper to create items consistently
  SearchableItem createItem(String name, PropertyType type) {
    return SearchableItem()
      ..id = isar.searchableItems.autoIncrement()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..className = className
      ..type = type;
  }

  // 2. Add the class itself as a searchable entry
  searchableItems.add(createItem(className, PropertyType.Class));

  // 3. Define a map of collections to their respective types
  // This replaces all those repetitive addAll blocks
  final propertyMap = {
    PropertyType.Constant: classContent.constants,
    PropertyType.Property: classContent.members,
    PropertyType.Method: classContent.methods,
    PropertyType.Signal: classContent.signals,
    PropertyType.ThemeItem: classContent.themeItems,
    PropertyType.Annotation: classContent.annotations,
  };

  // 4. Iterate and map
  for (var entry in propertyMap.entries) {
    final type = entry.key;
    final items = entry.value;

    searchableItems.addAll(items
        .where((dynamic i) => i.name != null)
        .map((dynamic i) => createItem(i.name!, type)));
  }

  isar.write((isar) {
    isar.searchableItems.putAll(searchableItems);
  });
}

ClassContent parseXML(XmlElement node, Isar isar) {
  // Use a helper for cleaner attribute access
  String? attr(XmlElement el, String name) => el.getAttribute(name);

// Use the shared normalization utility for both packaging and runtime
  String getTxt(XmlElement el, String tag) {
    final rawText = el.findElements(tag).firstOrNull?.innerText ?? "";

    // Replace .trim() with your robust normalization logic
    return removeIndent(rawText);
  }

  ClassContent rtn = ClassContent(id: isar.classContents.autoIncrement());

  rtn.name = attr(node, 'name');
  rtn.inherits = attr(node, 'inherits');
  rtn.category = attr(node, 'category');
  rtn.version = attr(node, 'version');

  rtn.briefDescription = getTxt(node, 'brief_description');
  rtn.description = getTxt(node, 'description');

  // Helper for mapping children to objects
  List<T> mapTags<T>(
      String parentTag, String childTag, T Function(XmlElement) mapper) {
    final parent = node.findElements(parentTag).firstOrNull;
    if (parent == null) return [];
    return parent.findElements(childTag).map(mapper).toList();
  }

  // Constants
  rtn.constants = mapTags(
      'constants',
      'constant',
      (el) => Constant()
        ..name = attr(el, 'name')
        ..value = attr(el, 'value')
        ..enumValue = attr(el, 'enum')
        ..constantText = removeIndent(el.innerText));

  // Members
  rtn.members = mapTags(
      'members',
      'member',
      (el) => Member()
        ..name = attr(el, 'name')
        ..type = attr(el, 'type')
        ..setter = attr(el, 'setter')
        ..getter = attr(el, 'getter')
        ..enumValue = attr(el, 'enum')
        ..memberText = removeIndent(el.innerText));

  // Methods (The most complex part)
  rtn.methods = mapTags('methods', 'method', (el) {
    // final methodAttr = el.attributes;

    // Support both old 'argument' and new 'param' tags
    final argNodes = el.findElements('param').isNotEmpty
        ? el.findElements('param')
        : el.findElements('argument');

    final returnNode = el.findElements('return').firstOrNull;

    final List<MethodArgument> args = argNodes
        .map((a) => MethodArgument()
          ..index = attr(a, 'index')
          ..name = attr(a, 'name')
          ..type = attr(a, 'type')
          ..enumValue = attr(a, 'enum')
          ..defaultValue = attr(a, 'default'))
        .toList();

    // Ensure arguments are in order
    args.sort((a, b) => (a.index ?? "0").compareTo(b.index ?? "0"));

    return Method()
      ..name = attr(el, 'name')
      ..qualifiers = attr(el, 'qualifiers')
      ..description = getTxt(el, 'description')
      ..arguments = args
      ..returnValue = returnNode == null
          ? null
          : (MethodReturn()
            ..type = attr(returnNode, 'type')
            ..enumValue = attr(returnNode, 'enum'));
  });

  // Signals
  rtn.signals = mapTags(
      'signals',
      'signal',
      (el) => Signal()
        ..name = attr(el, 'name')
        ..description = getTxt(el, 'description')
        ..arguments = el
            .findElements('argument')
            .map((a) => SignalArgument()
              ..index = attr(a, 'index')
              ..name = attr(a, 'name')
              ..type = attr(a, 'type'))
            .toList());

  // Theme Items
  rtn.themeItems = mapTags(
      'theme_items',
      'theme_item',
      (el) => ThemeItem()
        ..name = attr(el, 'name')
        ..type = attr(el, 'type')
        ..description = removeIndent(el.innerText));

// annotations (specifically for 4.x+)
  rtn.annotations = mapTags('annotations', 'annotation', (el) {
    // Annotations use 'param' for their arguments
    final argNodes = el.findElements('param');
    final returnNode = el.findElements('return').firstOrNull;

    final List<MethodArgument> args = argNodes
        .map((a) => MethodArgument()
          ..index = attr(a, 'index')
          ..name = attr(a, 'name')
          ..type = attr(a, 'type')
          ..defaultValue = attr(a, 'default'))
        .toList();

    // Standard ordering check
    args.sort((a, b) => (a.index ?? "0").compareTo(b.index ?? "0"));

    return Annotation()
      ..name = attr(el, 'name')
      ..description = getTxt(el, 'description')
      ..params = args
      ..annotationReturn = returnNode == null
          ? null
          : (MethodReturn()..type = attr(returnNode, 'type'));
  });

  return rtn;
}

void copySvg(String svgSourceFolder, ClassContent classContent, Isar isar) {
  final className = classContent.name!;
  final svgFileName = findSvgFile(svgSourceFolder, className);
  if (svgFileName != null && svgFileName.isNotEmpty) {
    classContent.svgFileName = svgFileName;
    final svgFile = File(join(svgSourceFolder, svgFileName));

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
          fileName: basename(svgFileName),
          content: svgContent));
    });
    print("SVG file $svgFileName copied");
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
