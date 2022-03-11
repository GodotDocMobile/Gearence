import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/set_font_size.dart';
import '../screens/class_select.dart';
import '../constants/stored_values.dart';

// ignore: must_be_immutable
class GCRDrawer extends StatefulWidget {
  final Function(int)? setScaleFunc;

  const GCRDrawer({Key? key, this.setScaleFunc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GCRDrawerState();
  }
}

class GCRDrawerState extends State<GCRDrawer> {
  String? godotVersion;
  late PackageInfo pi;
  String? docDate;
  bool? darkTheme;
  bool? monoSpaceFont;

  OverlayState? overlayState;
  OverlayEntry? overlayEntry;

  Color? overlayBackground;

  @override
  initState() {
    super.initState();
    StoredValues().themeChange.addListener(() async {
      if (overlayEntry != null) {
        await Future.delayed(Duration(milliseconds: 500));
        overlayEntry!.remove();
        overlayEntry = null;
      }
    });
  }

  void showLoading(BuildContext context, bool isDark) {
    Color tmp =
        isDark ? ThemeData.dark().cardColor : ThemeData.light().cardColor;
    overlayBackground = Color.fromARGB(0x99, tmp.red, tmp.green, tmp.green);

    overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Container(
        color: overlayBackground,
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            child: Card(
              elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Loading Theme",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CircularProgressIndicator(strokeWidth: 5),
                ],
              ),
            ),
          ),
        ),
      );
    });
    overlayState!.insert(overlayEntry!);
  }

  Future<bool> loadAll() async {
    pi = await PackageInfo.fromPlatform();
    godotVersion = storedValues.prefs!.getString('version')!.substring(0);
    darkTheme = storedValues.prefs!.getBool('darkTheme') ?? false;
    docDate = storedValues.configContent.updateDate;
    monoSpaceFont = storedValues.monospaced.monospaced;
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
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text(docDate!),
                  subtitle: Text('Doc Last Update '),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text(pi.version),
                  subtitle: Text("Version"),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text("View Source"),
                  subtitle: Text("Issues are welcome!"),
                  onTap: () async {
                    const url =
                        'https://github.com/GodotDocMobile/godot_class_reference';
                    if (!await launch(url)) {
                      print("can not launch url $url");
                    }
                  },
                ),
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaded = loadAll();
    return FutureBuilder<bool>(
      future: loaded,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF303d68),
                    image: DecorationImage(
                        image: AssetImage("drawer_header.png"),
                        fit: BoxFit.fitWidth),
                  ),
                  child: Container(),
                ),
                ListTile(
                  leading: Icon(Icons.compare_arrows),
                  title: Text("Godot Version"),
                  trailing: DropdownButton<String>(
                    value: godotVersion,
                    items: StoredValues().configContent.branches.map((i) {
                      return DropdownMenuItem<String>(
                        value: i,
                        child: Text(i),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        godotVersion = v;
                      });
                      StoredValues().prefs!.setString('version', v!);
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
                    value: darkTheme!,
                    onChanged: (v) {
                      showLoading(context, v);
                      StoredValues().prefs!.setBool('darkTheme', v);
                      setState(() {
                        darkTheme = v;
                      });
                      StoredValues().themeChange.switchTheme(v);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text("Set text size"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SetFontSize(setScaleFunc: widget.setScaleFunc),
                        ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.font_download_outlined),
                  title: Text('Monospace font'),
                  trailing: Switch(
                    value: monoSpaceFont!,
                    onChanged: (v) {
                      storedValues.prefs!.setBool('monoSpaceFont', v);
                      setState(() {
                        storedValues.monospaced.setMonospaced(v);
                        monoSpaceFont = v;
                      });
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
                ListTile(
                  title: Text('I WANT TRANSLATION!'),
                  onTap: () async {
                    const url =
                        'https://hosted.weblate.org/projects/godot-engine/godot-class-reference/';
                    if (await launch(url)) {
                      print("can not launch url $url");
                    }
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
