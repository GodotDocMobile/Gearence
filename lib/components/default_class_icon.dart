import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class DefaultClassIcon extends StatelessWidget {
  const DefaultClassIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/Node.svg');
  }
}
