import 'package:flutter/cupertino.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassThemeItems extends StatelessWidget {
  final ClassContent clsContent;

  ClassThemeItems({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Theme Items");
  }
}
