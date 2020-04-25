import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassThemeItems extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ClassThemeItems({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.themeItems == null || clsContent.themeItems.length == 0) {
      return Center(
        child: Text('0 theme item in this class'),
      );
    }

    return ScrollablePositionedList.builder(
      itemCount: clsContent.themeItems.length,
      itemScrollController: _scrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        final t = clsContent.themeItems[index];
        return ListTile(
          leading: Text(t.type),
          title: Text(t.name),
        );
      },
    );
  }
}
