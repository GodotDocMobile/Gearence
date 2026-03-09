import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:isar_plus/isar_plus.dart';

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
    final Isar docIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    final isClass = docIsar.classContents.where().nameEqualTo(text).count() > 0;
    return isClass
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
              blocs.tapEventBloc.add(
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
