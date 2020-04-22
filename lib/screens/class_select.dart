import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/components/drawer.dart';

class ClassSelect extends StatelessWidget {
  static Future<List<String>> getXmlFiles() async {
    final file = await rootBundle.loadString('xmls/files_3.0.json');
    final decoded = json.decode(file);
    final parsedList = List<String>.from(decoded);
    ClassList().updateList(parsedList);
    return parsedList;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> jsonContent = getXmlFiles();

    return Scaffold(
      drawer: GCRDrawer(),
      appBar: AppBar(
        title: Text("Classes"),
//          actions: <Widget>[
//            FlatButton(
//              child: Icon(Icons.search),
//              onPressed: () {},
//            )
//          ],
      ),
      body: FutureBuilder<List<String>>(
        future: jsonContent,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            snapshot.data.sort();
            return ListView(
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
                  .toList(),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
