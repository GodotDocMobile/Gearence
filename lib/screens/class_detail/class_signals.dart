import 'package:flutter/cupertino.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassSignals extends StatelessWidget {
  final ClassContent clsContent;

  ClassSignals({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Signals");
  }
}
