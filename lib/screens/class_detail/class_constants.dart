import 'package:flutter/cupertino.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassConstants extends StatelessWidget {
  final ClassContent clsContent;

  ClassConstants({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Constants");
  }
}
