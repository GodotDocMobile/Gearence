import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  final String svgContent;
  const SvgIcon({super.key, required this.svgContent});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgContent,
      placeholderBuilder: (context) => SizedBox(),
    );
    // String svgPath = '';
    // if (svgFileName != null && svgFileName!.length > 0) {
    //   svgPath = 'svgs/' + storedValues.version + '/' + svgFileName!;
    // } else {
    //   final icon_file =
    //       storedValues.versionDouble >= 4 ? 'Node.svg' : 'icon_node.svg';
    //   svgPath = 'svgs/' + storedValues.version + '/' + icon_file;
    // }

    // return SvgPicture.asset(
    //   svgPath,
    //   placeholderBuilder: (context) => SizedBox(),
    // );
  }
}
