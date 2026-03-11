import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';

import 'package:godotclassreference/theme/themes.dart';

class NodeTag extends StatelessWidget {
  final ClassContent? classContent;

  const NodeTag({Key? key, this.classContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: nonScaledMediaQueryData(context),
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: tagColor[classContent!.nodeType],
            borderRadius: BorderRadius.circular(5),
          ),
          width: 50,
          height: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tagColor[classContent!.nodeType] ?? Colors.blueGrey,
              borderRadius:
                  BorderRadius.circular(4), // Slightly sharper fits Godot style
            ),
            child: Text(
              tagName[classContent!.nodeType] ?? 'Node',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, // Reduced slightly to feel less "cramped"
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
