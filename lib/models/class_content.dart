import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/annotation.dart';
import 'package:xml/xml.dart';

import 'constant.dart';
import 'member.dart';
import 'method.dart';
import 'method_argument.dart';
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
String getNodeName(classNodeType nodeType) {
  switch (nodeType) {
    case classNodeType.D2:
      return "Node2D";
    case classNodeType.D3:
      return storedValues.version == '4.0' ? "Node3D" : "Spatial";
    case classNodeType.Control:
      return "Control";
    case classNodeType.VisualScript:
      return "VisualScriptNode";
    case classNodeType.VisualShader:
      return "VisualShaderNode";
    case classNodeType.Other:
      return "Node";
    case classNodeType.None:
      return "";
  }
}

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
  List<Annotation> annotations = [];
  String? tutorials;

  /* the following properties are not in xml files,
   need to be set by hand or by external program */
  classNodeType nodeType = classNodeType.None;
  String? inheritChain;
  String? svgFileName;

  // this was caculated in run time, maybe we can move this to the python script
  String? xmlFilePath;

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

    this.briefDescription =
        node.findElements('brief_description').first.innerText;

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
            constantText: f.innerText);
      }).toList();
    }

    this.description = node.findElements('description').first.innerText;

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
            memberText: f.innerText);
      }).toList();
    }

    // methods
    final methodRoot = node.findElements('methods');
    if (methodRoot.length > 0) {
      final methodNodes = methodRoot.first.children;
      this.methods = methodNodes.map((f) {
        final element = f as XmlElement;
        final List<XmlAttribute?> nodeAttr = f.attributes;

        var args = element.findElements('argument');
        final argumentNodes =
            args.length > 0 ? args : element.findAllElements('param');
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
            description: element.findAllElements('description').first.innerText,
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
            description: element.findElements('description').first.innerText,
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

    // annotations
    final annotationRoot = node.findElements('annotations');
    if (annotationRoot.length > 0) {
      final annotationNodes = annotationRoot.first.children;
      this.annotations = annotationNodes.map((f) {
        final element = f as XmlElement;
        final List<XmlAttribute?> nodeAttr = f.attributes;

        final argumentNodes = element.findElements("param");
        List<MethodArgument> args = argumentNodes.map((a) {
          final argumentAttr = a.attributes;
          return MethodArgument(
              index: _getAttrByName(argumentAttr, 'index'),
              name: _getAttrByName(argumentAttr, 'name'),
              type: _getAttrByName(argumentAttr, 'type'),
              defaultValue: _getAttrByName(argumentAttr, 'default'));
        }).toList();

        args.sort((a, b) => a.index!.compareTo(b.index!));

        MethodReturn? annReturn;
        final annReturnNodes = element.findAllElements("return");
        if (annReturnNodes.length > 0) {
          final annReturnAttr = annReturnNodes.first.attributes;
          annReturn = MethodReturn(
            type: _getAttrByName(annReturnAttr, 'type'),
          );
        }

        return Annotation(
            name: _getAttrByName(nodeAttr, 'name'),
            params: args,
            description: element.findAllElements('description').first.innerText,
            annotationReturn: annReturn);
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
              this.inheritChain!.contains('[${getNodeName(e)}]')) ||
          this.name == getNodeName(e)) {
        this.nodeType = e;
        return;
      }
    }
  }
}
