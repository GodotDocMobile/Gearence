import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
import 'package:godotclassreference/screens/doc_seed.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:godotclassreference/screens/set_font_size.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/bloc/blocs.dart';

class GCRDrawer extends StatefulWidget {
  const GCRDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GCRDrawerState();
  }
}

class GCRDrawerState extends State<GCRDrawer> {
  late SettingsRepository settingsRepo;
  late UserSetting versionRecord;
  late UserSetting darkModeRecord;
  late UserSetting monospaceRecord;
  late UserSetting translationRecord;

  @override
  initState() {
    super.initState();
    settingsRepo = GetIt.I();
    versionRecord = settingsRepo.getGodotVersion();
    darkModeRecord = settingsRepo.getIsDarkMode();
    monospaceRecord = settingsRepo.getMonospace();
    translationRecord = settingsRepo.getTranslation();
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
                  title: Text(storedValues.configContent.updateDate!),
                  subtitle: Text('Doc Last Update '),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  title: Text(GetIt.I<PackageInfo>().version),
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
    if (double.parse(versionRecord.stringValue!) < 3.4) {
      return SizedBox();
    }
    return MergeSemantics(
      child: ListTile(
        leading: Icon(Icons.compare_arrows),
        title: Text("Translation"),
        trailing: Semantics(
          onTapHint: 'Select translated language',
          child: DropdownButton<String>(
            value: translationRecord.stringValue!,
            items: [
              DropdownMenuItem(
                child: Text('None'),
                value: 'en',
              ),
              ...storedValues
                  .configContent.branchTranslations[versionRecord.stringValue!]!
                  .map((i) {
                return DropdownMenuItem<String>(
                  value: i,
                  child: Text(i),
                );
              }).toList()
            ],
            onChanged: (v) {
              setState(() {
                settingsRepo.saveSettings(translationRecord..stringValue = v);
              });
              // setState(() {
              //   storedValues.translation = v!;
              // });
              // blocs.translationBloc.add(v!);
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
                  image: AssetImage("project_assets/drawer_header.png"),
                  fit: BoxFit.fitWidth),
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
                  value: versionRecord.stringValue!,
                  items: godotVersions.map((i) {
                    return DropdownMenuItem<String>(
                      value: i,
                      child: Text(i),
                    );
                  }).toList(),
                  onChanged: (v) {
                    blocs.versionBloc.add(v!);
                    setState(() {
                      // storedValues.version = v;
                      settingsRepo.saveSettings(versionRecord..stringValue = v);
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocSeed(),
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
                  value: darkModeRecord.boolValue == true,
                  onChanged: (v) {
                    setState(() {
                      settingsRepo.saveSettings(darkModeRecord..boolValue = v);
                    });
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
                    builder: (context) => SetFontSize(),
                  ));
            },
          ),
          MergeSemantics(
            child: ListTile(
              leading: Icon(Icons.font_download_outlined),
              title: Text('Monospace font'),
              trailing: Switch(
                value: monospaceRecord.boolValue == true,
                onChanged: (v) {
                  // blocs.monospaceFontBloc.add(v);

                  setState(() {
                    settingsRepo.saveSettings(monospaceRecord..boolValue = v);
                  });

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
          // ListTile(
          //   title: Text('I WANT TRANSLATION!'),
          //   onTap: () async {
          //     // const url =
          //     //     'https://hosted.weblate.org/projects/godot-engine/godot-class-reference/';
          //     var url = Uri.parse(
          //         'https://hosted.weblate.org/projects/godot-engine/godot-class-reference/');
          //     if (await launchUrl(url)) {
          //       print("can not launch url $url");
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
