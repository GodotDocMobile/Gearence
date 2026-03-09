import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/components/default_class_icon.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/screens/class_detail.dart';
import 'package:godotclassreference/screens/search.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  late Isar docsIsar;
  late SettingsRepository settingsRepo;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    settingsRepo = GetIt.instance<SettingsRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GCRDrawer(),
      appBar: AppBar(
        title: StreamBuilder(
            stream: settingsRepo.watchAllSettings(),
            builder: (context, asyncSnapshot) {
              final currentLocale = settingsRepo.getTranslation().stringValue!;
              final currentVersion =
                  settingsRepo.getGodotVersion().stringValue!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Godot v" + currentVersion + " classes"),
                  double.parse(currentVersion) >= 3.4 && currentLocale != 'en'
                      ? Text(
                          "Translation: " + currentLocale,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        )
                      : SizedBox()
                ],
              );
            }),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
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
                    child: StreamBuilder(
                        stream: settingsRepo
                            .watchSetting(MetadataKeys.monoSpaceFont),
                        builder: (context, asyncSnapshot) {
                          return Text(
                            x.name!,
                            style: monoOptionalStyle(context),
                          );
                        }),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassDetail(className: x.name!),
                        ));
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
