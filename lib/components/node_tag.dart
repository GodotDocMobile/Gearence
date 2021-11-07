import 'package:flutter/material.dart';

import '../models/class_content.dart';

class NodeTag extends StatelessWidget {
  final ClassContent? classContent;

  const NodeTag({Key? key, this.classContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        decoration: BoxDecoration(
          color: tagColor[classContent!.nodeType],
          borderRadius: BorderRadius.circular(5),
        ),
        width: 45,
        height: 20,
        child: Center(
          child: Text(
            tagName[classContent!.nodeType]!,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
