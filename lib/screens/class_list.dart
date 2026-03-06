import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  late Isar docsIsar;
  late Isar prefsIsar;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.I(instanceName: MetadataKeys.docsIsarKey);
    prefsIsar = GetIt.I(instanceName: MetadataKeys.preferenceIsarKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: GCRDrawer(setScaleFunc: setScale),
  //     appBar: AppBar(
  //       title: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Godot v" + storedValues.version + " classes"),
  //           storedValues.versionDouble >= 3.4 &&
  //                   storedValues.translation != 'en'
  //               ? Text(
  //                   "Translation: " + storedValues.translation,
  //                   style: TextStyle(
  //                     color: Colors.grey,
  //                     fontSize: 13,
  //                   ),
  //                 )
  //               : SizedBox()
  //         ],
  //       ),
  //       actions: <Widget>[
  //         IconButton(
  //           tooltip: 'Filter classes shown on the list',
  //           icon: Icon(Icons.filter_alt_outlined),
  //           onPressed: () {
  //             showFilterDialog();
  //           },
  //         ),
  //         IconButton(
  //           tooltip: 'Search',
  //           icon: Icon(
  //             Icons.search,
  //           ),
  //           onPressed: () {
  //             Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) => SearchScreen()));
  //           },
  //         )
  //       ],
  //     ),
  //     body: buildList(),
  //   );
  // }

  // Widget buildList() {
  //   return BlocBuilder(
  //     bloc: _filterBloc,
  //     builder: (context, state) {
  //       return ListView(
  //           children: filterClasses(_classes)
  //               .map((f) => MediaQuery(
  //                     data: scaledMediaQueryData(context),
  //                     child: Card(
  //                       child: Semantics(
  //                         label: getSpacedClassName(f.name!),
  //                         onTapHint: 'Read class detail',
  //                         child: ListTile(
  //                           leading: ClassIcon(
  //                             classContent: f,
  //                             key: UniqueKey(),
  //                           ),
  //                           title: Semantics(
  //                             excludeSemantics: true,
  //                             child: Text(
  //                               f.name!,
  //                               style: monoOptionalStyle(context),
  //                             ),
  //                           ),
  //                           onTap: () {
  //                             Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       ClassDetail(className: f.name!),
  //                                 ));
  //                           },
  //                           trailing: f.nodeType == classNodeType.None
  //                               ? null
  //                               : NodeTag(classContent: f),
  //                         ),
  //                       ),
  //                     ),
  //                   ))
  //               .toList());
  //     },
    );
  }
}
