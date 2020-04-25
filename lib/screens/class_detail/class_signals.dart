import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassSignals extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ClassSignals({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.signals == null || clsContent.signals.length == 0) {
      return Center(
        child: Text('0 signal in thie class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: clsContent.signals.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final s = clsContent.signals[index];
          return ListTile(
            title: Text(
              s.name +
                  s.arguments.map((a) {
                    return a.type + " " + a.name;
                  }).toString(),
            ),
            subtitle: DescriptionText(
              className: clsContent.name,
              content: s.description,
              onLinkTap: onLinkTap,
            ),
          );
        });
  }
}
