import 'dart:async';
import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/theme/default.dart';
import 'package:godotclassreference/theme/themes.dart';

import '../bloc/tap_event_arg.dart';
import '../constants/class_db.dart';
import '../models/class_content.dart';

import 'class_detail.dart';

class SetFontSize extends StatefulWidget {
  final Function(int)? setScaleFunc;

  const SetFontSize({Key? key, this.setScaleFunc}) : super(key: key);

  @override
  _SetFontSizeState createState() => _SetFontSizeState();
}

class _SetFontSizeState extends State<SetFontSize>
    with SingleTickerProviderStateMixin {
  int settingsFontSize = StoredValues().fontSize!;
  int initFontSize = StoredValues().fontSize!;
  bool save = false;

  ClassContent dummyNode = dummyClass;
  var node = ClassDB().getDB().firstWhere((element) => element.name == 'Node');

  TabController? tabController;
  List<ClassTab> _tabs = [];
  final _streamController = StreamController<TapEventArg?>.broadcast();

  @override
  void initState() {
    dummyNode.constants = node.constants;
    dummyNode.members = node.members;
    dummyNode.methods = node.methods;
    dummyNode.signals = node.signals;
    _tabs = getClassTabs(dummyNode, _streamController.stream, (args) {});
    tabController = TabController(
      vsync: this,
      length: _tabs.length,
    );
    super.initState();
  }

  @override
  void dispose() {
    if (!save) {
      StoredValues().fontSize = initFontSize.toInt();
    }
    super.dispose();
  }

  Widget itemCountContainer(int itemCount) {
    return Row(
      children: <Widget>[
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
    return MediaQuery(
      data: scaledMediaQueryData(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Node"),
          bottom: TabBar(
            indicatorColor: StoredValues().themeChange.isDark
                ? Theme.of(context).colorScheme.secondary
                : Colors.white,
            controller: tabController,
            isScrollable: true,
            tabs: _tabs.map((f) {
              return Tab(
                child: Row(
                  children: <Widget>[
                    Text(f.title!),
                    f.showCnt ? itemCountContainer(f.itemCount!) : SizedBox()
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        bottomSheet: BottomAppBar(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              height: 100,
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
                        value: settingsFontSize.toDouble(),
                        min: 0,
                        max: 4,
                        divisions: 4,
                        onChanged: (v) {
                          setState(() {
                            StoredValues().fontSize = v.toInt();
                            settingsFontSize = v.toInt();
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
                      widget.setScaleFunc!(settingsFontSize.toInt());
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
          padding: EdgeInsets.only(
              bottom: 100 + MediaQuery.of(context).padding.bottom),
          child: TabBarView(
            controller: tabController,
            children: _tabs.map((c) {
              return c.child!;
            }).toList(),
          ),
        ),
      ),
    );
  }
}

ClassContent dummyClass = new ClassContent(
    name: "ClassName",
    inherits: "ParentClass",
    inheritChain: "[Node] >> [Node2D] >> [Spatial] >> [Control]",
    briefDescription:
        "Properties of this class in the rest tabs are from Node.",
    version: "x.x",
    description: """
This is [b]bold Text.[/b]
This is [i]italic Text.[/i]
This is [code]inline code text.[/code]
This is [center]center text.[/center]
Next is two line break.[br]<- One[br]<- Two
This is [u]underline text.[/u]
This is [s] crossed text.[/s]
This is [url] url text.[/url]
This is [url=https://godotengine.org/] a link to official godot engine website.[/url] which is not implemented yet.
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
""");
