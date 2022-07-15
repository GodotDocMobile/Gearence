import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';

class ZeroContentHint extends StatelessWidget {
  final ClassContent clsContent;
  final PropertyType propertyType;

  ZeroContentHint(
      {Key? key, required this.clsContent, required this.propertyType})
      : super(key: key);

  final TextStyle _plainTextStyle =
      TextStyle(color: storedValues.isDarkTheme ? Colors.white : Colors.black);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("0 ${propertyType.name.toLowerCase()} in this class"),
        SizedBox(height: 5),
        if (clsContent.inherits != null && clsContent.inherits!.isNotEmpty) ...[
          RichText(
              text: TextSpan(
            children: [
              TextSpan(
                  text: 'maybe check on parent class: ',
                  style: _plainTextStyle),
              WidgetSpan(
                  child: LinkText(
                text: clsContent.inherits!,
              )),
            ],
          )),
          SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "or  ", style: _plainTextStyle),
                WidgetSpan(
                  child: InkWell(
                    child: Text(
                      "${clsContent.inherits!}'s ${propertyType.name.toLowerCase()}",
                      style: monoOptionalStyle(
                        context,
                        baseStyle: TextStyle(
                          fontSize: 15,
                          color: godotColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      blocs.tapEventBloc.add(
                        TapEventArg(
                          className: clsContent.inherits!,
                          propertyType: propertyType,
                          fieldName: '',
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ],
    );
  }
}
