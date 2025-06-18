import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:godotclassreference/screens/set_font_size.dart';
import 'package:godotclassreference/screens/class_select.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/bloc/blocs.dart';

class GCRDrawer extends StatefulWidget {
  final Function(int)? setScaleFunc;

  const GCRDrawer({Key? key, this.setScaleFunc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GCRDrawerState();
  }
}

class GCRDrawerState extends State<GCRDrawer> {
  String? docDate = storedValues.configContent.updateDate;

  void showLoading(BuildContext context, bool isDark) {
    Color tmp =
        isDark ? ThemeData.dark().cardColor : ThemeData.light().cardColor;

    final Color overlayBackground =
        Color.fromARGB(0x99, tmp.red, tmp.green, tmp.green);

    final OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry = OverlayEntry(builder: (context) {
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
    overlayState!.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      overlayEntry!.remove();
      overlayEntry = null;
    });
  }

  Future<void> showAboutDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("About"),
            children: [
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
                  title: Text(storedValues.packageInfo.version),
                  subtitle: Text("Version"),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text("View Source"),
                  subtitle: Text("Issues are welcome!"),
                  onTap: () async {
                    // const url =
                    //     'https://github.com/GodotDocMobile/godot_class_reference';
                    var url =
                        Uri.parse('https://github.com/GodotDocMobile/Gearence');
                    if (!await launchUrl(url)) {
                      print("can not launch url $url");
                    }
                  },
                ),
              )
            ],
          );
        });
  }

  Widget selectTranslation() {
    if (storedValues.versionDouble < 3.4) {
      return SizedBox();
    }
    return MergeSemantics(
      child: ListTile(
        leading: Icon(Icons.compare_arrows),
        title: Text("Translation"),
        trailing: Semantics(
          onTapHint: 'Select translated language',
          child: DropdownButton<String>(
            value: storedValues.translation,
            items: [
              DropdownMenuItem(
                child: Text('None'),
                value: 'en',
              ),
              ...storedValues
                  .configContent.branchTranslations[storedValues.version]!
                  .map((i) {
                return DropdownMenuItem<String>(
                  value: i,
                  child: Text(i),
                );
              }).toList()
            ],
            onChanged: (v) {
              setState(() {
                storedValues.translation = v!;
              });
              blocs.translationBloc.add(v!);
              // Navigator.of(context).pop();
              // setState(() {
              //   storedValues.version = v!;
              // });
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ClassSelect(),
              //     ),
              //     (Route<dynamic> route) => false);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF303d68),
              image: DecorationImage(
                  image: AssetImage("drawer_header.png"), fit: BoxFit.fitWidth),
            ),
            child: Container(),
          ),
          MergeSemantics(
            child: ListTile(
              leading: Icon(Icons.compare_arrows),
              title: Text("Godot Version"),
              trailing: Semantics(
                onTapHint: 'Change godot version',
                child: DropdownButton<String>(
                  value: storedValues.version,
                  items: StoredValues().configContent.branches.map((i) {
                    return DropdownMenuItem<String>(
                      value: i,
                      child: Text(i),
                    );
                  }).toList(),
                  onChanged: (v) {
                    blocs.versionBloc.add(v!);
                    setState(() {
                      storedValues.version = v;
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassSelect(),
                        ),
                        (Route<dynamic> route) => false);
                  },
                ),
              ),
            ),
          ),
          selectTranslation(),
          MergeSemantics(
            child: ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Dark Theme'),
              trailing: Tooltip(
                message: 'dark theme',
                child: Switch(
                  value: storedValues.isDarkTheme,
                  onChanged: (v) {
                    showLoading(context, v);
                    blocs.themeChangeBloc.add(v);
                  },
                ),
              ),
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
          MergeSemantics(
            child: ListTile(
              leading: Icon(Icons.font_download_outlined),
              title: Text('Monospace font'),
              trailing: Switch(
                value: storedValues.isMonospaced,
                onChanged: (v) {
                  blocs.monospaceFontBloc.add(v);
                  // setState(() {
                  //   storedValues.isMonospaced = v;
                  // });
                },
              ),
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
              // const url =
              //     'https://hosted.weblate.org/projects/godot-engine/godot-class-reference/';
              var url = Uri.parse(
                  'https://hosted.weblate.org/projects/godot-engine/godot-class-reference/');
              if (await launchUrl(url)) {
                print("can not launch url $url");
              }
            },
          ),
        ],
      ),
    );
  }
}
