import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String className;
  final String version;

  final int height;
  final int width;

  String _correspondFilename = 'icon';

  SvgIcon(
      {@required this.className,
      Key key,
      @required this.version,
      this.height,
      this.width})
      : assert(className != null),
        assert(version != null),
        super(key: key) {
    final _classNameLength = className.length - 4; // '.xml' not included
    int _digit = 0;

    while (_digit < _classNameLength) {
      if (className[_digit] == '@') {
        _digit++;
        continue;
      }
      if (className[_digit].toUpperCase() == className[_digit]) {
        _correspondFilename += '_' + className[_digit].toLowerCase();
      } else {
        _correspondFilename += className[_digit];
      }

      _digit++;
    }

    _correspondFilename =
        'svgs/' + version + '/' + _correspondFilename + '.svg';
  }

  @override
  Widget build(BuildContext context) {
    if (version == '2.0') {
      return SizedBox();
    }

    Future<String> _svgContent;
    try {
      _svgContent = rootBundle.loadString(_correspondFilename);
    } catch (e) {
      _svgContent = Future.value('svgs/' + version + '/icon_node.svg');
    }

    return FutureBuilder<String>(
      future: _svgContent,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('darawing svg: ' + version + ': ' + className);
          return SvgPicture.string(snapshot.data);
        }
        return SvgPicture.asset('svgs/' + version + '/icon_node.svg');
      },
    );
  }
}
