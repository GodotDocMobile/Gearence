import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:package_info/package_info.dart';

import 'package:godotclassreference/constants/colors.dart';

import 'package:godotclassreference/screens/class_select.dart';

// ignore: must_be_immutable
class GCRDrawer extends StatefulWidget {
//  String _version = '';
//  String godotVersion = StoredValues().prefs.getString('version').substring(0);

  @override
  State<StatefulWidget> createState() {
    return GCRDrawerState();
  }
}

class GCRDrawerState extends State<GCRDrawer> {
//  Future<PackageInfo>
  String godotVersion;
  PackageInfo pi;
  String docDate;
  bool darkTheme;

  Future<bool> loadAll() async {
//    await PackageInfo.fromPlatform();
//    await StoredValues().readValue();
    pi = await PackageInfo.fromPlatform();
    godotVersion = StoredValues().prefs.getString('version').substring(0);
    darkTheme = StoredValues().prefs.getBool('darkTheme') == null
        ? false
        : StoredValues().prefs.getBool('darkTheme');
    docDate = StoredValues().docDate;
//    print(StoredValues().docDate);
    return true;
  }

  Future<void> showAboutDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("About"),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text(docDate),
                  subtitle: Text('Doc Last Update '),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text(pi.version),
                  subtitle: Text("Version"),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final loaded = loadAll();
    return FutureBuilder<bool>(
      future: loaded,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("drawer_header.png"),
                        fit: BoxFit.cover),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.compare_arrows),
                  title: Text("Godot Version"),
                  trailing: DropdownButton<String>(
                    value: godotVersion,
                    items: <String>['2.0', '2.1', '3.0', '3.1', '3.2'].map((i) {
                      return DropdownMenuItem<String>(
                        value: i,
                        child: Text(i),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        godotVersion = v;
                      });
                      StoredValues().prefs.setString('version', v);
//                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassSelect(),
                          ),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.brightness_6),
                  title: Text('Dark Theme'),
                  trailing: Switch(
                    value: darkTheme,
                    onChanged: (v) {
                      StoredValues().prefs.setBool('darkTheme', v);
                      StoredValues().themeChange.switchTheme(v);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About"),
                  onTap: () {
                    showAboutDialog();
                  },
                ),
              ],
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
      },
    );
  }
}
