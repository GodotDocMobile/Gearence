import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../bloc/tap_event_arg.dart';
import '../../constants/class_db.dart';
import '../../constants/colors.dart';
import '../../models/class_content.dart';

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
        return Column(
          children: [
            ListTile(
              title: Text(t.name),
              subtitle: Row(
                children: [
                  Text("type"),
                  SizedBox(
                    width: 10,
                  ),
                  ClassDB().getDB().any((element) => element.name == t.type)
                      ? InkWell(
                          child: Text(
                            t.type,
                            style: TextStyle(
                              color: godotColor,
                            ),
                          ),
                          onTap: () {
                            TapEventArg _arg = TapEventArg(
                                className: t.type,
                                linkType: LinkType.Class,
                                fieldName: '');
                            widget.onLinkTap(_arg);
                          },
                        )
                      : Text(t.type)
                ],
              ),
            ),
            Divider(
              color: Colors.blueGrey,
            )
          ],
        );
      },
    );
  }
}
