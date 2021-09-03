import 'package:flutter/material.dart';

import '../models/class_content.dart';

class NodeTag extends StatelessWidget {
  final ClassContent classContent;

  const NodeTag({Key key, this.classContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool visualScript = false;
    Color _backColor = Colors.blueGrey;

    if (classContent.belong('Node2D')) {
      _backColor = Color(0xffa5b7f3);
    } else if (classContent.belong('Spatial')) {
      _backColor = Color(0xfffc9c9c);
    } else if (classContent.belong('Control')) {
      _backColor = Color(0xffa5efac);
    } else if (classContent.belong('VisualScriptNode')) {
      visualScript = true;
    }

    return Container(
      decoration: BoxDecoration(
        color: _backColor,
        borderRadius: BorderRadius.circular(5),
      ),
      width: 45,
      height: 20,
      child: Center(
        child: Text(
          visualScript ? "Visual" : "Node",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
