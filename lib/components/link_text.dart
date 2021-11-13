import 'package:flutter/material.dart';
import '../bloc/tap_event_arg.dart';
import '../constants/class_db.dart';
import '../constants/colors.dart';

class LinkText extends StatelessWidget {
  final String text;
  final Function(TapEventArg args) onLinkTap;

  const LinkText({Key? key, required this.text, required this.onLinkTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClassDB().getDB().any((element) => element.name == text)
        ? InkWell(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: godotColor,
              ),
            ),
            onTap: () {
              onLinkTap(
                TapEventArg(
                  className: text,
                  linkType: LinkType.Class,
                  fieldName: '',
                ),
              );
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
