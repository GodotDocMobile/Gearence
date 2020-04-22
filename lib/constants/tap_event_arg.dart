import 'package:flutter/cupertino.dart';

enum LinkType { Class, Method, Signal, Enum, Member }

class TapEventArg {
  final LinkType linkType;
  final String className;
  final String fieldName;

  TapEventArg(
      {this.linkType, @required this.className, @required this.fieldName})
      : assert(className != null),
        assert(fieldName != null);
}
