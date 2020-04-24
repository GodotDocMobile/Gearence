import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
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
        return ListTile(
          leading: Text(
            m.returnValue == null ? 'void' : m.returnValue.type,
//                  style: TextStyle(fontSize: 25),
          ),
          title: Text(
            m.name,
            softWrap: true,
            style: TextStyle(fontSize: 25, color: godotColor),
//                    overflow: TextOverflow.fade,
          ),
          subtitle: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  (m.arguments != null && m.arguments.length > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'arguments:',
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: m.arguments.map((a) {
                                      return Text(a.type,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black));
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: m.arguments.map((a) {
                                      return Text(a.name,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black));
                                    }).toList(),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: m.arguments.map((a) {
                                      return a.defaultValue == null
                                          ? Text('')
                                          : Row(
                                              children: <Widget>[
                                                Text(
                                                  ' = ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  a.defaultValue,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )
                                              ],
                                            );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox()),
//                    SizedBox(
//                      height: 5,
//                    ),
                  Row(
                    children: <Widget>[
//                      Text(
//                        "return ",
//                        style: TextStyle(color: Colors.grey),
//                      ),
//                      Text(m.returnValue == null ? 'void' : m.returnValue.type),
//                      SizedBox(
//                        width: 5,
//                      ),
                      m.qualifiers == null
                          ? SizedBox()
                          : Row(
                              children: <Widget>[
                                Text(
                                  'qualifiers ',
                                ),
                                Text(
                                  m.qualifiers,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
              DescriptionText(
                className: clsContent.name,
                content: m.description,
                onLinkTap: (e) {},
//            style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
