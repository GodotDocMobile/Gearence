import 'package:flutter/material.dart';
import '../theme/themes.dart';

class InlineCode extends StatelessWidget {
  final String? codeText;

  const InlineCode({Key? key, this.codeText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 2, right: 2),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        codeText!,
        style: monoOptionalStyle(context),
      ),
    );
  }
}
