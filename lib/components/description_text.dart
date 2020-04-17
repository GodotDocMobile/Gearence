import 'package:flutter/cupertino.dart';

class DescriptionText extends StatelessWidget {
  final String text;
  final Function onTap;

  DescriptionText({Key key, @required this.text, this.onTap})
      : assert(text != null),
        assert(onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
