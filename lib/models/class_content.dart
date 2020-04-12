import 'package:xml/xml.dart';

import 'constant.dart';
import 'member.dart';
import 'method.dart';
import 'signal.dart';
import 'theme_item.dart';

class ClassContent {
  String name;
  String inherits;
  String category;
  String version;
  String briefDescription;
  String demos;
  List<Constant> constants;
  String description;
  List<Member> members;
  List<Method> methods;
  List<Signal> signals;
  List<ThemeItem> themeItems;
  String tutorials;

  ClassContent(
      {this.name,
      this.inherits,
      this.category,
      this.version,
      this.briefDescription,
      this.demos,
      this.constants,
      this.description,
      this.members,
      this.methods,
      this.signals,
      this.themeItems,
      this.tutorials});

  static ClassContent fromJson(XmlElement node) {
    ClassContent toReturn = ClassContent();

    final rootAttrs = node.attributes;
    final childNodes = node.children;
    // attribute fields
    toReturn.name = _getAttrByName(rootAttrs, 'name');

    toReturn.inherits = _getAttrByName(rootAttrs, 'inherits');

    toReturn.category = _getAttrByName(rootAttrs, 'category');

    toReturn.version = _getAttrByName(rootAttrs, 'version');

    toReturn.briefDescription =
        node.findElements('brief_description').first.text;

    // constants
    final constantNode = node.findElements('constants').first;
    if (constantNode != null) {
      toReturn.constants = constantNode.children.map((f) {
        final nodeAttr = f.attributes;
        return Constant(
            name: _getAttrByName(nodeAttr, 'name'),
            value: _getAttrByName(nodeAttr, 'value'),
            enumValue: _getAttrByName(nodeAttr, 'enum'),
            constantText: f.text);
      }).toList();
    }

    toReturn.description = node.findElements('description').first.text;

    // members
    final memberNode = node.findElements('members').first;
    toReturn.members = memberNode.children.map((f) {
      final nodeAttr = f.attributes;
      return Member(
          name: _getAttrByName(nodeAttr, 'name'),
          type: _getAttrByName(nodeAttr, 'type'),
          setter: _getAttrByName(nodeAttr, 'setter'),
          getter: _getAttrByName(nodeAttr, 'getter'),
          enumValue: _getAttrByName(nodeAttr, 'enum'),
          memberText: f.text);
    }).toList();

    // methods
    final methodNode = node.findElements('methods').first;
    toReturn.methods = methodNode.children.map((f) {
      final nodeAttr = f.attributes;
      final argumentNodes = f.document.findElements('argument');
      final methodReturnNodes = f.document.findElements('return');

      MethodReturn methodRtn;
      if (methodReturnNodes.length > 0) {
        final methodReturnAttr = methodReturnNodes.first.attributes;
        methodRtn = MethodReturn(
          type: _getAttrByName(methodReturnAttr, 'type'),
          enumValue: _getAttrByName(methodReturnAttr, 'enum'),
        );
      }

      final a = f.document.findElements('description');
      return Method(
          name: _getAttrByName(nodeAttr, 'name'),
          qualifiers: _getAttrByName(nodeAttr, 'qualifiers'),
          // TODO: fix here with 3.0/AABB.xml
          description: f.document.findElements('description')?.first?.text,
          arguments: argumentNodes.map((a) {
            final argumentAttr = a.attributes;
            return MethodArgument(
                index: _getAttrByName(argumentAttr, 'index'),
                name: _getAttrByName(argumentAttr, 'name'),
                type: _getAttrByName(argumentAttr, 'type'),
                enumValue: _getAttrByName(argumentAttr, 'enum'),
                defaultValue: _getAttrByName(argumentAttr, 'default'));
          }).toList(),
          returnValue: methodRtn);
    }).toList();

    // signals
    final signalNode = node.findElements('signals').first;
    toReturn.signals = signalNode.children.map((f) {
      final nodeAttr = f.attributes;
      final argumentNodes = f.document.findElements('argument');
      return Signal(
          name: _getAttrByName(nodeAttr, 'name'),
          description: f.document.findElements('argument').first.text,
          arguments: argumentNodes.map((a) {
            final argumentAttr = a.attributes;
            return SignalArgument(
                index: _getAttrByName(argumentAttr, 'index'),
                name: _getAttrByName(argumentAttr, 'name'),
                type: _getAttrByName(argumentAttr, 'type'));
          }));
    }).toList();

    return toReturn;
  }

  static String _getAttrByName(List<XmlAttribute> attrs, String attrName) {
    return attrs.singleWhere((w) => w.name.local == attrName, orElse: () {
      return null;
    })?.value;
  }
}
