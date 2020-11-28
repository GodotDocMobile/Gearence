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
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/screens/search.dart';

class ClassSelect extends StatefulWidget {
  static Future<List<String>> getXmlFiles() async {
//    await StoredValues().readValue();

    String version = StoredValues().prefs.getString('version');
//    print(version);
    if (version == null || version.length == 0) {
      version = '3.2';
      await StoredValues().prefs.setString('version', version);
    }

    final file = await rootBundle.loadString('xmls/files_' + version + '.json');
    final decoded = json.decode(file);
    final parsedList = List<String>.from(decoded);
    ClassList().updateList(parsedList);
    ClassDB().updateDB(version);
    return parsedList;
  }

  @override
  _ClassSelectState createState() => _ClassSelectState();
}

class _ClassSelectState extends State<ClassSelect> {
  IconForNonNodeBloc _bloc;

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
              drawer: GCRDrawer(
                iconBloc: _bloc,
              ),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                  )
                ],
              ),
              body: ListView(
                  children: snapshot.data
                      .map((f) => Card(
                            child: ListTile(
                              leading: ClassIcon(className: f, bloc: _bloc),
                              title: Text(f
                                  .replaceAll('#Node#', '')
                                  .replaceAll('.xml', '')),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassDetail(
                                          className: f
                                              .replaceAll('#Node#', '')
                                              .replaceAll('.xml', '')),
                                    ));
                              },
                              trailing: f.contains('#Node#') ? NodeTag() : null,
                            ),
                          ))
                      .toList()),
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
