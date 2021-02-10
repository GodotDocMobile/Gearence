import 'package:flutter/material.dart';

class CodeText extends StatelessWidget {
  final String codeText;

  const CodeText({Key key, this.codeText}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: BoxConstraints(minWidth: double.infinity),
        decoration: BoxDecoration(
          color: Colors.black12,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(codeText),
      ),
    );
  }
}
