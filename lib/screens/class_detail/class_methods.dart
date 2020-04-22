import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassMethods extends StatelessWidget {
  final ClassContent clsContent;

  ClassMethods({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.methods == null || clsContent.methods.length == 0) {
      return Center(
        child: Text('0 method in this class'),
      );
    }

    return ListView(
      padding: EdgeInsets.all(5),
      children: clsContent.methods.map((m) {
        m.arguments.sort((a, b) => a.index.compareTo(b.index));
        return Column(
          children: <Widget>[
            ListTile(
              leading:
                  Text(m.returnValue == null ? 'void' : m.returnValue.type),
              title: Text(m.name +
                  m.arguments.map((a) {
                    return a.type + " " + a.name;
                  }).toString()),
              trailing: m.qualifiers == null ? SizedBox() : Text(m.qualifiers),
//          subtitle: Text(m.description),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(
                m.description,
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}
