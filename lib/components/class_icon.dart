import 'package:flutter/material.dart';

import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassIcon extends StatelessWidget {
  final ClassContent? classContent;
  const ClassIcon({Key? key, this.classContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      svgFileName: classContent!.svgFileName,
    );
  }
}
