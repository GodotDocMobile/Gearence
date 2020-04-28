import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:xml/xml.dart' as xml;

import 'package:godotclassreference/screens/class_detail/class_constants.dart';
import 'package:godotclassreference/screens/class_detail/class_enums.dart';
import 'package:godotclassreference/screens/class_detail/class_info.dart';
import 'package:godotclassreference/screens/class_detail/class_members.dart';
import 'package:godotclassreference/screens/class_detail/class_methods.dart';
import 'package:godotclassreference/screens/class_detail/class_signals.dart';
import 'package:godotclassreference/screens/class_detail/class_theme_items.dart';

import 'package:godotclassreference/models/class_content.dart';

class ClassDetail extends StatefulWidget {
  final String className;
  final TapEventArg args;

  const ClassDetail({Key key, @required this.className, this.args})
      : assert(className != null),
        super(key: key);

  @override
  _ClassDetailState createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail>
    with TickerProviderStateMixin {
  TabController _tabController;
  Future<ClassContent> _classContent;
  List<ClassTab> _tabs;

  @override
  void initState() {
    super.initState();
    _classContent = getClassDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<ClassContent> getClassDetail() async {
    final version = StoredValues().prefs.getString('version');

    final file = await rootBundle
        .loadString('xmls/' + version + '/' + widget.className + '.xml');

    final rootNode = xml
        .parse(file)
        .root
        .children
        .lastWhere((w) => w.nodeType != xml.XmlNodeType.TEXT);
    return ClassContent.fromXml(rootNode);
  }

  void onLinkTap(TapEventArg args) {
    if (args.className == widget.className) {
      //navigation within class
      int _toFocusTabIndex =
          _tabs.indexWhere((w) => w.title == linkTypeToString(args.linkType));
      _tabController.animateTo(_toFocusTabIndex);
    } else {
//      Navigator
    }
    print(
        args.className + ":" + args.linkType.toString() + ":" + args.fieldName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassContent>(
      future: _classContent,
      builder: (BuildContext context, AsyncSnapshot<ClassContent> snapshot) {
        if (snapshot.hasData) {
          _tabs = getClassTabs(snapshot.data, this.onLinkTap);
          // append theme item tab if needed
          if (snapshot.data.themeItems != null &&
              snapshot.data.themeItems.length > 0) {
            _tabs.add(ClassTab(
              title: 'Theme Item',
              child: ClassThemeItems(
                clsContent: snapshot.data,
                onLinkTap: onLinkTap,
              ),
              showCnt: true,
              itemCount: snapshot.data.themeItems.length,
            ));
          }

          _tabController = TabController(vsync: this, length: _tabs.length);

//          _tabController.animateTo(1);

          if (widget.args != null &&
              widget.args.className == snapshot.data.name) {
            int _tabIndex = _tabs.indexWhere(
                (w) => w.title == linkTypeToString(LinkType.Constant));
            _tabController.animateTo(_tabIndex);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.className),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((f) {
                  return Tab(
                    child: Row(
                      children: <Widget>[
                        Text(f.title),
                        f.showCnt
                            ? Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3)),
                                    ),
                                    height: 20,
                                    child: Center(
                                      child: Text(
                                        " " + f.itemCount.toString() + " ",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox()
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _tabs.map((c) {
                return c.child;
              }).toList(),
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
  ClassTab({this.title, this.child, this.itemCount, this.showCnt = false});

  final String title;

  final Widget child;

  final int itemCount;

  final bool showCnt;
}

List<ClassTab> getClassTabs(
    ClassContent clsContent, Function(TapEventArg args) onLinkTap) {
  return <ClassTab>[
    ClassTab(
      title: "Info",
      child: ClassInfo(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
    ),
    ClassTab(
      title: "Enums",
      child: ClassEnums(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
      showCnt: true,
      itemCount: clsContent.constants == null
          ? 0
          : clsContent.constants.where((w) => w.enumValue != null).length,
    ),
    ClassTab(
      title: "Constants",
      child: ClassConstants(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
      showCnt: true,
      itemCount: clsContent.constants == null
          ? 0
          : clsContent.constants.where((w) => w.enumValue == null).length,
    ),
    ClassTab(
      title: "Members",
      child: ClassMembers(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
      showCnt: true,
      itemCount: clsContent.members == null ? 0 : clsContent.members.length,
    ),
    ClassTab(
      title: "Methods",
      child: ClassMethods(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
      showCnt: true,
      itemCount: clsContent.methods == null ? 0 : clsContent.methods.length,
    ),
    ClassTab(
      title: "Signals",
      child: ClassSignals(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
      ),
      showCnt: true,
      itemCount: clsContent.signals == null ? 0 : clsContent.signals.length,
    )
  ];
}
