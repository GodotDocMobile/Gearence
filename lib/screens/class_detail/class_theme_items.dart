import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassThemeItems extends StatelessWidget {
  final ClassContent clsContent;

  ClassThemeItems({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.themeItems == null || clsContent.themeItems.length == 0) {
      return Center(
        child: Text('0 theme item in this class'),
      );
    }

    return ListView(
      children: clsContent.themeItems.map((t) {
        return ListTile(
          leading: Text(t.type),
          title: Text(t.name),
        );
      }).toList(),
    );
  }
}
