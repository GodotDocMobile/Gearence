import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/arduino-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/theme/themes.dart';

class BBOBCodeText extends StatelessWidget {
  final bbob.Node bbobNode;
  const BBOBCodeText({Key? key, required this.bbobNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 3)]),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: HighlightView(
            bbobNode.textContent,
            language: 'gdscript',
            textStyle:
                scaledTextStyle(context).copyWith(fontFamily: 'JetbrainsMono'),
            theme:
                storedValues.isDarkTheme ? atomOneDarkTheme : arduinoLightTheme,
            padding: EdgeInsets.all(10),
          ),
        ),
      ),
    );
  }
}
