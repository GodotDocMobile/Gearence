import 'package:flutter/material.dart';

class TypeName extends StatelessWidget {
  final String typeName;
  final String? notRender;

  TypeName({Key? key, this.notRender, required this.typeName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(typeName);
  }
}
