import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:godotclassreference/theme/default.dart';
import 'package:godotclassreference/theme/themes.dart';

import '../constants/stored_values.dart';

class CodeText extends StatelessWidget {
  final String? codeText;

  const CodeText({Key? key, this.codeText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          // color: Colors.red,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 3)]
          // border: Border.all(color: Colors.grey),
          ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          codeText!,
          language: 'gdscript',
          textStyle: scaledTestStyle(context),
          theme: StoredValues().themeChange.isDark
              ? atomOneDarkTheme
              : githubTheme,
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
