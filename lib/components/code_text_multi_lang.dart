import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/arduino-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/constants/stored_values.dart';

class CodeTextMultiLang extends StatefulWidget {
  final String codeTextWithBBCode;

  const CodeTextMultiLang({Key? key, required this.codeTextWithBBCode})
      : super(key: key);

  @override
  State<CodeTextMultiLang> createState() => _CodeTextMultiLangState();
}

class _CodeTextMultiLangState extends State<CodeTextMultiLang> {
  // bool displayGDScriptCode = true;
  int tabIndex = 0;

  String gdScriptCodeText = '';
  String cSharpScriptCOdeText = '';

  @override
  void initState() {
    super.initState();

    final gdScriptTagStart = widget.codeTextWithBBCode.indexOf('[gdscript]');
    final gdScriptTagEnd = widget.codeTextWithBBCode.indexOf('\n[/gdscript]');
    gdScriptCodeText = widget.codeTextWithBBCode
        .substring(gdScriptTagStart + '[gdscript]\n'.length, gdScriptTagEnd);

    final cSharpTagStart = widget.codeTextWithBBCode.indexOf('[csharp]');
    final cSharpTagEnd = widget.codeTextWithBBCode.indexOf('\n[/csharp]');
    cSharpScriptCOdeText = widget.codeTextWithBBCode
        .substring(cSharpTagStart + '[csharp]\n'.length, cSharpTagEnd);
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
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                      color: storedValues.isDarkTheme
                          ? Colors.black45
                          : Colors.white54),
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
                  decoration: BoxDecoration(
                      color: storedValues.isDarkTheme
                          ? Colors.black45
                          : Colors.white54),
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
    );
  }
}
