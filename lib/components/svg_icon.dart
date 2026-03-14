import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:godotclassreference/components/default_class_icon.dart';

class SvgIcon extends StatelessWidget {
  final String svgContent;
  const SvgIcon({super.key, required this.svgContent});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgContent,
      placeholderBuilder: (context) => const DefaultClassIcon(),
    );
  }
}
