import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/class_list_filter_bloc.dart';
import '../components/class_icon.dart';
import '../components/node_tag.dart';
import '../components/drawer.dart';
import '../constants/class_db.dart';
import '../constants/stored_values.dart';
import '../models/class_content.dart';
import '../screens/class_detail.dart';
import '../screens/search.dart';

class ClassSelect extends StatefulWidget {
  static Future<List<ClassContent>> getXmlFiles() async {
    String version = StoredValues().prefs.getString('version');
    if (version == null || version.length == 0) {
      version = '3.3';
      await StoredValues().prefs.setString('version', version);
    }

    final file = await rootBundle.loadString('xmls/files_' + version + '.json');
    final decoded = json.decode(file);

    final _decodedList = decoded as List;
    final List<ClassContent> _parsedList =
        List<ClassContent>.from(_decodedList.map((e) {
      final _rtn = new ClassContent();
      _rtn.name = e['class_name'];
      _rtn.inheritChain = e['inherit_chain'];
      return _rtn;
    })).toList();
    ClassDB().updateList(_parsedList);
    ClassDB().updateDB(version);
    return _parsedList;
  }

  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  ClassListFilterBloc _filterBloc;

  List<ClassContent> _classes = [];

  // ignore: non_constant_identifier_names
  List<ClassContent> _2dNodes = [];
  // ignore: non_constant_identifier_names
  List<ClassContent> _3dNodes = [];
  List<ClassContent> _controlNodes = [];
  List<ClassContent> _otherNodes = [];
  List<ClassContent> _nonNodes = [];

  @override
  void initState() {
    _2dNodes.clear();
    _3dNodes.clear();
    _controlNodes.clear();
    _otherNodes.clear();
    _nonNodes.clear();
    _filterBloc = ClassListFilterBloc();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> showFilterDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter List Nodes'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      'you can navigate and search filtered classes',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    ListTile(
                      title: Text('2D Nodes'),
                      trailing: Switch(
                          value: StoredValues().show2DNodes,
                          onChanged: (v) {
                            setState(() {
                              StoredValues().show2DNodes = v;
                              _filterBloc.argSink
                                  .add(FilterOption(FilterType.Node2D, v));
                              StoredValues().prefs.setBool("show2DNodes", v);
                            });
                          }),
                    ),
                    ListTile(
                      title: Text('3D Nodes'),
                      trailing: Switch(
                        value: StoredValues().show3DNodes,
                        onChanged: (v) {
                          setState(() {
                            StoredValues().show3DNodes = v;
                            _filterBloc.argSink
                                .add(FilterOption(FilterType.Node3D, v));
                            StoredValues().prefs.setBool("show3DNodes", v);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Control Nodes'),
                      trailing: Switch(
                        value: StoredValues().showControlNodes,
                        onChanged: (v) {
                          setState(() {
                            StoredValues().showControlNodes = v;
                            _filterBloc.argSink
                                .add(FilterOption(FilterType.NodeControl, v));
                            StoredValues().prefs.setBool("showControlNodes", v);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Other Nodes'),
                      trailing: Switch(
                        value: StoredValues().showOtherNodes,
                        onChanged: (v) {
                          setState(() {
                            StoredValues().showOtherNodes = v;
                            _filterBloc.argSink
                                .add(FilterOption(FilterType.NodeOther, v));
                            StoredValues().prefs.setBool("showOtherNodes", v);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Non Nodes'),
                      trailing: Switch(
                        value: StoredValues().showNonNodes,
                        onChanged: (v) {
                          setState(() {
                            StoredValues().showNonNodes = v;
                            _filterBloc.argSink
                                .add(FilterOption(FilterType.NonNode, v));
                            StoredValues().prefs.setBool("showNonNodes", v);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close")),
              ],
            );
          });
        });
  }

  void _sortClasses(List<ClassContent> list) async {
    List<ClassContent> _filteredClasses = List<ClassContent>.from(list);
    if (_2dNodes.length == 0) {
      _2dNodes = _filteredClasses
          .where((element) => element.belong('Node2D'))
          .toList();
    }

    if (_3dNodes.length == 0) {
      _3dNodes = _filteredClasses
          .where((element) => element.belong('Spatial'))
          .toList();
    }

    if (_controlNodes.length == 0) {
      _controlNodes = _filteredClasses
          .where((element) => element.belong('Control'))
          .toList();
    }

    if (_otherNodes.length == 0) {
      _otherNodes = _filteredClasses.where((element) {
        var _allNames = '[${element.name}]${element.inheritChain}';
        return _allNames.contains('[Node]') &&
            !_allNames.contains('Node2D') &&
            !_allNames.contains('[Spatial]') &&
            !_allNames.contains('[Control]');
      }).toList();
    }

    if (_nonNodes.length == 0) {
      _nonNodes = _filteredClasses.where((element) {
        var _allNames = '[${element.name}]${element.inheritChain}';
        return !_allNames.contains('[Node]');
      }).toList();
    }
  }

  List<ClassContent> filterClasses(List<ClassContent> list) {
    List<ClassContent> _rtnList = [];
    _sortClasses(list);
    if (StoredValues().show2DNodes) {
      _rtnList.addAll(_2dNodes);
    }

    if (StoredValues().show3DNodes) {
      _rtnList.addAll(_3dNodes);
    }

    if (StoredValues().showControlNodes) {
      _rtnList.addAll(_controlNodes);
    }

    if (StoredValues().showOtherNodes) {
      _rtnList.addAll(_otherNodes);
    }

    if (StoredValues().showNonNodes) {
      _rtnList.addAll(_nonNodes);
    }

    _rtnList.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    return _rtnList;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<ClassContent>> jsonContent = ClassSelect.getXmlFiles();

    return FutureBuilder(
        future: jsonContent,
        builder:
            (BuildContext context, AsyncSnapshot<List<ClassContent>> snapshot) {
          if (snapshot.hasData) {
            _classes = snapshot.data;
            _sortClasses(_classes);
            return Scaffold(
              // resizeToAvoidBottomPadding: true,
              drawer: GCRDrawer(),
              appBar: AppBar(
                title: Text("Godot v" +
                    StoredValues().prefs.getString('version') +
                    " classes"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.filter_alt_outlined),
                    onPressed: () {
                      showFilterDialog();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                  )
                ],
              ),
              body: buildList(),
            );
          }

          return Container(
            color:
                StoredValues().themeChange.isDark ? Colors.black : Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Widget buildList() {
    return StreamBuilder<FilterOption>(
        stream: _filterBloc.argStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.type) {
              case FilterType.Node2D:
                StoredValues().show2DNodes = snapshot.data.value;
                break;
              case FilterType.Node3D:
                StoredValues().show3DNodes = snapshot.data.value;
                break;
              case FilterType.NodeControl:
                StoredValues().showControlNodes = snapshot.data.value;
                break;
              case FilterType.NodeOther:
                StoredValues().showOtherNodes = snapshot.data.value;
                break;
              case FilterType.NonNode:
                StoredValues().showNonNodes = snapshot.data.value;
                break;
            }
          }

          var _widget = ListView(
              children: filterClasses(_classes)
                  .map((f) => Card(
                        child: ListTile(
                          leading: ClassIcon(
                            classContent: f,
                            key: UniqueKey(),
                          ),
                          title: Text(f.name),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClassDetail(className: f.name),
                                ));
                          },
                          trailing: f.belong('Node')
                              ? NodeTag(
                                  classContent: f,
                                )
                              : null,
                        ),
                      ))
                  .toList());

          return _widget;
        });
  }
}
