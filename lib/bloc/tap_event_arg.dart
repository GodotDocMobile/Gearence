import 'package:flutter/material.dart';

enum LinkType { Class, Method, Signal, Enum, Member, Constant, ThemeItem }

class TapEventArg {
  final LinkType linkType;
  final String className;
  final String fieldName;

  TapEventArg(
      {this.linkType, @required this.className, @required this.fieldName})
      : assert(className != null),
        assert(fieldName != null);

  String toString() {
    return 'class:' +
        className +
        ',type:' +
        linkType.toString() +
        ',field:' +
        fieldName;
  }
}

String linkTypeToString(LinkType input) {
  switch (input) {
    case LinkType.Enum:
      return 'Enums';
    case LinkType.Constant:
      return 'Constants';
    case LinkType.Member:
      return 'Members';
    case LinkType.Method:
      return 'Methods';
    case LinkType.Signal:
      return 'Signals';
    case LinkType.ThemeItem:
      return 'Theme Items';
    case LinkType.Class:
    default:
      return 'Info';
  }
}

LinkType linkTypeFromString(String input) {
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
    case 'theme items':
      return LinkType.ThemeItem;
    default:
      return null;
  }
}
