import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/components/svg_icon.dart';

import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/screens/search.dart';

class ClassSelect extends StatefulWidget {
  static Future<List<String>> getXmlFiles() async {
    await StoredValues().readValue();

    String version = StoredValues().prefs.getString('version');
//    print(version);
    if (version == null || version.length == 0) {
      version = '3.0';
      await StoredValues().prefs.setString('version', '3.2');
    }

    final file = await rootBundle.loadString('xmls/files_' + version + '.json');
    final decoded = json.decode(file);
    final parsedList = List<String>.from(decoded);
    ClassList().updateList(parsedList);
    return parsedList;
  }

  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> jsonContent = ClassSelect.getXmlFiles();

    return FutureBuilder(
        future: jsonContent,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            snapshot.data.sort();
            return Scaffold(
              resizeToAvoidBottomPadding: true,
              drawer: GCRDrawer(),
              appBar: AppBar(
                title: Text("Godot v" +
                    StoredValues().prefs.getString('version') +
                    " classes"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) => SearchScreen()));

                      showSearch(
                          context: context,
                          delegate: ClassSelectSearchDelegate());
                    },
                  )
                ],
              ),
              body: ListView(
                  children: snapshot.data
                      .map((f) => Card(
                            child: ListTile(
                                leading: SvgIcon(
                                  className: f,
                                  version:
                                      StoredValues().prefs.getString('version'),
                                ),
                                title: Text(f.replaceAll('.xml', '')),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClassDetail(
                                            className:
                                                f.replaceAll('.xml', '')),
                                      ));
                                }),
                          ))
                      .toList()),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class ClassSelectSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length == 0) {
      return Container();
    }

    final _lowerQuery = query.toLowerCase();

    final _resultList = ClassList().getList().where(
        (e) => e.toLowerCase().contains(_lowerQuery.replaceAll(' ', '')));

    final _toMapList = _resultList.toList();
    _toMapList.sort((a, b) => a
        .toLowerCase()
        .indexOf(_lowerQuery)
        .compareTo(b.toLowerCase().indexOf(_lowerQuery)));

    return ListView(
      children: _toMapList.map((c) {
        return ListTile(
          title: Text(
            c.substring(0, c.length - 4),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClassDetail(className: c.replaceAll('.xml', '')),
                ));
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
