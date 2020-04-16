import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/screens/class_detail/class_constants.dart';
import 'package:godotclassreference/screens/class_detail/class_info.dart';
import 'package:godotclassreference/screens/class_detail/class_members.dart';
import 'package:godotclassreference/screens/class_detail/class_methods.dart';
import 'package:godotclassreference/screens/class_detail/class_signals.dart';
import 'package:godotclassreference/screens/class_detail/class_theme_items.dart';

import 'package:xml/xml.dart' as xml;

import 'package:godotclassreference/models/class_content.dart';
//import 'package:godotclassreference/components/drawer.dart';

class ClassDetail extends StatelessWidget {
  final String className;

  const ClassDetail({Key key, @required this.className})
      : assert(className != null),
        super(key: key);

  Future<ClassContent> getClassDetail() async {
    final file = await rootBundle.loadString('xmls/3.0/' + className + '.xml');
    final rootNode = xml.parse(file).root.lastChild;

    return ClassContent.fromXml(rootNode);
  }

  @override
  Widget build(BuildContext context) {
    final _classContent = getClassDetail();

    return FutureBuilder<ClassContent>(
      future: _classContent,
      builder: (BuildContext context, AsyncSnapshot<ClassContent> snapshot) {
        if (snapshot.hasData) {
          List<ClassTab> tabs = getClassTabs(snapshot.data);
          // append theme item tab if needed
          if (snapshot.data.themeItems != null &&
              snapshot.data.themeItems.length > 0) {
            tabs.add(ClassTab(
              title: 'Theme Item',
              child: ClassThemeItems(
                clsContent: snapshot.data,
              ),
            ));
          }
          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
//              drawer: GCRDrawer(),
              appBar: AppBar(
                title: Text(className),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: tabs.map((f) {
                    return Tab(text: f.title);
                  }).toList(),
                ),
              ),
              body: TabBarView(
                children: tabs.map((c) {
                  return c.child;
                }).toList(),
              ),
            ),
          );
        }
        return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class ClassTab {
  ClassTab({this.title, this.child});

  final String title;

  final Widget child;
}

List<ClassTab> getClassTabs(ClassContent clsContent) {
  return <ClassTab>[
    ClassTab(
      title: "Info",
      child: ClassInfo(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      title: "Constants",
      child: ClassConstants(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      title: "Members",
      child: ClassMembers(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      title: "Methods",
      child: ClassMethods(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      title: "Signals",
      child: ClassSignals(
        clsContent: clsContent,
      ),
    )
  ];
}
