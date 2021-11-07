import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/themes.dart';
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
  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  late ClassListFilterBloc _filterBloc;

  List<ClassContent>? _classes = [];

  Map<classNodeType, List<ClassContent>> sortedLists =
      new Map<classNodeType, List<ClassContent>>();

  List<bool> filterOptionValues = <bool>[];

  // this will create correspond list for each classNodeType
  void initialize() {
    for (var e in classNodeType.values) {
      sortedLists[e] = <ClassContent>[];
      // not == true here, because value could be null
      filterOptionValues.add(
          StoredValues().prefs!.getBool(filterOptionStoreKey[e]!) != false);
    }
  }

  static Future<List<ClassContent>> getXmlFiles() async {
    String? version = StoredValues().prefs!.getString('version');
    if (version == null || version.length == 0) {
      version = '3.4';
      await StoredValues().prefs!.setString('version', version);
    }

    final file = await rootBundle.loadString('xmls/files_' + version + '.json');
    final decoded = json.decode(file);

    final _decodedList = decoded as List;
    final List<ClassContent> _parsedList =
        List<ClassContent>.from(_decodedList.map((e) {
      final _rtn = new ClassContent();
      _rtn.name = e['class_name'];
      _rtn.inheritChain = e['inherit_chain'];
      _rtn.setNodeType();
      return _rtn;
    })).toList();
    ClassDB().updateList(_parsedList);
    ClassDB().updateDB(version);
    return _parsedList;
  }

  @override
  void initState() {
    _filterBloc = new ClassListFilterBloc();
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _filterBloc.dispose();
    super.dispose();
  }

  List<Widget> buildFilterOptions() {
    List<Widget> ret = <Widget>[
      Text(
        'you can navigate and search filtered classes',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    ];

    for (var e in classNodeType.values) {
      if (sortedLists[e]!.length > 0) {
        int index = classNodeType.values.indexOf(e);
        ret.add(ListTile(
          title: Text(filterName[e]!),
          trailing: Switch(
              value: filterOptionValues[index],
              onChanged: (v) {
                setState(() {
                  filterOptionValues[index] = v;
                });
                _filterBloc.argSink.add(FilterOption(e, v));
                StoredValues().prefs!.setBool(filterOptionStoreKey[e]!, v);
              }),
        ));
      }
    }

    return ret;
  }

  Future<void> showFilterDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Filter List Nodes'),
            content: SingleChildScrollView(
              child: StreamBuilder<FilterOption>(
                  stream: _filterBloc.argStream,
                  builder: (context, snapshot) {
                    return ListBody(
                      children: buildFilterOptions(),
                    );
                  }),
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
  }

  void _sortClasses(List<ClassContent>? list) async {
    for (var e in classNodeType.values) {
      if (sortedLists[e]!.length == 0) {
        sortedLists[e] =
            list!.where((element) => element.nodeType == e).toList();
      }
    }
  }

  List<ClassContent> filterClasses(List<ClassContent>? list) {
    List<ClassContent> _rtnList = [];
    _sortClasses(list);
    for (var e in classNodeType.values) {
      if (filterOptionValues[classNodeType.values.indexOf(e)]) {
        _rtnList.addAll(sortedLists[e]!);
      }
    }
    _rtnList.sort((a, b) {
      return a.name!.compareTo(b.name!);
    });
    return _rtnList;
  }

  void setScale(int value) {
    setState(() {
      StoredValues().prefs!.setInt('gcrFontSize', value);
      StoredValues().fontSize = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getXmlFiles(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ClassContent>> snapshot) {
          if (snapshot.hasData) {
            _classes = snapshot.data;
            _sortClasses(_classes);
            return MediaQuery(
              data: scaledMediaQueryData(context),
              child: Scaffold(
                // resizeToAvoidBottomPadding: true,
                drawer: GCRDrawer(setScaleFunc: setScale),
                appBar: AppBar(
                  title: Text("Godot v" +
                      StoredValues().prefs!.getString('version')! +
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
        });
  }

  Widget buildList() {
    return StreamBuilder<FilterOption>(
        stream: _filterBloc.argStream,
        builder: (context, snapshot) {
          var _widget = ListView(
              children: filterClasses(_classes)
                  .map((f) => Card(
                        child: ListTile(
                          leading: ClassIcon(
                            classContent: f,
                            key: UniqueKey(),
                          ),
                          title: Text(f.name!),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClassDetail(className: f.name!),
                                ));
                          },
                          trailing: f.nodeType == classNodeType.None
                              ? null
                              : NodeTag(classContent: f),
                        ),
                      ))
                  .toList());
          return _widget;
        });
  }
}
