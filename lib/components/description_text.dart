import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/code_text_multi_lang.dart';
import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/code_text.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/colors.dart';

//logic check godot/editor/editor_help.cpp _add_text_to_rt

// TODO: refactor this.

enum DescriptionUsedBy {
  Inherits,
  ChildClasses,
  BriefDescription,
  Description,
  Normal
}

class DescriptionText extends StatelessWidget {
  final String className;
  final String content;
  // final Function(TapEventArg args) onLinkTap;
  final TextStyle? style;
  final DescriptionUsedBy descriptionUsedBy;

  String hintText = '';

  DescriptionText(
      {Key? key,
      required this.className,
      required this.content,
      // required this.onLinkTap,
      this.style,
      this.descriptionUsedBy = DescriptionUsedBy.Normal})
      : super(key: key);

  // this is a full implementation of _add_text_to_rt
  List<InlineSpan> _parseText(BuildContext context) {
    List<InlineSpan> _toRtn = [];

    List<String> tagStack = [];
    bool codeTag = false;
    bool inlineCode = false;
    bool multiLangCode = false;
    int pos = 0; // read position

    TextStyle _toApplyStyle = scaledTextStyle(context);
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
            brkPos = content.indexOf('[/codeblock', brkPos + 1);
          }
          text = content.substring(pos, brkPos);
          _toRtn.add(TextSpan(text: "\n"));
          _toRtn.add(WidgetSpan(
            child: multiLangCode
                ? CodeTextMultiLang(codeTextWithBBCode: text)
                : CodeText(codeText: text),
          ));
          _toRtn.add(TextSpan(text: "\n\n"));
        } else {
          if (inlineCode) {
            _toRtn.add(TextSpan(text: text, semanticsLabel: ''));
          } else {
            if (text.characters.last == '\n' &&
                pos + text.length >= content.length) {
              text = text.substring(0, text.length - 1);
            }

            text = text.replaceAll('\n', '\n\n');

            _toRtn.add(
              TextSpan(text: text, semanticsLabel: '', style: _toApplyStyle),
            );
          }

          //semantic handling
          if (descriptionUsedBy == DescriptionUsedBy.Inherits) {
            // we describe 'A inherits from B' with 'A >> B'
            // and we desplay inherit chain in this way,
            // so replace them for friendlier screen reading experience
            text = text.replaceAll('>>', ', which inherits ');
          }

          text = text.replaceAll('/', ' divided by').replaceAll('*', ' times ');

          hintText = "$hintText $text";
        }
        _toApplyStyle = scaledTextStyle(context);
      }

      if (brkPos == content.length) {
        break; // nothing else to add
      }

      int brkEnd = content.indexOf(']', brkPos + 1);

      if (brkEnd == -1) {
        String text = content.substring(brkPos, content.length);
        // if (!codeTag) {
        //   text = text.replaceAll('\n', '\n\n');
        // }

        hintText = "$hintText $text";
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
        hintText = "$hintText $linkTarget";
        _toRtn.add(
          WidgetSpan(
            child: Semantics(
              label: tag,
              child: InkWell(
                child: Text(
                  linkTarget + (tag.startsWith('method ') ? '()' : ''),
                  style: monoOptionalStyle(context,
                      baseStyle: _toApplyStyle.copyWith(color: godotColor)),
                ),
                onTap: () {
                  TapEventArg args = TapEventArg(
                      propertyType: linkTypeFromString(tag.split(' ').first),
                      className: linkTarget.contains('.')
                          ? linkTarget.split('.').first
                          : className,
                      fieldName: linkTarget.contains('.')
                          ? linkTarget.split('.').last
                          : linkTarget);
                  // this.onLinkTap(args);
                  blocs.tapEventBloc.add(args);
                },
              ),
            ),
          ),
        );
        pos = brkEnd + 1;
      } else if (ClassDB().getDB().any((element) => element.name == tag)) {
        hintText = "$hintText ${getSpacedClassName(tag)}";
        _toRtn.add(WidgetSpan(
          child: Semantics(
            label: "class ${getSpacedClassName(tag)}",
            child: InkWell(
                child: ExcludeSemantics(
                  child: Text(
                    tag,
                    style: monoOptionalStyle(context,
                        baseStyle: _toApplyStyle.copyWith(
                            fontFeatures: [FontFeature.tabularFigures()],
                            color: godotColor)),
                  ),
                ),
                onTap: () {
                  TapEventArg args = TapEventArg(
                    propertyType: PropertyType.Class,
                    className: tag,
                    fieldName: '',
                  );
                  // this.onLinkTap(args);
                  blocs.tapEventBloc.add(args);
                }),
          ),
        ));
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
      } else if (tag == 'codeblocks') {
        multiLangCode = true;
        codeTag = true;
        inlineCode = false;
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag == 'codeblock') {
        //should set font
        multiLangCode = false;
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

        hintText = "$hintText $url";
        _toRtn.add(TextSpan(text: url));
        pos = brkEnd + 1;
        tagStack.add(tag);
      } else if (tag.startsWith('url=')) {
        String url = tag.substring(4, tag.length);
        hintText = "$hintText $url";
        _toRtn.add(TextSpan(text: url));
        pos = brkEnd + 1;
        tagStack.add('url');
      } else if (tag.startsWith('color=')) {
        String col = tag.substring(6, tag.length);
        Color color;
        if (col.startsWith('#'))
          color = hexToColor(col);
        else {
          switch (col) {
            case 'aqua':
              color = hexToColor('#00FFFF');
              break;
            case 'black':
              color = hexToColor('#000000');
              break;
            case 'blue':
              color = hexToColor('#0000FF');
              break;
            case 'fuchsia':
              color = hexToColor('#FF00FF');
              break;
            case 'gray':
            case 'grey':
              color = hexToColor('#808080');
              break;
            case 'green':
              color = hexToColor('#008000');
              break;
            case 'lime':
              color = hexToColor('#00FF00');
              break;
            case 'maroon':
              color = hexToColor('#800000');
              break;
            case 'navy':
              color = hexToColor('#000080');
              break;
            case 'olive':
              color = hexToColor('#808000');
              break;
            case 'purple':
              color = hexToColor('#800080');
              break;
            case 'red':
              color = hexToColor('#FF0000');
              break;
            case 'silver':
              color = hexToColor('#C0C0C0');
              break;
            case 'teal':
              color = hexToColor('#008008');
              break;
            case 'white':
              color = hexToColor('#FFFFFF');
              break;
            case 'yellow':
              color = hexToColor('#FFFF00');
              break;
            default:
              color = Color.fromARGB(1, 0, 0, 0);
              break;
          }
        }

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
    final parsed = _parseText(context);
    switch (descriptionUsedBy) {
      case DescriptionUsedBy.Inherits:
        hintText = "inherit chain: $hintText";
        break;
      case DescriptionUsedBy.ChildClasses:
        hintText = "child classes: $hintText";
        break;
      case DescriptionUsedBy.BriefDescription:
        hintText = "brief description: $hintText";
        break;
      case DescriptionUsedBy.Description:
        hintText = "description: $hintText";
        break;
      case DescriptionUsedBy.Normal:
        break;
    }
    return MediaQuery(
      data: scaledMediaQueryData(context),
      child: Semantics(
        label: hintText,
        child: RichText(
          text: TextSpan(
            style: scaledTextStyle(context),
            children: parsed,
          ),
        ),
      ),
    );
  }
}
