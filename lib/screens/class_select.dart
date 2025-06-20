import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/bloc/class_list_filter_bloc.dart';
import 'package:godotclassreference/components/class_icon.dart';
import 'package:godotclassreference/components/node_tag.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/screens/search.dart';

class ClassSelect extends StatefulWidget {
  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  ClassListFilterBloc _filterBloc = ClassListFilterBloc();

  List<ClassContent>? _classes =
      []; // we will fill this after all xml files are parsed.

  Map<classNodeType, List<ClassContent>> sortedLists =
      new Map<classNodeType, List<ClassContent>>();

  List<bool> filterOptionValues = <bool>[];

  // we can optimize this by yield when json has loaded,
  // and return when all xml files are loaded.
  Future<bool> getXmlFiles() async {
    ClassDB _db = ClassDB();
    if (_db.getDB().length == 0 || _db.version != storedValues.version) {
      final file = await rootBundle
          .loadString('xmls/files_' + storedValues.version + '.json');
      final decoded = json.decode(file);

      final _decodedList = decoded as List;
      final List<ClassContent> _parsedList =
          List<ClassContent>.from(_decodedList.map((e) {
        final _rtn = new ClassContent();
        _rtn.name = e['class_name'];
        _rtn.inheritChain = e['inherit_chain'];
        _rtn.svgFileName = e['svg_file_name'];
        _rtn.xmlFilePath =
            'xmls/' + storedValues.version + '/' + _rtn.name! + '.xml';
        _rtn.setNodeType();
        return _rtn;
      })).toList();

      ClassDB().loadFromJsonIndex(_parsedList, storedValues.version);
    }
    if (_db.getDB().last.version == null ||
        _db.getDB().last.version?.isEmpty == true) {
      ClassDB().loadFromXmls();
    }
    return true;
  }

  @override
  void initState() {
    // this will create correspond list for each classNodeType
    for (var e in classNodeType.values) {
      sortedLists[e] = <ClassContent>[];
      // not == true here, because value could be null
      filterOptionValues
          .add(StoredValues().prefs.getBool(filterOptionStoreKey[e]!) != false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _filterBloc.close();
    super.dispose();
  }

  List<Widget> buildFilterOptions(StateSetter setStateFunc) {
    List<Widget> ret = <Widget>[
      Text(
        'filtered classes are accessible in search and in-class links',
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
                setStateFunc(() {
                  filterOptionValues[index] = v;
                });
                _filterBloc.add(FilterOption(e, v));
                StoredValues().prefs.setBool(filterOptionStoreKey[e]!, v);
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
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter List Nodes'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: buildFilterOptions(setState),
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

  void _fillTypedList(List<ClassContent>? list) {
    for (var e in classNodeType.values) {
      if (sortedLists[e]!.length == 0) {
        sortedLists[e] =
            list!.where((element) => element.nodeType == e).toList();
      }
    }
  }

  List<ClassContent> filterClasses(List<ClassContent>? list) {
    List<ClassContent> _rtnList = [];
    _fillTypedList(list);
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
      storedValues.fontSize = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getXmlFiles(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            _classes = ClassDB().getDB();
            // _fillTypedList(_classes);
            return Scaffold(
              drawer: GCRDrawer(setScaleFunc: setScale),
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Godot v" + storedValues.version + " classes"),
                    storedValues.versionDouble >= 3.4 &&
                            storedValues.translation != 'en'
                        ? Text(
                            "Translation: " + storedValues.translation,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          )
                        : SizedBox()
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Filter classes shown on the list',
                    icon: Icon(Icons.filter_alt_outlined),
                    onPressed: () {
                      showFilterDialog();
                    },
                  ),
                  IconButton(
                    tooltip: 'Search',
                    icon: Icon(
                      Icons.search,
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
            color: storedValues.isDarkTheme ? Colors.black : Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Widget buildList() {
    return BlocBuilder(
      bloc: _filterBloc,
      builder: (context, state) {
        return ListView(
            children: filterClasses(_classes)
                .map((f) => MediaQuery(
                      data: scaledMediaQueryData(context),
                      child: Card(
                        child: Semantics(
                          label: getSpacedClassName(f.name!),
                          onTapHint: 'Read class detail',
                          child: ListTile(
                            leading: ClassIcon(
                              classContent: f,
                              key: UniqueKey(),
                            ),
                            title: Semantics(
                              excludeSemantics: true,
                              child: Text(
                                f.name!,
                                style: monoOptionalStyle(context),
                              ),
                            ),
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
                        ),
                      ),
                    ))
                .toList());
      },
    );
  }
}
