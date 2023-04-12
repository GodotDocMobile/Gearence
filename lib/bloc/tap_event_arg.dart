enum PropertyType {
  Class,
  Method,
  Signal,
  Enum,
  Member,
  Constant,
  ThemeItem,
  Annotation,
}

class TapEventArg {
  final PropertyType? propertyType;
  final String className;
  final String fieldName;

  TapEventArg(
      {this.propertyType, required this.className, required this.fieldName});

  String toString() {
    return 'class:' +
        className +
        ',type:' +
        propertyType.toString() +
        ',field:' +
        fieldName;
  }
}

String linkTypeToString(PropertyType? input) {
  switch (input) {
    case PropertyType.Enum:
      return 'Enums';
    case PropertyType.Constant:
      return 'Constants';
    case PropertyType.Member:
      return 'Members';
    case PropertyType.Method:
      return 'Methods';
    case PropertyType.Signal:
      return 'Signals';
    case PropertyType.ThemeItem:
      return 'Theme Items';
    case PropertyType.Annotation:
      return "Annotations";
    case PropertyType.Class:
    default:
      return 'Info';
  }
}

PropertyType? linkTypeFromString(String input) {
  switch (input.trimRight().trimLeft().toLowerCase()) {
    case 'class':
      return PropertyType.Class;
    case 'method':
      return PropertyType.Method;
    case 'signal':
      return PropertyType.Signal;
    case 'enum':
      return PropertyType.Enum;
    case 'member':
      return PropertyType.Member;
    case 'constant':
      return PropertyType.Constant;
    case 'theme items':
      return PropertyType.ThemeItem;
    case "annotation":
      return PropertyType.Annotation;
    default:
      return null;
  }
}
