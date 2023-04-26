import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/blocs.dart';

import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/screens/class_detail/class_annotations.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/screens/class_detail/class_constants.dart';
import 'package:godotclassreference/screens/class_detail/class_enums.dart';
import 'package:godotclassreference/screens/class_detail/class_info.dart';
import 'package:godotclassreference/screens/class_detail/class_members.dart';
import 'package:godotclassreference/screens/class_detail/class_methods.dart';
import 'package:godotclassreference/screens/class_detail/class_signals.dart';
import 'package:godotclassreference/screens/class_detail/class_theme_items.dart';

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

  String className = '';

  @override
  void initState() {
    super.initState();
    className = widget.className;
    _classContent = getClassDetail();
    if (blocs.tapEventBloc.state.className.isNotEmpty &&
        blocs.tapEventBloc.state.fieldName.isEmpty) {
      blocs.tapEventBloc.reached();
    }
    if (widget.args != null) {
      blocs.tapEventBloc.add(widget.args!);
    }
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  Future<ClassContent> getClassDetail() async {
    final version = storedValues.version;

    return await ClassDB().getSingle(version, widget.className);
  }

  void onLinkTap(TapEventArg args) async {
    if (args.className == widget.className) {
      int _toFocusTabIndex = _tabs
          .indexWhere((w) => w.title == linkTypeToString(args.propertyType));
      tabController!
          .animateTo(_toFocusTabIndex, duration: Duration(milliseconds: 100));
      if (args.fieldName.isEmpty) {
        blocs.tapEventBloc.reached();
      }
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

  Widget itemCountContainer(int itemCount) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Center(
            child: Text(
              " " + itemCount.toString() + " ",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) =>
          current.className.isNotEmpty && ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        onLinkTap(state);
      },
      child: FutureBuilder<ClassContent>(
        future: _classContent,
        builder: (BuildContext context, AsyncSnapshot<ClassContent> snapshot) {
          if (snapshot.hasData) {
            _tabs = getClassTabs(snapshot.data!);
            // append theme item tab if needed
            if (snapshot.data!.themeItems.length > 0) {
              _tabs.add(
                ClassTab(
                  title: 'Theme Items',
                  child: ClassThemeItems(
                    clsContent: snapshot.data,
                  ),
                  showCnt: true,
                  itemCount: snapshot.data!.themeItems.length,
                ),
              );
            }

            if (snapshot.data!.annotations.length > 0) {
              _tabs.add(ClassTab(
                title: "Annotations",
                child: ClassAnnotations(
                  clsContent: snapshot.data,
                ),
                showCnt: true,
                itemCount: snapshot.data!.annotations.length,
              ));
            }

            if (tabController == null) {
              tabController = TabController(
                vsync: this,
                length: _tabs.length,
              );
            }

            if (widget.args != null &&
                widget.args!.className == snapshot.data!.name) {
              int _tabIndex = _tabs.indexWhere((w) =>
                  w.title == linkTypeToString(widget.args!.propertyType));
              if (_tabIndex != -1) {
                tabController!.animateTo(_tabIndex);
              }
            }

            return MediaQuery(
              data: scaledMediaQueryData(context),
              child: Scaffold(
                appBar: AppBar(
                  title: Semantics(
                      label: getSpacedClassName(widget.className),
                      child: ExcludeSemantics(child: Text(widget.className))),
                  bottom: TabBar(
                    indicatorColor: storedValues.isDarkTheme
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white,
                    controller: tabController,
                    isScrollable: true,
                    tabs: _tabs.map((f) {
                      return Tab(
                        child: Row(
                          children: [
                            Text(f.title!),
                            f.showCnt
                                ? itemCountContainer(f.itemCount!)
                                : SizedBox(),
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
              ),
            );
          }
          return Container(
            color: storedValues.isDarkTheme ? Colors.black : Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
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

List<ClassTab> getClassTabs(ClassContent clsContent) {
  return <ClassTab>[
    ClassTab(
      title: "Info",
      child: ClassInfo(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      title: "Enums",
      child: ClassEnums(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.constants.where((w) => w.enumValue != null).length,
    ),
    ClassTab(
      title: "Constants",
      child: ClassConstants(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.constants.where((w) => w.enumValue == null).length,
    ),
    ClassTab(
      title: "Members",
      child: ClassMembers(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.members.length,
    ),
    ClassTab(
      title: "Methods",
      child: ClassMethods(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.methods.length,
    ),
    ClassTab(
      title: "Signals",
      child: ClassSignals(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.signals.length,
    )
  ];
}
