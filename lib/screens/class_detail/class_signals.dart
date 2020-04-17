import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassSignals extends StatelessWidget {
  final ClassContent clsContent;

  ClassSignals({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.signals == null || clsContent.signals.length == 0) {
      return Center(
        child: Text('0 signal in thie class'),
      );
    }

    return ListView(
      padding: EdgeInsets.all(5),
      children: clsContent.signals.map((s) {
        return ListTile(
          title: Text(
            s.name +
                s.arguments.map((a) {
                  return a.type + " " + a.name;
                }).toString(),
          ),
          subtitle: Text(s.description),
        );
      }).toList(),
    );
  }
}
