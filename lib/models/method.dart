class MethodArgument {
  String? index;
  String? name;
  String? type;
  String? enumValue;
  String? defaultValue;

  MethodArgument(
      {this.index, this.name, this.type, this.enumValue, this.defaultValue});
}

class MethodReturn {
  String? type;
  String? enumValue;

  MethodReturn({this.type, this.enumValue});
}

class Method {
  String? description;
  String? name;
  String? qualifiers;

  List<MethodArgument>? arguments;
  MethodReturn? returnValue;

  Method(
      {this.name,
      this.qualifiers,
      this.arguments,
      this.returnValue,
      this.description});
}
