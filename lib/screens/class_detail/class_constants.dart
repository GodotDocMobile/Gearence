import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassConstants extends StatelessWidget {
  final ClassContent clsContent;

  ClassConstants({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.constants == null ||
        clsContent.constants.where((w) => w == null).length == 0) {
      return Center(
        child: Text('0 constant in this class'),
      );
    }

    return ListView(
      padding: EdgeInsets.all(5),
      children: clsContent.constants.where((w) => w == null).map((c) {
        return ListTile(
          leading: Card(
            child: Text(c.value),
          ),
          title: Text(c.name),
//          trailing: Text('value:' + c.value),
          subtitle: DescriptionText(
            className: clsContent.name,
            content: c.constantText,
            onLinkTap: (e) {},
          ),
        );
      }).toList(),
    );
  }
}
