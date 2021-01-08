import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

//check godot/editor/icons/SCsub

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
    final _classNameLength = className.length; // '.xml' not included
    int _digit = 0;

    while (_digit < _classNameLength) {
      if (className[_digit] == '@') {
        _digit++;
        continue;
      }
      if (className[_digit].toUpperCase() == className[_digit]) {
        _correspondFilename += '_';
      }
      _correspondFilename += className[_digit].toLowerCase();

      _digit++;
    }
    // print(_correspondFilename);

    _correspondFilename =
        'svgs/' + version + '/' + _correspondFilename + '.svg';
  }

  Future<String> getSVGContent() async {
    bool _loadFailed = false;

    String _svgContent;
    try {
      _svgContent = await rootBundle.loadString(_correspondFilename);
    } catch (e) {
      _svgContent = await Future.value('svgs/' + version + '/icon_node.svg');
      _loadFailed = true;
    }
    // print("$_loadFailed , $_correspondFilename");
    if (_loadFailed &&
        (_correspondFilename.endsWith('2_d.svg') ||
            _correspondFilename.endsWith('3_d.svg'))) {
      _correspondFilename =
          _correspondFilename.replaceAll('2_d', '2d').replaceAll('3_d', '3d');
      // print("replaced:$_correspondFilename");
      try {
        _svgContent = await rootBundle.loadString(_correspondFilename);
      } catch (e) {
        _svgContent = await Future.value('svgs/' + version + '/icon_node.svg');
      }
    }
    return _svgContent;
  }

  @override
  Widget build(BuildContext context) {
    if (version == '2.0') {
      return SizedBox();
    }

    return FutureBuilder<String>(
      future: getSVGContent(),
      builder: (context, snapshot) {
        return Container(
//          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: snapshot.hasData
                ? SvgPicture.string(snapshot.data)
                : SvgPicture.asset('svgs/' + version + '/icon_node.svg'),
          ),
        );
//        if (snapshot.hasData) {
////          print('darawing svg: ' + version + ': ' + className);
//          return SvgPicture.string(snapshot.data);
//        }
//        return SvgPicture.asset('svgs/' + version + '/icon_node.svg');
      },
    );
  }
}
