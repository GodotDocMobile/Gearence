import 'package:flutter/material.dart';

import '../bloc/tap_event_bloc.dart';
import '../bloc/tap_event_arg.dart';
import '../components/node_tag.dart';
import '../constants/class_db.dart';
import '../constants/stored_values.dart';
import '../models/class_content.dart';

import '../screens/class_detail/class_constants.dart';
import '../screens/class_detail/class_enums.dart';
import '../screens/class_detail/class_info.dart';
import '../screens/class_detail/class_members.dart';
import '../screens/class_detail/class_methods.dart';
import '../screens/class_detail/class_signals.dart';
import '../screens/class_detail/class_theme_items.dart';

class ClassDetail extends StatefulWidget {
  final String className;
  final TapEventArg? args;

  const ClassDetail({Key? key, required this.className, this.args})
      : super(key: key);

  @override
  _ClassDetailState createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  Future<ClassContent>? _classContent;
  late List<ClassTab> _tabs;

  late TapEventBloc _bloc;

  String className = '';

  @override
  void initState() {
    super.initState();
    className = widget.className;
    _bloc = TapEventBloc();
    _classContent = getClassDetail();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.args != null) {
        Future.delayed(Duration(milliseconds: 200), () {
          _bloc.argSink.add(widget.args);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
    _bloc.dispose();
  }

  Future<ClassContent> getClassDetail() async {
    final version = StoredValues().prefs!.getString('version');

    return await ClassDB().getSingle(version, widget.className);
  }

  void onLinkTap(TapEventArg args) async {
    if (args.className == widget.className) {
      //navigation within class
      int _toFocusTabIndex =
          _tabs.indexWhere((w) => w.title == linkTypeToString(args.linkType));
      tabController!
          .animateTo(_toFocusTabIndex, duration: Duration(milliseconds: 100));
      Future.delayed(Duration(milliseconds: 120), () {
        _bloc.argSink.add(args);
      });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetail(
              className: args.className,
              args: args,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassContent>(
      future: _classContent,
      builder: (BuildContext context, AsyncSnapshot<ClassContent> snapshot) {
        if (snapshot.hasData) {
          _tabs = getClassTabs(snapshot.data!, _bloc.argStream, this.onLinkTap);
          // append theme item tab if needed
          if (snapshot.data!.themeItems != null &&
              snapshot.data!.themeItems!.length > 0) {
            _tabs.add(
              ClassTab(
                title: 'Theme Items',
                child: ClassThemeItems(
                  clsContent: snapshot.data,
                  onLinkTap: onLinkTap,
                  eventStream: _bloc.argStream,
                ),
                showCnt: true,
                itemCount: snapshot.data!.themeItems!.length,
              ),
            );
          }

          if (tabController == null) {
            tabController = TabController(
              vsync: this,
              length: _tabs.length,
            );
          }

          if (widget.args != null &&
              widget.args!.className == snapshot.data!.name) {
            int _tabIndex = _tabs.indexWhere(
                (w) => w.title == linkTypeToString(widget.args!.linkType));
            if (_tabIndex != -1) {
              tabController!.animateTo(_tabIndex);
            }
          }

          return Scaffold(
            appBar: AppBar(
              title:Text(widget.className),
              bottom: TabBar(
                controller: tabController,
                isScrollable: true,
                tabs: _tabs.map((f) {
                  return Tab(
                    child: Row(
                      children: <Widget>[
                        Text(f.title!),
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
              controller: tabController,
              children: _tabs.map((c) {
                return c.child!;
              }).toList(),
            ),
          );
        }
        return Container(
          color:
              StoredValues().themeChange.isDark ? Colors.black : Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class ClassTab {
  ClassTab(
      {this.title,
      this.child,
      this.itemCount,
      this.eventStream,
      this.showCnt = false});

  final String? title;

  final Widget? child;

  final int? itemCount;

  final bool showCnt;

  final Stream<TapEventArg>? eventStream;
}

List<ClassTab> getClassTabs(ClassContent clsContent,
    Stream<TapEventArg?> eventStream, Function(TapEventArg args) onLinkTap) {
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
        eventStream: eventStream,
      ),
      showCnt: true,
      itemCount: clsContent.constants == null
          ? 0
          : clsContent.constants!.where((w) => w.enumValue != null).length,
    ),
    ClassTab(
      title: "Constants",
      child: ClassConstants(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
        eventStream: eventStream,
      ),
      showCnt: true,
      itemCount: clsContent.constants == null
          ? 0
          : clsContent.constants!.where((w) => w.enumValue == null).length,
    ),
    ClassTab(
      title: "Members",
      child: ClassMembers(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
        eventStream: eventStream,
      ),
      showCnt: true,
      itemCount: clsContent.members == null ? 0 : clsContent.members!.length,
    ),
    ClassTab(
      title: "Methods",
      child: ClassMethods(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
        eventStream: eventStream,
      ),
      showCnt: true,
      itemCount: clsContent.methods == null ? 0 : clsContent.methods!.length,
    ),
    ClassTab(
      title: "Signals",
      child: ClassSignals(
        clsContent: clsContent,
        onLinkTap: onLinkTap,
        eventStream: eventStream,
      ),
      showCnt: true,
      itemCount: clsContent.signals == null ? 0 : clsContent.signals!.length,
    )
  ];
}
