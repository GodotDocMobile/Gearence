import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:godotclassreference/constants/stored_values.dart';

class SvgIcon extends StatelessWidget {
  final String? svgFileName;
  final String version = storedValues.version;
  SvgIcon({required this.svgFileName, Key? key});

  Future<PictureInfo> getSvgContent() async {
    String rawSvg = '';
    if (svgFileName != null && svgFileName!.length > 0) {
      rawSvg =
          await rootBundle.loadString('svgs/' + version + '/' + svgFileName!);
    } else {
      final icon_file =
          double.parse(version) >= 4 ? 'Node.svg' : 'icon_node.svg';
      rawSvg = await rootBundle.loadString('svgs/' + version + '/' + icon_file);
    }
    try {
      return await vg.loadPicture(SvgStringLoader(rawSvg), null);
    } catch (_) {
      final icon_file =
          double.parse(version) >= 4 ? 'Node.svg' : 'icon_node.svg';
      rawSvg = await rootBundle.loadString('svgs/' + version + '/' + icon_file);
      return await vg.loadPicture(SvgStringLoader(rawSvg), null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PictureInfo>(
        future: getSvgContent(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Transform.translate(
              offset: Offset(-snapshot.data!.size.width / 4,
                  -snapshot.data!.size.height / 4),
              child: CustomPaint(
                painter: SvgIconPainter(svgContent: snapshot.data!),
              ),
            );
          }
          return SizedBox();
        });
  }
}

class SvgIconPainter extends CustomPainter {
  PictureInfo svgContent;

  SvgIconPainter({required this.svgContent, Key? key});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(svgContent.picture);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
