import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/themes.dart';
import '../components/code_text.dart';
import '../components/inline_code.dart';
import '../constants/class_db.dart';
import '../constants/colors.dart';
import '../constants/stored_values.dart';
import '../bloc/tap_event_arg.dart';

//logic check godot/editor/editor_help.cpp _add_text_to_rt

class DescriptionText extends StatelessWidget {
  final String className;
  final String content;
  final Function(TapEventArg args) onLinkTap;
  final TextStyle? style;

  DescriptionText(
      {Key? key,
      required this.className,
      required this.content,
      required this.onLinkTap,
      this.style})
      : super(key: key);

  // this is a full implementation of _add_text_to_rt
  List<InlineSpan> _parseText(BuildContext context) {
    List<InlineSpan> _toRtn = [];

    List<String> tagStack = [];
    bool codeTag = false;
    bool inlineCode = false;
    int pos = 0;

    TextStyle _toApplyStyle = scaledTestStyle(context);
    while (pos < content.length) {
      int brkPos = content.indexOf('[', pos);

      if (brkPos < 0) {
        brkPos = content.length;
      }

      if (brkPos > pos) {
        String text = content.substring(pos, brkPos);
        if (codeTag) {
          // in case there are a '[' in code
          while (!content.substring(brkPos).startsWith('[/code')) {
            brkPos = content.indexOf('[', brkPos + 1);
          }
          text = content.substring(pos, brkPos);

          _toRtn.add(WidgetSpan(
            child: CodeText(
              codeText: text,
            ),
          ));
        } else if (inlineCode) {
          _toRtn.add(WidgetSpan(
            child: InlineCode(
              codeText: text,
            ),
          ));
        } else {
          if (text.characters.last == '\n') {
            text = text.substring(0, text.length - 1);
          }
          _toRtn.add(TextSpan(
              text: text.replaceAll('\n', '\n\n'), style: _toApplyStyle));
        }
        _toApplyStyle = scaledTestStyle(context);
      }

      if (brkPos == content.length) {
        break; // nothing else to add
      }

      int brkEnd = content.indexOf(']', brkPos + 1);

      if (brkEnd == -1) {
        String text = content.substring(brkPos, content.length);
        if (!codeTag) {
          text = text.replaceAll('\n', '\n\n');
        }
        _toRtn.add(TextSpan(text: text));

        break;
      }

      String tag = content.substring(brkPos + 1, brkEnd);

      if (tag.startsWith('/')) {
        bool tagOK = tagStack.length > 0 &&
            tagStack.last == tag.substring(1, tag.length);
        if (!tagOK) {
          _toRtn.add(TextSpan(text: '['));
          pos = brkPos + 1;
          continue;
        }

        tagStack.removeAt(0);
        pos = brkEnd + 1;
        codeTag = false;
        inlineCode = false;
//        if (tag != '/img') {
//          _toRtn.removeLast();
//        }
      } else if (codeTag) {
        _toRtn.add(TextSpan(text: '['));
        pos = brkPos + 1;
      } else if (tag.startsWith('method ') ||
          tag.startsWith('member ') ||
          tag.startsWith('signal ') ||
          tag.startsWith('enum ') ||
          tag.startsWith('constant ')) {
        String linkTarget = tag.substring(tag.indexOf(' ') + 1, tag.length);
//        String linkTag = tag.substring(0, tag.indexOf(' ')).padRight(6);
        _toRtn.add(
          TextSpan(
            text: linkTarget + (tag.startsWith('method ') ? '()' : ''),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                TapEventArg args = TapEventArg(
                    linkType: linkTypeFromString(tag.split(' ').first),
                    className: linkTarget.contains('.')
                        ? linkTarget.split('.').first
                        : className,
                    fieldName: linkTarget.contains('.')
                        ? linkTarget.split('.').last
                        : linkTarget);
                this.onLinkTap(args);
              },
            style: _toApplyStyle.copyWith(color: godotColor),
          ),
        );
        pos = brkEnd + 1;
      } else if (ClassDB().getDB().any((element) => element.name == tag)) {
        _toRtn.add(
          TextSpan(
            text: tag,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                TapEventArg args = TapEventArg(
                  linkType: LinkType.Class,
                  className: tag,
                  fieldName: '',
                );
                this.onLinkTap(args);
              },
            style: _toApplyStyle.copyWith(
                color: tag == className
                    ? (StoredValues().themeChange.currentTheme() ==
                            ThemeMode.dark
                        ? Colors.white
                        : Colors.black)
                    : godotColor),
          ),
        );
        pos = brkEnd + 1;
      } else if (tag == 'b') {
        // bold
        pos = brkEnd + 1;
        tagStack.add(tag);
        _toApplyStyle = _toApplyStyle.copyWith(fontWeight: FontWeight.bold);
      } else if (tag == 'i') {
        // italic
        pos = brkEnd + 1;
        tagStack.add(tag);
        _toApplyStyle = _toApplyStyle.copyWith(fontStyle: FontStyle.italic);
      } else if (tag == 'codeblock') {
        //should set font
        codeTag = true;
        inlineCode = false;
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'code') {
        codeTag = false;
        inlineCode = true;
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'center') {
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'br') {
        _toRtn.add(TextSpan(text: '\n'));
        pos = brkEnd + 1;
      } else if (tag == 'u') {
        //underline
        pos = brkEnd + 1;
        tagStack.add(tag);
        _toApplyStyle =
            _toApplyStyle.copyWith(decoration: TextDecoration.underline);
      } else if (tag == 's') {
//        tagStack.add(value)
        pos = brkEnd + 1;
        tagStack.add(tag);
        _toApplyStyle =
            _toApplyStyle.copyWith(decoration: TextDecoration.lineThrough);
      } else if (tag == 'url') {
        int end = content.indexOf('[', brkEnd);
        if (end == -1) {
          end = content.length;
        }
        String url = content.substring(brkEnd + 1, end - 1);
        _toRtn.add(TextSpan(text: url));
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag.startsWith('url=')) {
        String url = tag.substring(4, tag.length);
        _toRtn.add(TextSpan(text: url));
        pos = brkEnd + 1;
        tagStack.add('url');
      } else if (tag.startsWith('color=')) {
        String col = tag.substring(6, tag.length);
        Color color;
        if (col.startsWith('#'))
          color = hexToColor(col);
        else if (col == 'aqua')
          color = hexToColor('#00FFFF');
        else if (col == 'black')
          color = hexToColor('#000000');
        else if (col == 'blue')
          color = hexToColor('#0000FF');
        else if (col == 'fuchsia')
          color = hexToColor('#FF00FF');
        else if (col == 'gray' || col == 'grey')
          color = hexToColor('#808080');
        else if (col == 'green')
          color = hexToColor('#008000');
        else if (col == 'lime')
          color = hexToColor('#00FF00');
        else if (col == 'maroon')
          color = hexToColor('#800000');
        else if (col == 'navy')
          color = hexToColor('#000080');
        else if (col == 'olive')
          color = hexToColor('#808000');
        else if (col == 'purple')
          color = hexToColor('#800080');
        else if (col == 'red')
          color = hexToColor('#FF0000');
        else if (col == 'silver')
          color = hexToColor('#C0C0C0');
        else if (col == 'teal')
          color = hexToColor('#008008');
        else if (col == 'white')
          color = hexToColor('#FFFFFF');
        else if (col == 'yellow')
          color = hexToColor('#FFFF00');
        else
          color = Color.fromARGB(1, 0, 0, 0);

        pos = brkEnd + 1;
        tagStack.add('color');
        _toApplyStyle = _toApplyStyle.copyWith(color: color);
      } else if (tag.startsWith('font=')) {
        pos = brkEnd + 1;
        tagStack.add('font');
      } else {
        _toRtn.add(TextSpan(text: '['));
        pos = brkPos + 1;
      }
    }

    return _toRtn;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: scaledMediaQueryData(context),
      child: RichText(
        text: TextSpan(
          style: scaledTestStyle(context),
          children: _parseText(context),
        ),
      ),
    );
  }
}
