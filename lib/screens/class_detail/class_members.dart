import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassMembers extends StatelessWidget {
  final ClassContent clsContent;

  ClassMembers({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.members == null || clsContent.members.length == 0) {
      return Center(
        child: Text('0 memeber in this class'),
      );
    }

    return ListView(
      padding: EdgeInsets.all(5),
      children: clsContent.members.map((m) {
        return Column(children: <Widget>[
          ListTile(
            leading: Text(m.type),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  m.name,
                  style: TextStyle(fontSize: 25),
                ),
                Row(
                  children: <Widget>[
                    Text(m.setter + "(value)"),
                    Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        'setter',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(m.getter + "()"),
                    Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        'getter',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
//          subtitle: Text(m.memberText),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text(
              m.memberText,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ]);
      }).toList(),
    );
  }
}
