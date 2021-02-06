import 'package:flutter/material.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassIcon extends StatelessWidget {
  final ClassContent classContent;
  // final IconForNonNodeBloc bloc;

  const ClassIcon({Key key, this.classContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // if(StoredValues().)
    return SvgIcon(
      className: classContent.name,
      version: StoredValues().prefs.getString('version'),
    );
  }
}
