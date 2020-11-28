import 'package:flutter/material.dart';

class NodeTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(5),
      ),
      width: 45,
      height: 20,
      child: Center(
        child: Text(
          "Node",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
