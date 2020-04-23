import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';

//implementation check godot/editor/editor_help.cpp _add_text_to_rt

class DescriptionText extends StatelessWidget {
  final String className;
  final String content;
  final Function(TapEventArg args) onLinkTap;
  final TextStyle style;

  DescriptionText(
      {Key key,
      @required this.className,
      @required this.content,
      this.onLinkTap,
      this.style})
      : assert(className != null),
        assert(content != null),
        assert(onLinkTap != null),
        super(key: key);

  // this is a full implementation of _add_text_to_rt
  List<TextSpan> _parseText() {
    List<TextSpan> _toRtn = List<TextSpan>();

    List<String> tagStack = List<String>();
    bool codeTag = false;
    int pos = 0;
    while (pos < content.length) {
      int brkPos = content.indexOf('[', pos);

      if (brkPos < 0) {
        brkPos = content.length;
      }

      if (brkPos > pos) {
        String text = content.substring(pos, brkPos);
//        if (!codeTag) {
//          text = text.replaceAll('\n', '\n');
//        }
        _toRtn.add(TextSpan(text: text));
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

//        final aaa = tag.substring(1, tag.length);

        if (!tagOK) {
          _toRtn.add(TextSpan(text: ']'));
          pos = brkPos + 1;
          continue;
        }

        tagStack.removeAt(0);
        pos = brkEnd + 1;
        codeTag = false;
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
        _toRtn.add(TextSpan(
            text: linkTarget + (tag.startsWith('method ') ? '()' : ''),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                TapEventArg args = TapEventArg(
//                    linkType: strToLinkType(tag.split(pattern)),
                    className: className,
                    fieldName: linkTarget);
                this.onLinkTap(args);
              }));
//        _toRtn.removeLast();
//        _toRtn.removeLast();
        pos = brkEnd + 1;
      } else if (ClassList().getList().contains(tag + '.xml')) {
        _toRtn.add(TextSpan(text: tag));
//        _toRtn.removeLast();
//        _toRtn.removeLast();
        pos = brkEnd + 1;
      } else if (tag == 'b') {
        //should set font
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'i') {
        //should set font
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'code' || tag == 'codeblock') {
        //should set font
        codeTag = true;
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'center') {
        //set center
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'br') {
        _toRtn.add(TextSpan(text: '\n'));
        pos = brkEnd + 1;
      } else if (tag == 'u') {
//        _toRtn.add(TextSpan(text: 'u'));
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 's') {
//        tagStack.add(value)
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'url') {
        int end = content.indexOf('[', brkEnd);
        if (end == -1) {
          end = content.length;
        }
        String url = content.substring(brkEnd + 1, end - brkEnd - 1);
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
          color = hexToColor('008000');
        else if (col == 'lime')
          color = hexToColor('00FF00');
        else if (col == 'maroon')
          color = hexToColor('800000');
        else if (col == 'navy')
          color = hexToColor('000080');
        else if (col == 'olive')
          color = hexToColor('808000');
        else if (col == 'purple')
          color = hexToColor('800080');
        else if (col == 'red')
          color = hexToColor('FF0000');
        else if (col == 'silver')
          color = hexToColor('C0C0C0');
        else if (col == 'teal')
          color = hexToColor('008008');
        else if (col == 'white')
          color = hexToColor('FFFFFF');
        else if (col == 'yellow')
          color = hexToColor('FFFF00');
        else
          color = Color.fromARGB(1, 0, 0, 0);

//        _toRtn.add(value)
        pos = brkEnd + 1;
        tagStack.add('color');
      } else if (tag.startsWith('font=')) {
//        String fnt = tag.substring(5, tag.length);
        pos = brkEnd + 1;
        tagStack.add('font');
      } else {
        _toRtn.add(TextSpan(text: '['));
        pos = brkPos + 1;
      }
    }

    return _toRtn;
  }

  static LinkType strToLinkType(String input) {
    switch (input.trim()) {
      case 'method':
        return LinkType.Method;
      case 'signal':
        return LinkType.Signal;
      case 'member':
        return LinkType.Member;
      case 'enum':
        return LinkType.Enum;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: this.style == null ? DefaultTextStyle.of(context).style : style,
        children: _parseText(),
      ),
    );
  }
}
