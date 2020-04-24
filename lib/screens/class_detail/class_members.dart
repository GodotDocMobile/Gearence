import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
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
            title: Text(
              m.name,
              style: TextStyle(fontSize: 25, color: godotColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'setter',
                  style: TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    m.setter + "(value)",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text(
                  'getter',
                  style: TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    m.getter + "()",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DescriptionText(
                  className: clsContent.name,
                  content: m.memberText,
                  onLinkTap: (e) {},
                ),
              ],
            ),
          ),
//          Padding(
//            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//            child: DescriptionText(
//              className: clsContent.name,
//              content: m.memberText,
//              onLinkTap: (e) {},
//            ),
//          ),
          SizedBox(
            height: 10,
          ),
        ]);
      }).toList(),
    );
  }
}
