import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/components/default_class_icon.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/components/node_tag.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/sematic_helpers.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/isar/schema/user_setting.dart';
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
  late List<ClassContent> classes;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    settingsRepo = GetIt.instance<SettingsRepository>();
    _refreshList();
    _loadIcons();
  }

  Map<String, String> _iconCache = {};

  void _loadIcons() async {
    // Fetch all icons into memory once. Godot has ~500-1000 icons,
    // which fits easily in RAM (strings are small).
    final allIcons = await docsIsar.godotIcons.where().findAllAsync();

    if (mounted) {
      setState(() {
        _iconCache = {for (var icon in allIcons) icon.fileName: icon.content};
      });
    }
  }

  // Track enabled types locally for the UI switches
  List<int> enabledTypes = [];
  late UserSetting filterRecord;
  void _refreshList() {
    filterRecord = settingsRepo.getEnabledNodeTypes();
    enabledTypes =
        filterRecord.stringValue!.split(',').map((x) => int.parse(x)).toList();

    setState(() {
      // Use the 'anyOf' style query in Isar for maximum speed
      classes = docsIsar.classContents
          .where()
          .anyOf(
              enabledTypes,
              (q, int typeIndex) =>
                  q.nodeTypeEqualTo(classNodeType.values[typeIndex]))
          .sortByName()
          .findAll();
    });
  }

  List<Widget> buildFilterOptions() {
    List<Widget> ret = <Widget>[
      Text(
        'filtered classes are accessible in search and in-class links',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    ];

    final options = classNodeType.values.map((type) {
      final isEnabled = enabledTypes.contains(type.index);

      return ListTile(
        title: Text(filterName[type]!), // Or use a pretty map
        trailing: Switch(
          value: isEnabled,
          onChanged: (v) async {
            if (v) {
              enabledTypes.add(type.index);
            } else {
              enabledTypes.remove(type.index);
            }
            setState(() {
              enabledTypes = enabledTypes;
              // Save to repo and refresh the main list
            });
            settingsRepo.saveSettings(
                filterRecord..stringValue = enabledTypes.join(','));
            _refreshList();
          },
        ),
      );
    });
    ret.addAll(options);

    return ret;
  }

  Future<void> showFilterDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter List Nodes'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: buildFilterOptions(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close")),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: settingsRepo.watchAllSettings(),
        builder: (context, asyncSnapshot) {
          final currentLocale = settingsRepo.getTranslation().stringValue!;
          final currentVersion = settingsRepo.getGodotVersion().stringValue!;
          return MediaQuery(
              data: scaledMediaQueryData(context),
              child: Scaffold(
                drawer: GCRDrawer(),
                appBar: AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Godot v" + currentVersion + " classes"),
                      double.parse(currentVersion) >= 3.4 &&
                              currentLocale != 'en'
                          ? Text(
                              "Translation: " + currentLocale,
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
                        showFilterDialog();
                      },
                    ),
                    IconButton(
                      tooltip: 'Search',
                      icon: Icon(
                        Icons.search,
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
                body: ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final x = classes[index];
                    return Card(
                      child: Semantics(
                        label: getSpacedClassName(x.name!),
                        onTapHint: 'Read class detail',
                        child: ListTile(
                          leading: (x.svgFileName != null &&
                                  _iconCache.containsKey(x.svgFileName))
                              ? SvgIcon(svgContent: _iconCache[x.svgFileName]!)
                              : const DefaultClassIcon(),
                          title: Semantics(
                            excludeSemantics: true,
                            child: Text(
                              x.name!,
                              style: monoOptionalStyle(context),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClassDetail(className: x.name!),
                                ));
                          },
                          trailing: x.nodeType == classNodeType.None
                              ? null
                              : NodeTag(classContent: x),
                        ),
                      ),
                    );
                  },
                ),
              ));
        });
  }
}
