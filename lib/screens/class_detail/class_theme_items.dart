import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassThemeItems extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassThemeItems(
      {Key key, this.clsContent, this.eventStream, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassThemeItemsState createState() => _ClassThemeItemsState();
}

class _ClassThemeItemsState extends State<ClassThemeItems> {
  ItemScrollController _scrollController;
  ItemPositionsListener _itemPositionsListener;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    widget.eventStream.listen((v) {
      try {
        scrollTo(v);
      } catch (_) {}
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.ThemeItem) {
      final _targetIndex = widget.clsContent.themeItems
          .indexWhere((w) => w.name == args.fieldName);
      if (_targetIndex != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: _targetIndex,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clsContent.themeItems == null ||
        widget.clsContent.themeItems.length == 0) {
      return Center(
        child: Text('0 theme item in this class'),
      );
    }

    return ScrollablePositionedList.builder(
      itemCount: widget.clsContent.themeItems.length,
      itemScrollController: _scrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        final t = widget.clsContent.themeItems[index];
        return ListTile(
          leading: ClassDB().getDB().any((element) => element.name == t.type)
              ? InkWell(
                  child: Text(
                    t.type,
                    style: TextStyle(
                      color: godotColor,
                    ),
                  ),
                )
              : Text(t.type),
          title: Text(t.name),
        );
      },
    );
  }
}
