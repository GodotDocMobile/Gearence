import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../components/description_text.dart';
import '../../bloc/tap_event_arg.dart';
import '../../models/class_content.dart';
import '../../models/constant.dart';

class ClassConstants extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassConstants(
      {Key key, this.clsContent, this.eventStream, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassConstantsState createState() => _ClassConstantsState();
}

class _ClassConstantsState extends State<ClassConstants> {
  ItemScrollController _scrollController;
  ItemPositionsListener _itemPositionsListener;

  List<Constant> _onlyConstants = List<Constant>();

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _onlyConstants =
        widget.clsContent.constants.where((w) => w.enumValue == null).toList();
    widget.eventStream.listen((v) {
      try {
        scrollTo(v);
      } catch (_) {}
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Constant) {
      final _targetIndex =
          _onlyConstants.indexWhere((w) => w.name == args.fieldName);
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
    if (widget.clsContent.constants == null ||
        widget.clsContent.constants.where((w) => w.enumValue == null).length ==
            0) {
      return Center(
        child: Text('0 constant in this class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: _onlyConstants.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final c = _onlyConstants[index];
          return ListTile(
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
              className: widget.clsContent.name,
              content: c.constantText,
              onLinkTap: widget.onLinkTap,
            ),
          );
        });
  }
}
