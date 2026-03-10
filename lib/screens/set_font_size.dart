import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:isar_plus/isar_plus.dart';

import 'class_detail.dart';

class SetFontSize extends StatefulWidget {
  const SetFontSize({Key? key}) : super(key: key);

  @override
  _SetFontSizeState createState() => _SetFontSizeState();
}

class _SetFontSizeState extends State<SetFontSize>
    with SingleTickerProviderStateMixin {
  double bottomHeight = 130;

  late SettingsRepository settingsRepository;
  late UserSetting fontSizeRecord;
  late int dbFontSize;
  late int curFontSize;

  bool save = false;

  ClassContent dummyNode = dummyClass;
  // var node = ClassDB().getDB().firstWhere((element) => element.name == 'Node');

  TabController? tabController;
  List<ClassTab> _tabs = [];
  final _streamController = StreamController<TapEventArg?>.broadcast();

  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    final Isar docIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    settingsRepository = GetIt.I();
    fontSizeRecord = settingsRepository.getFontSize();
    curFontSize = fontSizeRecord.intValue!;
    dbFontSize = fontSizeRecord.intValue!;

    final node = docIsar.classContents.where().nameEqualTo('Node').findFirst()!;
    dummyNode.constants = node.constants;
    dummyNode.members = node.members;
    dummyNode.methods = node.methods;
    dummyNode.signals = node.signals;

    setState(() {
      _translationCache = batchTranslate([
        UIInfoKeys.info,
        UIInfoKeys.enumerations,
        UIInfoKeys.constants,
        UIInfoKeys.properties,
        UIInfoKeys.methods,
        UIInfoKeys.signals,
        UIInfoKeys.themeProperties,
        UIInfoKeys.annotations,
      ]);
    });

    _tabs = getClassTabs(dummyNode, context, _translationCache);
    tabController = TabController(
      vsync: this,
      length: _tabs.length,
    );
  }

  @override
  void dispose() {
    if (!save) {
      // StoredValues().fontSize = initFontSize.toInt();

      settingsRepository.saveSettings(fontSizeRecord..intValue = dbFontSize);
    }
    _streamController.close();
    super.dispose();
  }

  Widget itemCountContainer(int itemCount) {
    return Row(
      children: [
        SizedBox(
          width: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          height: 20,
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
      listenWhen: (previous, current) {
        return current.className.isNotEmpty;
      },
      bloc: blocs.tapEventBloc,
      listener: (context, state) {
        blocs.tapEventBloc.reached();
      },
      child: MediaQuery(
        data: scaledMediaQueryData(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text("DummyClass"),
            bottom: TabBar(
              indicatorColor:
                  settingsRepository.getIsDarkMode().boolValue == true
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
              controller: tabController,
              isScrollable: true,
              tabs: _tabs.map((f) {
                return Tab(
                  child: Row(
                    children: [
                      Text(f.title!),
                      f.showCnt ? itemCountContainer(f.itemCount!) : SizedBox()
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          bottomSheet: BottomAppBar(
            height: bottomHeight,
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: Container(
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "A",
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Slider(
                          value: curFontSize.toDouble(),
                          min: 0,
                          max: 4,
                          divisions: 4,
                          onChanged: (v) {
                            setState(() {
                              // StoredValues().fontSize = v.toInt();
                              curFontSize = v.toInt();
                              settingsRepository.saveSettings(
                                  fontSizeRecord..intValue = curFontSize);
                            });
                          },
                        ),
                      ),
                      Text(
                        "A",
                        style: TextStyle(fontSize: 30),
                      )
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    MaterialButton(
                      child: Text("Save"),
                      onPressed: () {
                        save = true;
                        settingsRepository.saveSettings(
                            fontSizeRecord..intValue = curFontSize);
                        Navigator.of(context).pop();
                      },
                      color: Colors.blue,
                    ),
                  ])
                ]),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(bottom: bottomHeight),
            child: TabBarView(
              controller: tabController,
              children: _tabs.map((c) {
                return c.child!;
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

ClassContent dummyClass = new ClassContent(id: -1)
  ..name = "DummyClass"
  ..inherits = "ParentClass"
  ..inheritChain = "[Node] >> [Node2D] >> [Spatial] >> [Control]"
  ..briefDescription =
      "Properties of this class in the rest tabs are from Node."
  ..version = "x.x"
  ..description = """
This is [b]bold Text.[/b]
This is [i]italic Text.[/i]
This is [code]inline code text.[/code]
This is [center]center text.[/center]
Next is two line break.[br]<- One[br]<- Two
This is [u]underline text.[/u]
This is [s] crossed text.[/s]
This is [url] url text.[/url]
This is [url=https://godotengine.org/] a link to official godot engine website.[/url] which is not implemented yet.
This is link to Node
This is link to [Node]
Next is color text

[color=aqua]aqua[/color]
[color=black]black[/color]
[color=blue]blue[/color]
[color=fuchsia]fuchsia[/color]
[color=gray]gray[/color]
[color=grey]grey[/color]
[color=green]green[/color]
[color=lime]lime[/color]
[color=maroon]maroon[/color]
[color=navy]navy[/color]
[color=olive]olive[/color]
[color=purple]purple[/color]
[color=red]red[/color]
[color=silver]silver[/color]
[color=teal]teal[/color]
[color=white]white[/color]
[color=yellow]yellow[/color] 
[codeblock]
# code are from Button class
func _ready():
    var button = Button.new()
    button.text = "Click me"
    button.connect("pressed", self, "_button_pressed")
    add_child(button)

func _button_pressed():
    print("Hello world!")
[/codeblock]
""";
