import 'package:flutter/cupertino.dart';

enum LinkType { Class, Method, Signal, Enum, Member, Constant }

class TapEventArg {
  final LinkType linkType;
  final String className;
  final String fieldName;

  TapEventArg(
      {this.linkType, @required this.className, @required this.fieldName})
      : assert(className != null),
        assert(fieldName != null);
}

String linkTypeToString(LinkType input) {
  switch (input) {
    case LinkType.Constant:
      return 'Constants';
    case LinkType.Member:
      return 'Members';
    case LinkType.Method:
      return 'Methods';
    case LinkType.Signal:
      return 'Signa';
    case LinkType.Class:
    default:
      return 'Info';
  }
}

LinkType linkTypeFromString(String input) {
  print(input);
  switch (input.trimRight().trimLeft().toLowerCase()) {
    case 'class':
      return LinkType.Class;
    case 'method':
      return LinkType.Method;
    case 'signal':
      return LinkType.Signal;
    case 'enum':
      return LinkType.Enum;
    case 'member':
      return LinkType.Member;
    case 'constant':
      return LinkType.Constant;
    default:
      return null;
  }
}
