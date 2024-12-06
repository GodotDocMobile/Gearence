import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';

import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/bbob_code_text.dart';
import 'package:godotclassreference/components/bbob_code_text_multi_lang.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/colors.dart';

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
  final DescriptionUsedBy descriptionUsedBy;

  DescriptionText(
      {Key? key,
      required this.className,
      required this.content,
      this.descriptionUsedBy = DescriptionUsedBy.Normal})
      : super(key: key);

  List<InlineSpan> bbob_render(
      BuildContext context, String hintText, List<bbob.Node> parsed) {
    List<InlineSpan> rtn = [];
    parsed.forEach((element) {
      if (element.runtimeType == bbob.Text) {
        if (element.textContent == '\n') {
          rtn.add(TextSpan(text: '\n\n'));
        } else {
          rtn.add(TextSpan(text: element.textContent));
        }
      } else {
        var e = element as bbob.Element;
        var tag = e.tag.split(' ').first;
        var name = e.tag.split(' ').last;
        switch (tag) {
          case 'method':
          case 'member':
          case 'signal':
          case 'enum':
          case 'annotation':
          case 'constant':
            // print(name);
            hintText = "$hintText $name";
            rtn.add(WidgetSpan(
              child: Semantics(
                label: name,
                child: InkWell(
                  child: Text(
                    name + (tag == 'method' ? '()' : ''),
                    style: monoOptionalStyle(context,
                        baseStyle: scaledTextStyle(context)
                            .copyWith(color: godotColor)),
                  ),
                  onTap: () {
                    TapEventArg args = TapEventArg(
                        propertyType: linkTypeFromString(tag),
                        className: name.contains('.')
                            ? name.split('.').first
                            : className,
                        fieldName:
                            name.contains('.') ? name.split('.').last : name);
                    print(args);
                    // this.onLinkTap(args);
                    blocs.tapEventBloc.add(args);
                  },
                ),
              ),
            ));
            break;
          case 'b':
            rtn.add(TextSpan(
                text: e.textContent,
                style: scaledTextStyle(context)
                    .copyWith(fontWeight: FontWeight.bold)));
            break;
          case 'i':
            rtn.add(TextSpan(
                text: e.textContent,
                style: scaledTextStyle(context)
                    .copyWith(fontStyle: FontStyle.italic)));
            break;
          case 'center':
            rtn.add(TextSpan(text: e.textContent));
            break;
          case 'br':
            rtn.add(TextSpan(text: '\n'));
            break;
          case 'u':
            rtn.add(
              TextSpan(
                  text: e.textContent,
                  style: scaledTextStyle(context)
                      .copyWith(decoration: TextDecoration.underline)),
            );
            break;
          case 's':
            rtn.add(
              TextSpan(
                  text: e.textContent,
                  style: scaledTextStyle(context)
                      .copyWith(decoration: TextDecoration.lineThrough)),
            );
            break;
          case 'url':
            if (e.attributes.length > 0) {
              rtn.add(TextSpan(text: e.attributes.keys.first));
            } else {
              rtn.add(TextSpan(text: e.textContent));
            }
            break;
          case 'param':
            rtn.add(WidgetSpan(
              child: Container(
                color: storedValues.isDarkTheme
                    ? Colors.grey[600]
                    : Colors.grey[300],
                child: Text(
                  name,
                  style: monoOptionalStyle(context),
                ),
              ),
            ));
            break;
          case 'code':
            rtn.add(WidgetSpan(
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: storedValues.isDarkTheme
                      ? Colors.grey[600]
                      : Colors.grey[300],
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Text(e.textContent),
              ),
            ));
            break;
          case 'codeblock':
            rtn.add(WidgetSpan(
              child: BBOBCodeText(
                bbobNode: e,
              ),
            ));
            break;
          case 'codeblocks':
            rtn.add(WidgetSpan(
              child: BBOBCodeTextMultiLang(
                bbobElement: e,
              ),
            ));
            break;
          case 'kbd':
            rtn.add(WidgetSpan(
              child: Container(
                padding: EdgeInsets.only(left: 2, right: 2),
                color: Colors.blueGrey,
                child: Text(
                  e.textContent,
                  style: monoOptionalStyle(context),
                ),
              ),
            ));
            break;
          case 'color':
            Color color;
            switch (e.attributes.keys.first) {
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
            rtn.add(TextSpan(
                text: e.textContent,
                style: scaledTextStyle(context).copyWith(color: color)));
            break;
          default:
            if (ClassDB().getDB().any((element) => element.name == e.tag)) {
              hintText = "$hintText ${getSpacedClassName(e.tag)}";
              rtn.add(WidgetSpan(
                child: Semantics(
                  label: "class ${getSpacedClassName(e.tag)}",
                  child: InkWell(
                    child: ExcludeSemantics(
                      child: Text(
                        e.tag,
                        style: monoOptionalStyle(context,
                            baseStyle: scaledTextStyle(context).copyWith(
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
                      blocs.tapEventBloc.add(args);
                    },
                  ),
                ),
              ));
            }
            // else if (tag.startsWith('annotation')) {
            //   rtn.add(TextSpan(
            //     text: name,
            //     style: scaledTextStyle(context).copyWith(color: godotColor),
            //   ));
            // }
            else {
              print(e);
            }
            break;
        }
      }
    });
    return rtn;
  }

  @override
  Widget build(BuildContext context) {
    var ast = bbob.parse(content, openTag: '[', closeTag: ']');

    String hintText = '';
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
    var rendered = bbob_render(context, hintText, ast);
    return MediaQuery(
      data: scaledMediaQueryData(context),
      child: Semantics(
        label: hintText,
        child: RichText(
          text: TextSpan(
            style: scaledTextStyle(context),
            children: rendered,
          ),
        ),
      ),
    );
  }
}
