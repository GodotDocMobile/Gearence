import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:godotclassreference/constants/colors.dart';

import 'package:godotclassreference/screens/class_select.dart';

// ignore: must_be_immutable
class GCRDrawer extends StatelessWidget {
  Future<PackageInfo> pi = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: pi,
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        String _version = snapshot.hasData ? snapshot.data.version : '';
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(color: godotColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Godot Class Reference",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "v $_version",
                            style: TextStyle(color: Colors.white30),
                          ),
                        ],
                      )
                    ],
                  )),
//              ListTile(
//                leading: Icon(Icons.list),
//                title: Text("List Classes"),
//                onTap: () {
//                  Navigator.pop(context); // this will close the drawer
//                  Navigator.push(context,
//                      MaterialPageRoute(builder: (context) => ClassSelect()));
//                },
//              ),
//              ListTile(
//                leading: Icon(Icons.language),
//                title: Text("Language"),
//              ),
              ListTile(
                leading: Icon(Icons.compare_arrows),
                title: Text("Godot Version"),
              ),
//              ListTile(
//                leading: Icon(Icons.color_lens),
//                title: Text("Theme"),
//              )
            ],
          ),
        );
      },
    );
  }
}
