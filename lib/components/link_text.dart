import 'package:flutter/material.dart';

import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/colors.dart';

class LinkText extends StatelessWidget {
  final String text;
  // final Function(TapEventArg args) onLinkTap;

  const LinkText({
    Key? key,
    required this.text,
    // required this.onLinkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClassDB().getDB().any((element) => element.name == text)
        ? InkWell(
            child: Text(
              text,
              style: monoOptionalStyle(
                context,
                baseStyle: TextStyle(
                  fontSize: 15,
                  color: godotColor,
                ),
              ),
            ),
            onTap: () {
              storedValues.tapEventBloc.add(
                TapEventArg(
                  className: text,
                  propertyType: PropertyType.Class,
                  fieldName: '',
                ),
              );
              // onLinkTap(
              //   TapEventArg(
              //     className: text,
              //     linkType: LinkType.Class,
              //     fieldName: '',
              //   ),
              // );
            },
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: 15,
            ),
          );
    // return Container();
  }
}
