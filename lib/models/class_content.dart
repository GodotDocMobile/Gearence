import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'constant.dart';
import 'member.dart';
import 'method.dart';
import 'signal.dart';
import 'theme_item.dart';

// names for node tag used in node_tag
final Map<classNodeType, String> tagName = {
  classNodeType.D2: "Node",
  classNodeType.D3: "Node",
  classNodeType.Control: "Node",
  classNodeType.VisualScript: "VScript",
  classNodeType.VisualShader: "VShader",
  classNodeType.Other: "Node",
  classNodeType.None: "",
};

// color for node tag used in node_tag
final Map<classNodeType, Color> tagColor = {
  classNodeType.D2: Color(0xffa5b7f3),
  classNodeType.D3: Color(0xfffc9c9c),
  classNodeType.Control: Color(0xffa5efac),
  classNodeType.VisualScript: Colors.blueGrey,
  classNodeType.VisualShader: Colors.blueGrey,
  classNodeType.Other: Colors.blueGrey,
  classNodeType.None: Colors.blueGrey,
};

// names for class_select filter classes pop up
final Map<classNodeType, String> filterName = {
  classNodeType.D2: "2D Nodes",
  classNodeType.D3: "3D Nodes",
  classNodeType.Control: "Control Nodes",
  classNodeType.VisualScript: "Visual Script Nodes",
  classNodeType.VisualShader: "Visual Shader Nodes",
  classNodeType.Other: "Other Nodes",
  classNodeType.None: "None Nodes",
};

// names for StoredValues
final Map<classNodeType, String> filterOptionStoreKey = {
  classNodeType.D2: "show2DNodes",
  classNodeType.D3: "show3DNodes",
  classNodeType.Control: "showControlNodes",
  classNodeType.VisualScript: "showVisualScriptNodes",
  classNodeType.VisualShader: "showVisualShaderNodes",
  classNodeType.Other: "showOtherNodes",
  classNodeType.None: "showNonNodes",
};

// names of nodes to categorize them for filtering
final Map<classNodeType, String> nodeName = {
  classNodeType.D2: "Node2D",
  classNodeType.D3: "Spatial",
  classNodeType.Control: "Control",
  classNodeType.VisualScript: "VisualScriptNode",
  classNodeType.VisualShader: "VisualShaderNode",
  classNodeType.Other: "Node",
  classNodeType.None: "",
};

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

class ClassContent {
  String? name;
  String? inherits;
  String? category;
  String? version;
  String? briefDescription;
  String? demos;
  List<Constant> constants = [];
  String? description;
  List<Member> members = [];
  List<Method> methods = [];
  List<Signal> signals = [];
  List<ThemeItem> themeItems = [];
  String? tutorials;

  /* the following properties are not in xml files,
   need to be set by hand or by external program */
  classNodeType nodeType = classNodeType.None;
  String? inheritChain;
  String? svgFileName;

  ClassContent(
      {this.name,
      this.inherits,
      this.category,
      this.version,
      this.briefDescription,
      this.demos,
      this.description,
      this.tutorials,
      this.inheritChain,
      this.svgFileName});

  static void fromJson(json) {}

  void fromXml(XmlElement node) {
    final rootAttrs = node.attributes;

    // attribute fields
    this.name = _getAttrByName(rootAttrs, 'name');

    this.inherits = _getAttrByName(rootAttrs, 'inherits');

    this.category = _getAttrByName(rootAttrs, 'category');

    this.version = _getAttrByName(rootAttrs, 'version');

    this.briefDescription = node.findElements('brief_description').first.text;

    // constants
    final constantRoot = node.findElements('constants');
    if (constantRoot.length > 0) {
      final constantNodes = constantRoot.first.children;
      this.constants = constantNodes.map((f) {
        final List<XmlAttribute?> nodeAttr = f.attributes;
        return Constant(
            name: _getAttrByName(nodeAttr, 'name'),
            value: _getAttrByName(nodeAttr, 'value'),
            enumValue: _getAttrByName(nodeAttr, 'enum'),
            constantText: f.text);
      }).toList();
    }

    this.description = node.findElements('description').first.text;

    // members
    final memberRoot = node.findElements('members');
    if (memberRoot.length > 0) {
      final memberNodes = memberRoot.first.children;
      this.members = memberNodes.map((f) {
        final List<XmlAttribute?> nodeAttr = f.attributes;
        return Member(
            name: _getAttrByName(nodeAttr, 'name'),
            type: _getAttrByName(nodeAttr, 'type'),
            setter: _getAttrByName(nodeAttr, 'setter'),
            getter: _getAttrByName(nodeAttr, 'getter'),
            enumValue: _getAttrByName(nodeAttr, 'enum'),
            memberText: f.text);
      }).toList();
    }

    // methods
    final methodRoot = node.findElements('methods');
    if (methodRoot.length > 0) {
      final methodNodes = methodRoot.first.children;
      this.methods = methodNodes.map((f) {
        final element = f as XmlElement;
        final List<XmlAttribute?> nodeAttr = f.attributes;

        final argumentNodes = element.findElements('argument');
        final methodReturnNodes = element.findAllElements('return');

        MethodReturn? methodRtn;
        if (methodReturnNodes.length > 0) {
          final methodReturnAttr = methodReturnNodes.first.attributes;
          methodRtn = MethodReturn(
            type: _getAttrByName(methodReturnAttr, 'type'),
            enumValue: _getAttrByName(methodReturnAttr, 'enum'),
          );
        }

        List<MethodArgument> _arguments = argumentNodes.map((a) {
          final argumentAttr = a.attributes;
          return MethodArgument(
              index: _getAttrByName(argumentAttr, 'index'),
              name: _getAttrByName(argumentAttr, 'name'),
              type: _getAttrByName(argumentAttr, 'type'),
              enumValue: _getAttrByName(argumentAttr, 'enum'),
              defaultValue: _getAttrByName(argumentAttr, 'default'));
        }).toList();

        _arguments.sort((a, b) => a.index!.compareTo(b.index!));

        return Method(
            name: _getAttrByName(nodeAttr, 'name'),
            qualifiers: _getAttrByName(nodeAttr, 'qualifiers'),
            description: element.findAllElements('description').first.text,
            arguments: _arguments,
            returnValue: methodRtn);
      }).toList();
    }

    // signals
    final signalRoot = node.findElements('signals');
    if (signalRoot.length > 0) {
      final signalNodes = signalRoot.first.children;
      this.signals = signalNodes.map((f) {
        final element = f as XmlElement;
        final List<XmlAttribute?> nodeAttr = f.attributes;
        final argumentNodes = element.findElements('argument');
        return Signal(
            name: _getAttrByName(nodeAttr, 'name'),
            description: element.findElements('description').first.text,
            arguments: argumentNodes.map((a) {
              final argumentAttr = a.attributes;
              return SignalArgument(
                  index: _getAttrByName(argumentAttr, 'index'),
                  name: _getAttrByName(argumentAttr, 'name'),
                  type: _getAttrByName(argumentAttr, 'type'));
            }).toList());
      }).toList();
    }

    // theme_items
    final themeItemRoot = node.findElements('theme_items');
    if (themeItemRoot.length > 0) {
      final themeItemNodes = themeItemRoot.first.children;
      this.themeItems = themeItemNodes.map((f) {
        final List<XmlAttribute?> nodeAttr = f.attributes;
        return ThemeItem(
            name: _getAttrByName(nodeAttr, 'name'),
            type: _getAttrByName(nodeAttr, 'type'));
      }).toList();
    }
  }

  static String? _getAttrByName(List<XmlAttribute?> attrs, String attrName) {
    if (attrs.any((element) => element!.name.local == attrName)) {
      return attrs
          .firstWhere((element) => element!.name.local == attrName)
          ?.value;
    }
    return null;
  }

  void setNodeType() {
    for (var e in classNodeType.values) {
      if ((this.inheritChain != null &&
              this.inheritChain!.contains('[${nodeName[e]}]')) ||
          this.name == nodeName[e]) {
        this.nodeType = e;
        return;
      }
    }
  }
}
