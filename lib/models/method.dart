import 'method_argument.dart';

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
