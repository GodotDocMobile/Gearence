import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/bloc/icon_for_non_node_bloc.dart';
import 'package:godotclassreference/components/class_icon.dart';
import 'package:godotclassreference/components/node_tag.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/class_db.dart';

import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/screens/search.dart';

class ClassSelect extends StatefulWidget {
  static Future<List<ClassContent>> getXmlFiles() async {
//    await StoredValues().readValue();

    String version = StoredValues().prefs.getString('version');
//    print(version);
    if (version == null || version.length == 0) {
      version = '3.2';
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
    // final _parsedList = List<ClassContent>.from();
    // final parsedList = List<String>.from(decoded);
    ClassDB().updateList(_parsedList);
    ClassDB().updateDB(version);
    return _parsedList;
  }

  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  IconForNonNodeBloc _bloc;
  bool show2DNode = true;
  bool show3DNode = true;
  bool showControlNode = true;
  bool showOtherNode = true;
  bool showNonNode = true;

  List<ClassContent> _classes = List<ClassContent>();

  @override
  void initState() {
    _bloc = IconForNonNodeBloc();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.dispose();
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
                          value: show2DNode,
                          onChanged: (v) {
                            setState(() {
                              show2DNode = v;
                              _classes = filterClasses(_classes);
                            });
                          }),
                    ),
                    ListTile(
                      title: Text('3D Nodes'),
                      trailing: Switch(
                        value: show3DNode,
                        onChanged: (v) {
                          show3DNode = v;
                          _classes = filterClasses(_classes);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Control Nodes'),
                      trailing: Switch(
                        value: showControlNode,
                        onChanged: (v) {
                          setState(() {
                            showControlNode = v;
                            _classes = filterClasses(_classes);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Other Nodes'),
                      trailing: Switch(
                        value: showOtherNode,
                        onChanged: (v) {
                          setState(() {
                            showOtherNode = v;
                            _classes = filterClasses(_classes);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Non Nodes'),
                      trailing: Switch(
                        value: showNonNode,
                        onChanged: (v) {
                          setState(() {
                            showNonNode = v;
                            _classes = filterClasses(_classes);
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

  List<ClassContent> filterClasses(List<ClassContent> list) {
    List<ClassContent> _classes = List<ClassContent>.from(list);

    List<String> _filtered = [];
    if (!show2DNode) {
      _filtered.add('Node2D');
    }
    if (!show3DNode) {
      _filtered.add('Node3D');
    }
    if (!showControlNode) {
      _filtered.add('Control');
    }
    // if (!showOtherNode) {
    //   _filtered.add('Node');
    // }

    if (!showOtherNode) {
      _classes = _classes.where((element) {
        var _allNames = '[${element.name}]${element.inheritChain}';
        return !_allNames.contains('Node2D') &&
            !_allNames.contains('Node3D') &&
            !_allNames.contains('Control') &&
            !_allNames.contains('[Node]');
      }).toList();
    }
    _classes = _classes.where((e) {
      bool result = true;
      for (var i in _filtered) {
        var _allNames = '[${e.name}]${e.inheritChain}';
        result = result && !_allNames.contains('[$i]');
        if (!result) break;
      }
      return result;
    }).toList();

    if (!showNonNode) {
      _classes = _classes.where((element) {
        var _allNames = '[${element.name}]${element.inheritChain}';
        return _allNames.contains('[Node]');
      }).toList();
    }
    return _classes;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<ClassContent>> jsonContent = ClassSelect.getXmlFiles();

    return FutureBuilder(
        future: jsonContent,
        builder:
            (BuildContext context, AsyncSnapshot<List<ClassContent>> snapshot) {
          if (snapshot.hasData) {
            snapshot.data.sort((a, b) {
              return a.name.compareTo(b.name);
            });

            // if (!show2DNode) {
            //   _classes = _classes.where((e) {
            //     return !e.inheritChain.contains('[Node2D]') &&
            //         e.name != 'Node2D';
            //   });
            // }
            //
            // if (!show3DNode) {
            //   _classes = _classes.where((e) {
            //     return !e.inheritChain.contains('[Node2D]') &&
            //         e.name != 'Node2D';
            //   });
            // }
            //
            // if (!showControlNode) {
            //   _classes = _classes.where((e) {
            //     return !e.inheritChain.contains('[Control]') &&
            //         e.name != 'Control';
            //   });
            // }

            return Scaffold(
              resizeToAvoidBottomPadding: true,
              drawer: GCRDrawer(
                iconBloc: _bloc,
              ),
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
              body: StatefulBuilder(builder: (context, setState) {
                _classes = filterClasses(snapshot.data.toList());

                return ListView(
                    children: _classes
                        .map((f) => Card(
                              child: ListTile(
                                leading:
                                    ClassIcon(className: f.name, bloc: _bloc),
                                title: Text(f.name),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ClassDetail(className: f.name),
                                      ));
                                },
                                trailing: f.inheritChain != null &&
                                            f.inheritChain.contains('[Node]') ||
                                        f.name == 'Node'
                                    ? NodeTag()
                                    : null,
                                // f.name.contains('#Node#') ? NodeTag() : null,
                              ),
                            ))
                        .toList());
              }),
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
}
