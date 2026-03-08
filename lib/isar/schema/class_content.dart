import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:isar_plus/isar_plus.dart';

part 'class_content.g.dart';

enum classNodeType {
  D2,
  D3,
  Control,
  VisualScript,
  VisualShader,
  // these two has to be in the tail
  Other,
  None,
}

@collection
class SearchableItem {
  late final int id;

  @Index()
  late String name;

  late String className;

  late PropertyType type; // Class, Method, Signal, etc.

  // Store a lower-case version for instant case-insensitive searching
  @Index(hash: true)
  late String nameLower;
}

@collection
class Translation {
  final int id;

  @Index(unique: true)
  String? msgid;

  // List of translations for different languages
  List<LocaleString>? translations;

  Translation({required this.id});
}

@collection
class GodotIcon {
  final int id;

  @Index(unique: true)
  final String fileName;

  final String content;
  GodotIcon({required this.id, required this.fileName, required this.content});
}

@collection
class ClassContent {
  final int id;

  @Index(unique: true)
  String? name;

  String? inherits;
  String? category;
  String? version;
  String? briefDescription;
  String? demos;
  String? description;
  String? tutorials;

  @ignore
  classNodeType nodeType = classNodeType.None;

  String? inheritChain;
  String? svgFileName;

  String? xmlFilePath;
  ClassContent({required this.id});

  List<Constant> constants = [];
  List<Member> members = [];
  List<Method> methods = [];
  List<Signal> signals = [];
  List<ThemeItem> themeItems = [];
  List<Annotation> annotations = [];
}

@embedded
class Constant {
  String? name;
  String? value;
  String? enumValue;
  String? constantText;
}

@embedded
class Member {
  String? name;
  String? type;
  String? setter;
  String? getter;
  String? enumValue;
  String? memberText;
}

@embedded
class Method {
  String? description;
  String? name;
  String? qualifiers;

  List<MethodArgument>? arguments;
  MethodReturn? returnValue;
}

@embedded
class MethodReturn {
  String? type;
  String? enumValue;
}

@embedded
class MethodArgument {
  String? index;
  String? name;
  String? type;
  String? enumValue;
  String? defaultValue;
}

@embedded
class Signal {
  String? name;
  String? description;

  List<SignalArgument>? arguments;
}

@embedded
class SignalArgument {
  String? index;
  String? name;
  String? type;
}

@embedded
class ThemeItem {
  String? name;
  String? type;
  String? description;
}

@embedded
class Annotation {
  String? name = '';
  List<MethodArgument>? params = [];
  String? description = '';
  MethodReturn? annotationReturn;
}

@embedded
class LocaleString {
  String? locale; // e.g., 'zh_CN'
  String? value; // The translated text
}
