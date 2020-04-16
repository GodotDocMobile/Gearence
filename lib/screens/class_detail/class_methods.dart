import 'package:flutter/cupertino.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassMethods extends StatelessWidget {
  final ClassContent clsContent;

  ClassMethods({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Methods");
  }
}
