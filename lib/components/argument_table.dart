import 'package:flutter/material.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/method_argument.dart';
import 'package:godotclassreference/theme/themes.dart';

class ArgumentTable extends StatelessWidget {
  final List<MethodArgument>? arguments;
  const ArgumentTable({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (arguments != null && arguments!.length == 0) {
      return Container();
    }

    bool containsDefault = false;
    TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold);

    List<List<Widget>> tableCells = [
      <Widget>[
        Text("Type", style: headerStyle),
        Text("Name", style: headerStyle),
      ]
    ];
    arguments!.forEach((element) {
      var _toAdd = <Widget>[];

      // argument type
      _toAdd.add(LinkText(
        text: element.type!,
        // onLinkTap: widget.onLinkTap,
      ));

      // argument name
      _toAdd.add(
        Text(
          element.name!,
          style: monoOptionalStyle(context),
        ),
      );

      // argument default value (if any)
      if (element.defaultValue != null) {
        containsDefault = true;
        _toAdd.add(Text(
          element.defaultValue!,
          style: monoOptionalStyle(context),
        ));
      }
      tableCells.add(_toAdd);
    });

    if (containsDefault) {
      tableCells[0].add(Text("Default", style: headerStyle));
      tableCells.forEach((element) {
        if (element.length == 2) {
          element.add(SizedBox());
        }
      });
    }

    // assemble table
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("arguments:"),
      SizedBox(
        height: 5,
      ),
      Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(
                width: 2,
                color: storedValues.isDarkTheme ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(5)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth()
            },
            children: tableCells.map((e) {
              return TableRow(
                  children: e.map((i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: i,
                  ),
                );
              }).toList());
            }).toList(),
          ),
        ),
      ),
      Divider(),
    ]);
  }
}
