import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//check godot/editor/icons/SCsub

class SvgIcon extends StatelessWidget {
  final String? svgFileName;
  final String version;

  SvgIcon({required this.svgFileName, Key? key, required this.version})
      : super(key: key);

  Widget svgRender(String? data) {
    if (data != null && data.length > 0) {
      return SvgPicture.asset('svgs/' + version + '/' + data);
    }
    return SvgPicture.asset('svgs/' + version + '/icon_node.svg');
  }

  @override
  Widget build(BuildContext context) {
    if (version == '2.0') {
      return SizedBox();
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: svgRender(svgFileName),
      ),
    );
  }
}
