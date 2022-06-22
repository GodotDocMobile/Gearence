import 'package:flutter/material.dart';
import '../components/svg_icon.dart';
import '../models/class_content.dart';

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
