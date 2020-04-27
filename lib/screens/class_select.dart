import 'dart:async';
import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/components/drawer.dart';

const appId = 'ca-app-pub-3569371273195353~4389051701';
const appUnitId = 'ca-app-pub-3569371273195353/9278184798';

class ClassSelect extends StatefulWidget {
  static Future<List<String>> getXmlFiles() async {
    await StoredValues().readValue();

    String version = StoredValues().prefs.getString('version');
//    print(version);
    if (version == null || version.length == 0) {
      version = '3.0';
      await StoredValues().prefs.setString('version', '3.0');
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
    FirebaseAdMob.instance.initialize(appId: appId);
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
              ),
              body: ListView(
                  children: snapshot.data
                      .map((f) => ListTile(
                          title: Text(f.replaceAll('.xml', '')),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetail(
                                      className: f.replaceAll('.xml', '')),
                                ));
                          }))
                      .toList()),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
