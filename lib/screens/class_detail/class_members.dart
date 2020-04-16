import 'package:flutter/cupertino.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassMembers extends StatelessWidget {
  final ClassContent clsContent;

  ClassMembers({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("members");
  }
}
