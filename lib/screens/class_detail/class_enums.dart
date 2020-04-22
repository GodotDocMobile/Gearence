import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassEnums extends StatelessWidget {
  final ClassContent clsContent;

  ClassEnums({Key key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.constants == null ||
        clsContent.constants.where((w) => w != null).length == 0) {
      return Center(
        child: Text('0 enum in this class'),
      );
    }
    final _enums = clsContent.constants
        .map((c) {
          return c.enumValue;
        })
        .toSet()
        .where((w) => w != null)
        .toList();
//    print(_enums);

    return ListView(
      padding: EdgeInsets.all(5),
      children: _enums.map((e) {
        final _enumValues =
            clsContent.constants.where((w) => w.enumValue == e).toList();
        _enumValues.sort((a, b) => a.value.compareTo(b.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'enum ',
                  style: TextStyle(color: godotColor, fontSize: 20),
                ),
                Text(
                  e,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  ':',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Column(
              children: _enumValues.map((c) {
                return ListTile(
//                  leading: Card(
//                    child: Text(c.value),
//                  ),
                  title: Text(c.name + ' = ' + c.value),
//          trailing: Text('value:' + c.value),
                  subtitle: DescriptionText(
                    className: clsContent.name,
                    content: c.constantText,
                    onLinkTap: (e) {},
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 5,
            )
          ],
        );
      }).toList(),
//      children: clsContent.constants.where((w) => w != null).map((c) {
//        return ListTile(
//          leading: Card(
//            child: Text(c.value),
//          ),
//          title: Text(c.name),
////          trailing: Text('value:' + c.value),
//          subtitle: Text(c.constantText),
//        );
//      }).toList(),
    );
  }
}
