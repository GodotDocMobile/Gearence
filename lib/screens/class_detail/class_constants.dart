import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassConstants extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ClassConstants({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.constants == null ||
        clsContent.constants.where((w) => w.enumValue == null).length == 0) {
      return Center(
        child: Text('0 constant in this class'),
      );
    }

    final _onlyConstants =
        clsContent.constants.where((w) => w.enumValue == null).toList();

    return ScrollablePositionedList.builder(
        itemCount: _onlyConstants.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final c = _onlyConstants[index];
          return ListTile(
//          leading: Card(
//            child: Text(c.value),
//          ),
            title: Row(
              children: <Widget>[
                Text(c.name),
                Text(
                  ' = ' + c.value,
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            subtitle: DescriptionText(
              className: clsContent.name,
              content: c.constantText,
              onLinkTap: onLinkTap,
            ),
          );
        });
  }
}
