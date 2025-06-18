import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:godotclassreference/constants/stored_values.dart';

class SvgIcon extends StatelessWidget {
  final String? svgFileName;
  SvgIcon({required this.svgFileName, Key? key});

  @override
  Widget build(BuildContext context) {
    String svgPath = '';
    if (svgFileName != null && svgFileName!.length > 0) {
      svgPath = 'svgs/' + storedValues.version + '/' + svgFileName!;
    } else {
      final icon_file =
          storedValues.versionDouble >= 4 ? 'Node.svg' : 'icon_node.svg';
      svgPath = 'svgs/' + storedValues.version + '/' + icon_file;
    }
    
    return SvgPicture.asset(
      svgPath,
      placeholderBuilder: (context) => SizedBox(),
    );
  }
}
