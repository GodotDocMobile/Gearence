import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassEnums extends StatelessWidget {
  final ClassContent clsContent;
  final String scrollTo;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController scrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  ClassEnums(
      {Key key,
      @required this.clsContent,
      this.scrollTo,
      @required this.onLinkTap})
      : assert(clsContent != null),
        assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.constants == null ||
        clsContent.constants
                .where((w) => w != null && w.enumValue != null)
                .length ==
            0) {
      return Center(
        child: Text('0 enum in this class'),
      );
    }
    final _enums = clsContent.constants
        .map((c) {
          return c.enumValue;
        })
        .toSet()
        .where((w) => w != null)
        .toList();

    final _toRtn = ScrollablePositionedList.builder(
      padding: EdgeInsets.all(5),
      itemCount: _enums.length,
      itemScrollController: scrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (context, index) {
        final _enumValues = clsContent.constants
            .where((w) => w.enumValue == _enums[index])
            .toList();
        _enumValues.sort((a, b) => a.value.compareTo(b.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'enum ',
                  style: TextStyle(color: godotColor, fontSize: 20),
                ),
                Text(
                  _enums[index],
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  ':',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Column(
              children: _enumValues.map((c) {
                return ListTile(
                  title: Text(c.name + ' = ' + c.value),
                  subtitle: DescriptionText(
                    className: clsContent.name,
                    content: c.constantText,
                    onLinkTap: onLinkTap,
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 5,
            )
          ],
        );
      },
    );

//    if (scrollTo != null && scrollTo.length > 0) {
//      _scrollController.jumpTo(index: _scrollIndex);
//    }
//    _scrollController.jumpTo(index: _enums.length - 1);

    return _toRtn;
  }
}
