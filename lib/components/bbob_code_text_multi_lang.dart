import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/arduino-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/theme/themes.dart';

class BBOBCodeTextMultiLang extends StatefulWidget {
  final bbob.Element bbobElement;
  const BBOBCodeTextMultiLang({Key? key, required this.bbobElement})
      : super(key: key);

  @override
  State<BBOBCodeTextMultiLang> createState() => _BBOBCodeTextMultiLangState();
}

class _BBOBCodeTextMultiLangState extends State<BBOBCodeTextMultiLang> {
  int tabIndex = 0;
  String gdScriptCodeText = '';
  String cSharpScriptCOdeText = '';

  @override
  void initState() {
    for (var c in widget.bbobElement.children) {
      if (c.runtimeType == bbob.Element) {
        var e = c as bbob.Element;
        if (e.tag == 'gdscript') {
          gdScriptCodeText = e.textContent;
        } else {
          cSharpScriptCOdeText = e.textContent;
        }
      }
    }
    super.initState();
  }

  Widget codeDisplayWidget() {
    switch (tabIndex) {
      case 0:
        return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                gdScriptCodeText,
                language: 'gdscript',
                textStyle: scaledTextStyle(context)
                    .copyWith(fontFamily: 'JetbrainsMono'),
                theme: storedValues.isDarkTheme
                    ? atomOneDarkTheme
                    : arduinoLightTheme,
                padding: EdgeInsets.all(10),
              ),
            ));
      case 1:
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          }),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              cSharpScriptCOdeText,
              language: 'csharp',
              textStyle: scaledTextStyle(context)
                  .copyWith(fontFamily: 'JetbrainsMono'),
              theme: storedValues.isDarkTheme
                  ? atomOneDarkTheme
                  : arduinoLightTheme,
              padding: EdgeInsets.all(10),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 3),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "GDScript",
                      style: TextStyle(
                          color: storedValues.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "CSharp",
                      style: TextStyle(
                          color: storedValues.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ],
              onTap: (value) {
                setState(() {
                  tabIndex = value;
                });
              },
            ),
          ),
          codeDisplayWidget(),
        ]),
      ),
    );
  }
}
