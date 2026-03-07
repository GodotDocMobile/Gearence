import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/components/default_class_icon.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  late Isar docsIsar;
  // late Isar prefsIsar;
  late SettingsRepository settingsRepo;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    settingsRepo = GetIt.instance<SettingsRepository>();
    // prefsIsar = GetIt.I(instanceName: MetadataKeys.preferenceIsarKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: GCRDrawer(setScaleFunc: setScale),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Godot v" +
                settingsRepo.getGodotVersion().stringValue! +
                " classes"),
            double.parse(settingsRepo.getGodotVersion().stringValue!) >= 3.4 &&
                    settingsRepo.getLanguage().stringValue != 'en'
                ? Text(
                    "Translation: " + settingsRepo.getLanguage().stringValue!,
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
              // showFilterDialog();
            },
          ),
          IconButton(
            tooltip: 'Search',
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          )
        ],
      ),
      body: ListView(
        children:
            docsIsar.classContents.where().sortByName().findAll().map((x) {
          return MediaQuery(
            data: scaledMediaQueryData(context),
            child: Card(
              child: Semantics(
                label: getSpacedClassName(x.name!),
                onTapHint: 'Read class detail',
                child: ListTile(
                  leading: x.svgFileName != null && x.svgFileName!.isNotEmpty
                      ? SvgIcon(
                          svgContent: docsIsar.godotIcons
                              .where()
                              .fileNameEqualTo(x.svgFileName!)
                              .findFirst()!
                              .content,
                          key: UniqueKey(),
                        )
                      : const DefaultClassIcon(),
                  title: Semantics(
                    excludeSemantics: true,
                    child: Text(
                      x.name!,
                      style: monoOptionalStyle(context),
                    ),
                  ),
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           ClassDetail(className: f.name!),
                    //     ));
                  },
                  // trailing: f.nodeType == classNodeType.None
                  //     ? null
                  //     : NodeTag(classContent: f),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
