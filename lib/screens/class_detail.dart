import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart' as xml_events;

import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/components/drawer.dart';

class ClassDetail extends StatelessWidget {
  final String className;

  const ClassDetail({Key key, @required this.className})
      : assert(className != null),
        super(key: key);

  // TODO: Read xml parse it and bind to object
  Future<ClassContent> getClassDetail() async {
    final file = await rootBundle.loadString('xmls/3.0/' + className + '.xml');
    final rootNode = xml.parse(file).root.lastChild;

    return ClassContent.fromJson(rootNode);
  }

  @override
  Widget build(BuildContext context) {
    final _classContent = getClassDetail();
    return Scaffold(
      drawer: GCRDrawer(),
      appBar: AppBar(
        title: Text(className),
      ),
      body: FutureBuilder<ClassContent>(
        future: _classContent,
        builder: (BuildContext builder, AsyncSnapshot<ClassContent> snapshot) {
//          if (snapshot.hasData) {}
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
