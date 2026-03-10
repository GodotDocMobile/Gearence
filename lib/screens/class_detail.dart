import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/constants/keys.dart';

import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/manager/class_repository.dart';
import 'package:godotclassreference/screens/class_detail/class_annotations.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
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
  late TabController tabController; // No longer nullable
  late ClassContent classContent;
  late List<ClassTab> _tabs;
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();

    // 1. Instant Memory Lookup (No Isar hit!)
    // If ClassDB is init in ClassList, this is O(1)
    classContent = ClassDB.getClass(widget.className)!;

    // 2. Prepare tabs with empty labels initially so UI is non-blocking
    _tabs = getClassTabs(classContent, context, {});
    tabController = TabController(length: _tabs.length, vsync: this);

    // 3. Prepare translations in background
    _prepareUiLabels();

    // 4. Handle deep-links
    if (widget.args != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onLinkTap(widget.args!);
      });
    }
  }

  Future<void> _prepareUiLabels() async {
    // Avoid blocking the 'Slide' transition animation
    await Future.delayed(const Duration(milliseconds: 300));

    final labels = await Future.microtask(() => batchTranslate([
          UIInfoKeys.info,
          UIInfoKeys.enumerations,
          UIInfoKeys.constants,
          UIInfoKeys.properties,
          UIInfoKeys.methods,
          UIInfoKeys.signals,
          UIInfoKeys.themeProperties,
          UIInfoKeys.annotations,
        ]));

    if (mounted) {
      setState(() {
        _translationCache = labels;
        // Update tabs with real labels, but keep existing children
        _tabs = getClassTabs(classContent, context, _translationCache);
      });
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void onLinkTap(TapEventArg args) async {
    if (args.className == widget.className) {
      int _toFocusTabIndex =
          _tabs.indexWhere((w) => w.type == args.propertyType);
      tabController.animateTo(_toFocusTabIndex,
          duration: Duration(milliseconds: 100));
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
      child: Builder(builder: (context) {
        _tabs = getClassTabs(classContent, context, _translationCache);

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
      }),
    );
  }
}

class ClassTab {
  ClassTab(this.type,
      {this.title,
      this.child,
      this.itemCount,
      this.eventStream,
      this.showCnt = false});

  final String? title;

  final PropertyType type;

  final Widget? child;

  final int? itemCount;

  final bool showCnt;

  final Stream<TapEventArg>? eventStream;
}

List<ClassTab> getClassTabs(ClassContent clsContent, BuildContext context,
    Map<String, String> _translationCache) {
  var _tabs = <ClassTab>[
    ClassTab(
      PropertyType.Class,
      title: _translationCache[UIInfoKeys.info] ?? UIInfoKeys.info,
      child: ClassInfo(
        clsContent: clsContent,
      ),
    ),
    ClassTab(
      PropertyType.Enum,
      title:
          _translationCache[UIInfoKeys.enumerations] ?? UIInfoKeys.enumerations,
      child: ClassEnums(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.constants.where((w) => w.enumValue != null).length,
    ),
    ClassTab(
      PropertyType.Constant,
      title: _translationCache[UIInfoKeys.constants] ?? UIInfoKeys.constants,
      child: ClassConstants(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.constants.where((w) => w.enumValue == null).length,
    ),
    ClassTab(
      PropertyType.Property,
      title: _translationCache[UIInfoKeys.properties] ?? UIInfoKeys.properties,
      child: ClassMembers(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.members.length,
    ),
    ClassTab(
      PropertyType.Method,
      title: _translationCache[UIInfoKeys.methods] ?? UIInfoKeys.methods,
      child: ClassMethods(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.methods.length,
    ),
    ClassTab(
      PropertyType.Signal,
      title: _translationCache[UIInfoKeys.signals] ?? UIInfoKeys.signals,
      child: ClassSignals(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.signals.length,
    )
  ];

  if (clsContent.themeItems.length > 0) {
    _tabs.add(
      ClassTab(
        PropertyType.ThemeItem,
        title: _translationCache[UIInfoKeys.themeProperties] ??
            UIInfoKeys.themeProperties,
        child: ClassThemeItems(
          clsContent: clsContent,
        ),
        showCnt: true,
        itemCount: clsContent.themeItems.length,
      ),
    );
  }

  if (clsContent.annotations.length > 0) {
    _tabs.add(ClassTab(
      PropertyType.Annotation,
      title:
          _translationCache[UIInfoKeys.annotations] ?? UIInfoKeys.annotations,
      child: ClassAnnotations(
        clsContent: clsContent,
      ),
      showCnt: true,
      itemCount: clsContent.annotations.length,
    ));
  }

  return _tabs;
}
